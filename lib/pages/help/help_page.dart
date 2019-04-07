import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatefulWidget {
  static const routeName = "/Help";
  
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListTile(
                    title: Text("Разработчик"),
                    subtitle: Text("Данилов Сергей(@utopicnarwhal)\ngigok@bk.ru"),
                    isThreeLine: true,
                    onTap: () async {
                      launch("mailto:gigok@bk.ru");
                    }
                  ),
                  Divider(height: 1,),
                  ListTile(
                    title: Text("Github"),
                    subtitle: Text("github.com/utopicnarwhal/FlibustaApp"),
                    onTap: () async {
                      await launch("https://github.com/utopicnarwhal/FlibustaApp");
                    },
                  )
                ]
              ),
            )
          ],
        )
      ),
    );
  }
}