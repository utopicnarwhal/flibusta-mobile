import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flibusta/pages/help/help_page.dart';
import 'package:flibusta/pages/proxy_settings/proxy_settings_page.dart';
import 'package:flibusta/route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _biggerFont = const TextStyle(fontSize: 18.0);

class FlibustaDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              UserAccountsDrawerHeader(
                margin: EdgeInsets.all(0),
                accountName: Text(
                  "Флибуста",
                  style: TextStyle(color: Colors.black),
                ),
                accountEmail: Text(
                  "Книжное братство",
                  style: TextStyle(color: Colors.black),
                ),
                // currentAccountPicture: CircleAvatar(

                // ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/img/bg-header.png"),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.home),
                title: Text(
                  'Главная',
                  style: _biggerFont,
                ),
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
                leading: Icon(
                  FontAwesomeIcons.projectDiagram,
                  size: 22.0,
                ),
                title: Text(
                  'Настройки Proxy',
                  style: _biggerFont,
                ),
                onTap: () {
                  Navigator.of(context).popAndPushNamed(ProxySettingsPage.routeName);
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
                leading: Icon(
                  FontAwesomeIcons.infoCircle,
                  size: 26.0,
                ),
                title: Text(
                  'О приложении',
                  style: _biggerFont,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(Help.routeName);
                },
              ),
              ThemeSwitcher(),
              // AboutListTile(icon: Icon(Icons.info_outline),)
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('Версия приложения ${FlibustaApp.versionName}'),
          ),
        ],
      ),
    );
  }
}

class ThemeSwitcher extends StatefulWidget {
  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        "Ночной режим",
        style: _biggerFont,
      ),
      secondary: Icon(FontAwesomeIcons.solidMoon),
      value: DynamicTheme.of(context).brightness == Brightness.dark,
      onChanged: (value) {
        setState(() {
          DynamicTheme.of(context)
              .setBrightness(value ? Brightness.dark : Brightness.light);
        });
      },
    );
  }
}
