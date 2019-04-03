import 'package:flibusta/pages/proxy_settings/proxy_setting_page.dart';
import 'package:flutter/material.dart';
import './pages/home/home_page.dart';
import './pages/login/login_page.dart';
import './pages/profile/profile_page.dart';
import './pages/settings/settings_page.dart';
import './pages/help/help_page.dart';
import './intro.dart';

class FlibustaApp extends StatelessWidget {
  ThemeData _customDarkTheme;

  FlibustaApp() {
    _customDarkTheme = ThemeData.dark().copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flibusta',
      theme: _customDarkTheme,
      // theme: ThemeData(
      //   primaryColor: Colors.blue,
      //   primarySwatch: Colors.blue,
      //   inputDecorationTheme: InputDecorationTheme(
      //     border: OutlineInputBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
      //     ),
      //     isDense: true,
      //   )
      //   // pageTransitionsTheme: PageTransitionsTheme( TODO: uncomment when drawer with cupertino fixed
      //   //   builders: <TargetPlatform, PageTransitionsBuilder> {
      //   //     TargetPlatform.android: CupertinoPageTransitionsBuilder()
      //   //   }
      //   // )
      // ),
      routes: <String, WidgetBuilder>{
        "/": (BuildContext context) => Home(),
        "/Profile": (BuildContext context) => Profile(),
        "/Login": (BuildContext context) => Login(),
        "/Settings": (BuildContext context) => Settings(),
        "/Intro": (BuildContext context) => IntroScreen(),
        "/ProxySettings": (BuildContext context) => ProxySettings(),
        "/Help": (BuildContext context) => Help()
      },
    );
  }
}
