import 'package:flutter/material.dart';
import 'login_body.dart';

class LoginScreen extends StatelessWidget {
  static const String TAG = "LoginScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(automaticallyImplyLeading: false, title: Text('P2P calls')),
      body: BodyLayout(),
    );
  }
}
