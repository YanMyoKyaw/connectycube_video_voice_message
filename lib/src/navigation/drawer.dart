import 'package:flutter/material.dart';
import 'draweritem.dart';
import 'package:p2p_call_sample/src/fragments/fragmentone.dart';
import 'package:p2p_call_sample/src/fragments/fragmenttwo.dart';
import 'package:p2p_call_sample/src/fragments/fragmentthree.dart';

class DrawerPage extends StatefulWidget {
  final drawerItems = [
    DrawerItem("Fragment One", Icons.ac_unit),
    DrawerItem("Fragment Two", Icons.child_care),
    DrawerItem("Fragment Three", Icons.check_circle)
  ];

  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<DrawerPage> {
  int _selectedIndex = 0;

  _renderWidget(int index) {
    switch (index) {
      case 0:
        return FragmentOne();
      case 1:
        return FragmentTwo();
      case 2:
        return FragmentThree();
      default:
        return Center(
          child: Text("Something Wrong"),
        );
    }
  }

  _onSelectedItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _drawerItemList = [];

    for (int i = 0; i < widget.drawerItems.length; i++) {
      var di = widget.drawerItems[i];
      _drawerItemList.add(ListTile(
        leading: Icon(di.iconData),
        title: Text(di.title),
        selected: i == _selectedIndex,
        onTap: () => _onSelectedItem(i),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Drawer Bar"),
      ),
      drawer: Drawer(
        child:  Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text("John Doe"), accountEmail: null),
            new Column(
              children: _drawerItemList,
            )
          ],
        ),
      ),
      body: _renderWidget(_selectedIndex),
    );
  }
}
