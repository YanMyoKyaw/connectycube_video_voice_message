import 'package:flutter/material.dart';
import 'chatmessage.dart';
// import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

class ChatScreen extends StatefulWidget {
  final CubeDialog cubeDialog;
  final List<int> opponentId;

  ChatScreen(this.cubeDialog, this.opponentId);
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _getMessages();
    _receiveMessage();
  }

  //Get All Message
  void _getMessages() {
    setState(() {
      loading = true;
    });
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
          oppId: widget.opponentId[0],
        ));
      }
      loading = false;
      setState(() {});
    }).catchError((error) {
      setState(() {
        loading = false;
      });
    });
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
        oppId: widget.opponentId[0],
      );
      setState(() {
        _messages.insert(0, chatMessage);
      });
    }).onError((handleError) {
      print("Message Listener Error $handleError");
    });
  }

  void _handleSubmit(String text) {
    textEditingController.clear();
    ChatMessage chatMessage = new ChatMessage(
      text: text,
      isReceive: false,
      isSend: true,
      oppId: widget.opponentId[0],
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
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
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
          );
  }
}
