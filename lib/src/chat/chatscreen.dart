import 'package:flutter/material.dart';
import 'ChatMessage.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';

class ChatScreen extends StatefulWidget {
  final CubeDialog cubeDialog;

  ChatScreen(this.cubeDialog);
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
    ChatMessagesManager chatMessagesManager =
        CubeChatConnection.instance.chatMessagesManager;
    chatMessagesManager.chatMessagesStream.listen((message) {
      print("Resive Message $message");
    }).onError((handleError) {
      print("Message Listener Error $handleError");
    });
  }

  void _handleSubmit(String text) {
    textEditingController.clear();
    ChatMessage chatMessage = new ChatMessage(text: text);
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
