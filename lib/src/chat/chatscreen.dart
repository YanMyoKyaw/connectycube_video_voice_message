import 'package:flutter/material.dart';
import 'chatmessage.dart';
// import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:p2p_call_sample/src/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final CubeDialog cubeDialog;
  final List<int> opponentId;
  final P2PClient _callClient;
  P2PSession _currentCall;

  ChatScreen(
      this.cubeDialog, this.opponentId, this._callClient, this._currentCall);
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();
    _getMessages();
    _receiveMessage();
  }

  //Get All Message
  void _getMessages() {
    GetMessagesParameters messagesParameters = GetMessagesParameters();
    messagesParameters.limit = 100;
    messagesParameters.filters = [
      RequestFilter(
          "", "date_sent", QueryRule.LT, DateTime.now().millisecondsSinceEpoch)
    ];
    messagesParameters.markAsRead = true;
    messagesParameters.sorter = RequestSorter(OrderType.DESC, "", "date_sent");
    getMessages(widget.cubeDialog.dialogId,
            messagesParameters.getRequestParameters())
        .then((pagedResult) {
      List<CubeMessage> messageList = pagedResult.items;
      for (int i = 0; i < messageList.length; i++) {
        CubeMessage cubeMessage = messageList[i];
        bool isSend = false, isReceive = false;
        if (widget.opponentId.contains(cubeMessage.senderId)) {
          isReceive = true;
        } else {
          isSend = true;
        }
        _messages.add(ChatMessage(
          text: cubeMessage.body,
          isReceive: isReceive,
          isSend: isSend,
        ));
      }
      setState(() {});
    }).catchError((error) {});
  }

  // Receive message
  void _receiveMessage() {
    ChatMessagesManager chatMessagesManager =
        CubeChatConnection.instance.chatMessagesManager;
    chatMessagesManager.chatMessagesStream.listen((message) {
      ChatMessage chatMessage = ChatMessage(
        text: message.body,
        isReceive: true,
        isSend: false,
      );
      setState(() {
        _messages.insert(0, chatMessage);
      });
    }).onError((handleError) {
      print("Message Listener Error $handleError");
    });
  }

  void _startCall(int callType, Set<int> opponents) {
    if (opponents.isEmpty) return;

    P2PSession callSession =
        widget._callClient.createCallSession(callType, opponents);
    widget._currentCall = callSession;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationCallScreen(callSession, false),
      ),
    );
  }

  void _handleSubmit(String text) {
    textEditingController.clear();
    ChatMessage chatMessage = new ChatMessage(
      text: text,
      isReceive: false,
      isSend: true,
    );
    CubeMessage message = CubeMessage();
    message.body = text;
    message.dateSent = DateTime.now().millisecondsSinceEpoch;
    message.markable = true;
    message.saveToHistory = true;
    widget.cubeDialog.sendMessage(message).then((value) {
      setState(() {
        //used to rebuild our widget
        _messages.insert(0, chatMessage);
      });
    }).catchError((onError) {
      print("Message Send Error $onError");
    });
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                decoration: new InputDecoration.collapsed(
                    hintText: "Enter your message"),
                controller: textEditingController,
                onSubmitted: _handleSubmit,
              ),
            ),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmit(textEditingController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messager"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              onPressed: () {
                _startCall(
                    CallType.AUDIO_CALL, Set<int>.from(widget.opponentId));
              }),
          IconButton(
              icon: Icon(
                Icons.video_call,
                color: Colors.white,
              ),
              onPressed: () {
                _startCall(
                    CallType.VIDEO_CALL, Set<int>.from(widget.opponentId));
              })
        ],
      ),
      body: Material(
        child: Column(
          children: <Widget>[
            new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            new Divider(
              height: 1.0,
            ),
            new Container(
              decoration: new BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: _textComposerWidget(),
            )
          ],
        ),
      ),
    );
  }
}
