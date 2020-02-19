import 'package:flibusta/ds_controls/ui/splash_screen.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/views/profile_view/components/about/about.dart';
import 'package:flibusta/pages/home/views/profile_view/components/about/donate.dart';
import 'package:flibusta/pages/home/views/profile_view/components/settings/settings.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flutter/material.dart';
import './pages/home/home_page.dart';
import './pages/login/login_page.dart';
import './intro.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) {
      // return CotrolsDemoPage();

      if (settings.isInitialRoute) {
        return SplashScreen();
      }

      switch (settings.name) {
        case '/':
        case HomePage.routeName:
          return HomePage();
        case Login.routeName:
          return Login();
        case IntroPage.routeName:
          return IntroPage();
        case AboutPage.routeName:
          return AboutPage();
        case DonatePage.routeName:
          return DonatePage();
        case SettingsPage.routeName:
          return SettingsPage();
        case BookPage.routeName:
          return BookPage(bookId: settings.arguments);
        case AuthorPage.routeName:
          return AuthorPage(authorId: settings.arguments);
        case SequencePage.routeName:
          return SequencePage(sequenceId: settings.arguments);
        default:
          print('undefined route');
      }
      return HomePage();
    },
  );
}
