import 'package:flibusta/ds_controls/ui/splash_screen.dart';
import 'package:flibusta/pages/advanced_search/advanced_search.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/favorites/favorites_page.dart';
import 'package:flibusta/pages/home/views/profile_view/pages/about.dart';
import 'package:flibusta/pages/home/views/profile_view/pages/settings.dart';
import 'package:flibusta/pages/home/views/proxy_settings/pages/tor_onion_proxy_page.dart';
import 'package:flibusta/pages/login_page/login_page.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/pages/intro.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) {
      // return CotrolsDemoPage();

      switch (settings.name) {
        case '/':
          return SplashScreen();
        case HomePage.routeName:
          return HomePage();
        case TorOnionProxyPage.routeName:
          return TorOnionProxyPage();
        case LoginPage.routeName:
          return LoginPage();
        case IntroPage.routeName:
          return IntroPage();
        case AboutPage.routeName:
          return AboutPage();
        case SettingsPage.routeName:
          return SettingsPage();
        case BookPage.routeName:
          return BookPage(bookId: settings.arguments);
        case AuthorPage.routeName:
          return AuthorPage(authorId: settings.arguments);
        case SequencePage.routeName:
          return SequencePage(sequenceId: settings.arguments);
        case AdvancedSearchPage.routeName:
          return AdvancedSearchPage(advancedSearchParams: settings.arguments);
        case SequencePage.routeName:
          return SequencePage(sequenceId: settings.arguments);
        case FavoritesPage.routeName:
          return FavoritesPage(favoritesType: settings.arguments);
        default:
          print('undefined route');
      }
      return HomePage();
    },
  );
}
