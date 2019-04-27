import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  static const routeName = "/Profile";

  @override
  createState() => new ProfileState();
}

class ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: false,
        title: new Text("Мой профиль"),
      )
    );
  }
}