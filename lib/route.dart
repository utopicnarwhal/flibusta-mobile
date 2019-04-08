import 'package:flibusta/blocs/theme_data/theme_data_bloc.dart';
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
      scaffoldBackgroundColor: Color(0xFF00003f),
    );

    var _customLightTheme = ThemeData.light().copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        isDense: true,
      ),
      scaffoldBackgroundColor: Colors.grey.shade300,
    );

    LocalStore().getIsDarkTheme().then((isDarkTheme) {
      if (isDarkTheme) {
        ThemeDataBloc().switchToDarkTheme();
      }
    });
    
    return StreamBuilder(
      initialData: false,
      stream: ThemeDataBloc().themeDataStream,
      builder: (BuildContext context, AsyncSnapshot<bool> isDarkTheme) {
        return MaterialApp(
          title: 'Flibusta',
          theme: isDarkTheme.data ? _customDarkTheme : _customLightTheme,
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
