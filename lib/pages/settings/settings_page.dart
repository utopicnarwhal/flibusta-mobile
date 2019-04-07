import '../../drawer.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  static const routeName = "/Settings";
  
  @override
  createState() => new SettingsState();
}

class SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: false,
        title: new Text("Настройки"),
      ),
      drawer: new MyDrawer().build(context),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new TextField(
            decoration: new InputDecoration(
              labelText: "Proxy Host"
            ),
          )
        ],
      ),
    );
  }
}