import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  static const routeName = "/Settings";
  
  @override
  createState() => new SettingsState();
}

class SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Настройки"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: "Proxy Host"
            ),
          )
        ],
      ),
    );
  }
}