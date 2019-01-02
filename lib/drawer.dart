import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _biggerFont = const TextStyle(fontSize: 18.0);

class MyDrawer {
  Drawer build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget> [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.all(0),
              accountName: Text("Флибуста", style: TextStyle(color: Colors.black),),
              accountEmail: Text("Книжное братство", style: TextStyle(color: Colors.black),),
              // currentAccountPicture: CircleAvatar(

              // ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/img/bg-header.png")
                )
              ),
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.home),
              title: Text('Главная', style: _biggerFont,),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            // ListTile(
            //   leading: Icon(FontAwesomeIcons.home),
            //   title: Text('Расширенный поиск', style: _biggerFont,),
            //   onTap: () {
            //     Navigator.of(context).pushNamed("/");
            //   },
            // ),
            // ListTile(
            //   leading: Icon(FontAwesomeIcons.userCircle),
            //   title: Text('Мой профиль', style: _biggerFont,),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     Navigator.of(context).pushNamed("/Profile");
            //   },
            // ),
            ListTile(
              leading: Icon(FontAwesomeIcons.projectDiagram, size: 18.0,),
              title: Text('Настройки Proxy', style: _biggerFont,),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/ProxySettings");
              },
            ),
            // ListTile(
            //   leading: Icon(FontAwesomeIcons.cog),
            //   title: Text('Настройки', style: _biggerFont,),
            //   onTap: () {
            //     Navigator.of(context).pop();
            //     Navigator.of(context).pushNamed("/Settings");
            //   },
            // ),
            Divider(),
            ListTile(
              leading: Icon(FontAwesomeIcons.infoCircle, size: 26.0,),
              title: Text('О приложении', style: _biggerFont,),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/Help");
              },
            ),
            // AboutListTile(icon: Icon(Icons.info_outline),)
          ],
        )
      );
  }
}