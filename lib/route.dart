import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/proxy_settings/proxy_settings_page.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './pages/home/home_page.dart';
import './pages/login/login_page.dart';
import './pages/profile/profile_page.dart';
import './pages/settings/settings_page.dart';
import './pages/help/help_page.dart';
import './intro.dart';

class FlibustaApp extends StatelessWidget {
  static const String versionName = '0.2.0';
  static const int versionCode = 8;

  @override
  Widget build(BuildContext context) {
    var _customDarkTheme = ThemeData.dark().copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        isDense: true,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          }),
    );

    var _customLightTheme = ThemeData.light().copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        isDense: true,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          }),
      dividerColor: Colors.grey.shade400,
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
          initialRoute: HomePage.routeName,
          home: HomePage(),
          routes: <String, WidgetBuilder>{
            HomePage.routeName: (BuildContext context) => HomePage(),
            Profile.routeName: (BuildContext context) => Profile(),
            Login.routeName: (BuildContext context) => Login(),
            Settings.routeName: (BuildContext context) => Settings(),
            IntroScreen.routeName: (BuildContext context) => IntroScreen(),
            ProxySettingsPage.routeName: (BuildContext context) =>
                ProxySettingsPage(),
            Help.routeName: (BuildContext context) => Help(),
          },
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case BookPage.routeName:
                return CupertinoPageRoute(settings: settings, builder: (context) => BookPage(bookId: settings.arguments));
              case AuthorPage.routeName:
                return CupertinoPageRoute(settings: settings, builder: (context) => AuthorPage(authorId: settings.arguments));
              case SequencePage.routeName:
                return CupertinoPageRoute(settings: settings, builder: (context) => SequencePage(sequenceId: settings.arguments));
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
