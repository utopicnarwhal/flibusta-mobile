import 'package:flibusta/services/http_client_service.dart';

import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  createState() => new ProfileState();
}

class ProfileState extends State<Profile> {
  var _httpClient = new ProxyHttpClient().getHttpClient();

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