import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      // TODO: implement build
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 70.0,
            height: 70.0,
            child: Center(child: CircularProgressIndicator(backgroundColor: Colors.black,)),
          ),
        ],
      );
    }
}