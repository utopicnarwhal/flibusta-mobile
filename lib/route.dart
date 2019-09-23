import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flutter/material.dart';
import './pages/home/home_page.dart';
import './pages/login/login_page.dart';
import './pages/profile/profile_page.dart';
import './pages/help/help_page.dart';
import './intro.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
    case HomePage.routeName:
      return MaterialPageRoute(builder: (context) => HomePage());
    case Profile.routeName:
      return MaterialPageRoute(builder: (context) => Profile());
    case Login.routeName:
      return MaterialPageRoute(builder: (context) => Login());
    case IntroPage.routeName:
      return MaterialPageRoute(builder: (context) => IntroPage());
    case Help.routeName:
      return MaterialPageRoute(builder: (context) => Help());
    case BookPage.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => BookPage(bookId: settings.arguments),
      );
    case AuthorPage.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => AuthorPage(authorId: settings.arguments),
      );
    case SequencePage.routeName:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => SequencePage(sequenceId: settings.arguments),
      );
    default:
      return MaterialPageRoute(builder: (context) => HomePage());
  }
}
