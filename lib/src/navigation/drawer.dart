import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:p2p_call_sample/src/utils/configs.dart' as config;
import 'package:p2p_call_sample/src/chat/chatscreen.dart';
import 'package:p2p_call_sample/src/chat/chatscreentwo.dart';
import 'package:p2p_call_sample/src/chat/chatscreenthree.dart';
import 'package:p2p_call_sample/src/conversion_screen.dart';
import 'package:p2p_call_sample/src/incoming_call.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<DrawerPage> {
  int _selectedIndex = 0;
  int _selectOppoId;
  P2PClient _callClient;
  P2PSession _currentCall;
  CubeDialog _cubeDialog;

  _renderWidget(int index, CubeUser user) {
    if (user.id == _selectOppoId) {
      switch (_selectedIndex) {
        case 0:
          return ChatScreen(_cubeDialog, [user.id]);
        case 1:
          return ChatScreenTwo(_cubeDialog, [user.id]);
        case 2:
          return ChatScreenThree(_cubeDialog, [user.id]);
      }
    } else {
      return Center(
        child: Text("Please Select One Partner For Chat"),
      );
    }
  }

  _onSelectedItem(int index, int id) {
    CubeDialog cubeDialog =
        CubeDialog(CubeDialogType.PRIVATE, occupantsIds: [id]);
    createDialog(cubeDialog).then((value) {
      setState(() {
        _selectedIndex = index;
        _cubeDialog = value;
        _selectOppoId = id;
      });
    }).catchError((onError) => print("Cannot create cube dialog"));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    CubeUser user = CubeChatConnection.instance.currentUser;
    final users = config.users.where((usr) => usr.id != user.id).toList();

    List<Widget> _drawerItemList = [];

    for (int i = 0; i < users.length; i++) {
      var di = users[i];
      _drawerItemList.add(ListTile(
        leading: CircleAvatar(
          child: Text(di.fullName[0]),
        ),
        title: Text(di.fullName),
        selected: di.id == _selectOppoId,
        onTap: () => _onSelectedItem(i, di.id),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(users[_selectedIndex].fullName),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              onPressed: () {
                _startCall(CallType.AUDIO_CALL, Set<int>.from([_selectOppoId]));
              }),
          IconButton(
              icon: Icon(
                Icons.video_call,
                color: Colors.white,
              ),
              onPressed: () {
                _startCall(CallType.VIDEO_CALL, Set<int>.from([_selectOppoId]));
              }),
          IconButton(
            onPressed: () => _logOut(context),
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text(user.fullName),
                accountEmail: Text(user.email != null ? user.email : "")),
            new Column(
              children: _drawerItemList,
            )
          ],
        ),
      ),
      body: _renderWidget(_selectedIndex, users[_selectedIndex]),
    );
  }

  _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want logout current user"),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                signOut().then(
                  (voidValue) {
                    CubeChatConnection.instance.logout();
                    CubeChatConnection.instance.destroy();
                    P2PClient.instance.destroy();
                    Navigator.pop(context); // cancel current Dialog
                    _navigateToLoginScreen(context);
                  },
                ).catchError(
                  (onError) {
                    P2PClient.instance.destroy();
                    Navigator.pop(context); // cancel current Dialog
                    _navigateToLoginScreen(context);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToLoginScreen(BuildContext context) {
    Navigator.pop(context);
  }

  //For P2p call
  @override
  void initState() {
    super.initState();

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
    mediaConfig.minHeight = 520;
    mediaConfig.minWidth = 1280;
    mediaConfig.minFrameRate = 30;
  }

  void _startCall(int callType, Set<int> opponents) {
    if (opponents.isEmpty) return;

    P2PSession callSession = _callClient.createCallSession(callType, opponents);
    _currentCall = callSession;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationCallScreen(callSession, false),
      ),
    );
  }
}
