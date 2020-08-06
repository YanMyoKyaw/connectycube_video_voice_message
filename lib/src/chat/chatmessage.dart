import 'package:flutter/material.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:p2p_call_sample/src/utils/configs.dart' as config;

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isSend, isReceive;
  final int oppId;
  //for opotional params we use curly braces
  ChatMessage({this.text, this.isReceive, this.isSend, this.oppId});
  @override
  Widget build(BuildContext context) {
    CubeUser user = CubeChatConnection.instance.currentUser;
    final senders = config.users.where((usr) => usr.id == oppId).toList();
    CubeUser sender = senders[0];
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        mainAxisAlignment:
            isReceive ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: <Widget>[
          isReceive
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: new CircleAvatar(
                    child: new Text(sender.fullName[0]),
                    backgroundColor: Colors.pink,
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(isReceive ? sender.fullName : user.fullName,
                  style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              )
            ],
          ),
          isSend
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: new CircleAvatar(
                    child: new Text(user.fullName[0]),
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }
}
