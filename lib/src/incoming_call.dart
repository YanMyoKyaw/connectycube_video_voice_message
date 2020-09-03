import 'package:flutter/material.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'conversion_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  static const String TAG = "IncomingCallScreen";
  final P2PSession _callSession;

  IncomingCallScreen(this._callSession);

  @override
  Widget build(BuildContext context) {

    FlutterRingtonePlayer.playRingtone(looping: true,);
    Vibration.vibrate(duration: 45000, repeat: 10, intensities: [1, 255]);

    _callSession.onSessionClosed = (callSession) {
      log("_onSessionClosed", TAG);
      FlutterRingtonePlayer.stop();
      Vibration.cancel();
      Navigator.pop(context);
    };

    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(36),
                    child: Text(_getCallTitle(), style: TextStyle(fontSize: 28, color: Colors.white)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 36, bottom: 8),
                    child: Text("Members:", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 86),
                    child: Text(_callSession.opponentsIds.join(", "),
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 36),
                        child: FloatingActionButton(
                          heroTag: "RejectCall",
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.red,
                          onPressed: () => _rejectCall(context, _callSession),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 36),
                        child: FloatingActionButton(
                          heroTag: "AcceptCall",
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.green,
                          onPressed: () => _acceptCall(context, _callSession),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  _getCallTitle() {
    String callType;

    switch (_callSession.callType) {
      case CallType.VIDEO_CALL:
        callType = "Video";
        break;
      case CallType.AUDIO_CALL:
        callType = "Audio";
        break;
    }

    return "Incoming $callType call";
  }

  void _acceptCall(BuildContext context, P2PSession callSession) {
    FlutterRingtonePlayer.stop();
    Vibration.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationCallScreen(callSession, true),
      ),
    );
  }

  void _rejectCall(BuildContext context, P2PSession callSession) {
    FlutterRingtonePlayer.stop();
    Vibration.cancel();
    callSession.reject();
  }

  Future<bool> _onBackPressed(BuildContext context) {
    return Future.value(false);
  }
}