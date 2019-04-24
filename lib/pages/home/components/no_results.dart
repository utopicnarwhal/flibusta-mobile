import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(FontAwesomeIcons.frownOpen, size: 45),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Извините, но книг с данным названием не существует в нашей библиотеке.",
            style: TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
