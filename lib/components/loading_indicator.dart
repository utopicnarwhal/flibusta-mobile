import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      // TODO: implement build
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 70.0,
            height: 70.0,
            child: new Center(child: new CircularProgressIndicator()),
          ),
        ],
      );
    }
}