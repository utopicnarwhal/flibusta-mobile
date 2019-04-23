import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flibusta/pages/proxy_settings/proxy_setting_page.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flutter/material.dart';
import './pages/home/home_page.dart';
import './pages/login/login_page.dart';
import './pages/profile/profile_page.dart';
import './pages/settings/settings_page.dart';
import './pages/help/help_page.dart';
import './intro.dart';

class FlibustaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _customDarkTheme = ThemeData.dark().copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        isDense: true,
      ),
    );

    var _customLightTheme = ThemeData.light().copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        isDense: true,
      ),
    );

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) {
        if (brightness == Brightness.dark) {
          return _customDarkTheme;
        }
        return _customLightTheme;
      },
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'Флибуста',
          theme: theme,
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
          home: Home(),
          routes: <String, WidgetBuilder>{
            Home.routeName: (BuildContext context) => Home(),
            Profile.routeName: (BuildContext context) => Profile(),
            Login.routeName: (BuildContext context) => Login(),
            Settings.routeName: (BuildContext context) => Settings(),
            IntroScreen.routeName: (BuildContext context) => IntroScreen(),
            ProxySettings.routeName: (BuildContext context) => ProxySettings(),
            Help.routeName: (BuildContext context) => Help(),
          },
        );
      },
    );
  }
}
