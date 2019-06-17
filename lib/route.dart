import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/proxy_settings/proxy_settings_page.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import './pages/home/home_page.dart';
import './pages/login/login_page.dart';
import './pages/profile/profile_page.dart';
import './pages/settings/settings_page.dart';
import './pages/help/help_page.dart';
import './intro.dart';

class FlibustaApp extends StatelessWidget {
  static const String versionName = '0.2.2';
  static const int versionCode = 10;

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
      dividerColor: Colors.grey[400],
      scaffoldBackgroundColor: Colors.grey[100],
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
          home: HomePage(),
          supportedLocales: [Locale("ru"),],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/':
              case HomePage.routeName:
                return MaterialPageRoute(builder: (context) => HomePage());
              case Profile.routeName:
                return MaterialPageRoute(builder: (context) => Profile());
              case Login.routeName:
                return MaterialPageRoute(builder: (context) => Login());
              case Settings.routeName:
                return MaterialPageRoute(builder: (context) => Settings());
              case IntroPage.routeName:
                return MaterialPageRoute(builder: (context) => IntroPage());
              case ProxySettingsPage.routeName:
                return MaterialPageRoute(
                    builder: (context) => ProxySettingsPage());
              case Help.routeName:
                return MaterialPageRoute(builder: (context) => Help());
              case BookPage.routeName:
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) => BookPage(bookId: settings.arguments));
              case AuthorPage.routeName:
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        AuthorPage(authorId: settings.arguments));
              case SequencePage.routeName:
                return MaterialPageRoute(
                    settings: settings,
                    builder: (context) =>
                        SequencePage(sequenceId: settings.arguments));
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
