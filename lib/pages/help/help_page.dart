import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  @override
  createState() => HelpState();
}

class HelpState extends State<Help> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: new AppBar(
        centerTitle: false,
        title: new Text("О приложении"),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)]),
            child: ListTile(
              title: Text("Разработчик"),
              subtitle: Text("Данилов Сергей(@utopicnarwhal)\ngigok@bk.ru"),
              isThreeLine: true,
            ),
          )
        ],
      ),
    );
  }
}