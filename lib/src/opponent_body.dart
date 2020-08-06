import 'package:flutter/material.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';

import 'call_screen.dart';
import 'utils/configs.dart' as utils;
import 'chat/chatscreen.dart';

class BodyLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyLayoutState();
  }
}

class _BodyLayoutState extends State<BodyLayout> {
  Set<int> _selectedUsers;
  P2PClient _callClient;
  P2PSession _currentCall;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Text(
              "Select users to call:",
              style: TextStyle(fontSize: 22),
            ),
            Expanded(
              child: _getOpponentsList(context),
            ),
          ],
        ));
  }

  Widget _getOpponentsList(BuildContext context) {
    CubeUser currentUser = CubeChatConnection.instance.currentUser;
    final users =
        utils.users.where((user) => user.id != currentUser.id).toList();

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Center(
              child: Text(
                users[index].fullName,
              ),
            ),
            onTap: (() {
              _selectedUsers.add(users[index].id);
              List<int> oppoList = List.from(_selectedUsers);
              CubeDialog cubeDialog =
                  CubeDialog(CubeDialogType.PRIVATE, occupantsIds: oppoList);
              createDialog(cubeDialog).then((value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(value, oppoList,_callClient,_currentCall)));
              }).catchError((onError) => print("Cannot create cube dialog"));
            }),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _selectedUsers = {};
    _initCustomMediaConfigs();
    _initCalls();
  }

  void _initCalls() {
    _callClient = P2PClient.instance;

    _callClient.init();

    _callClient.onReceiveNewSession = (callSession) {
      if (_currentCall != null &&
          _currentCall.sessionId != callSession.sessionId) {
        callSession.reject();
        return;
      }

      _showIncomingCallScreen(callSession);
    };

    _callClient.onSessionClosed = (callSession) {
      if (_currentCall != null &&
          _currentCall.sessionId == callSession.sessionId) {
        _currentCall = null;
      }
    };
  }

  void _showIncomingCallScreen(P2PSession callSession) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(callSession),
      ),
    );
  }

  void _initCustomMediaConfigs() {
    RTCMediaConfig mediaConfig = RTCMediaConfig.instance;
    mediaConfig.minHeight = 720;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;
  }
}