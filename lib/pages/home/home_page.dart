import 'package:flibusta/blocs/genres_list/genres_list_bloc.dart';
import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/intro.dart';
import 'package:flibusta/pages/home/views/downloaded_books/downloaded_books.dart';
import 'package:flibusta/pages/home/views/genres/genres.dart';
import 'package:flibusta/pages/home/views/profile_view/profile_view.dart';
import 'package:flibusta/pages/home/views/proxy_settings/proxy_settings_page.dart';
import 'package:flibusta/pages/home/views/recent_books/books.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/Home";

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeGridBloc _homeGridBloc = HomeGridBloc();
  BehaviorSubject<int> _selectedNavItemController = BehaviorSubject<int>();
  GenresListBloc _genresListBloc = GenresListBloc();
  BehaviorSubject<List<String>> _favoriteGenreCodesController = BehaviorSubject<List<String>>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    if (!await LocalStorage().getIntroCompleted()) {
      Navigator.of(context).pushReplacementNamed(IntroPage.routeName);
    }
    _homeGridBloc.getLatestBooks();

    var favoriteGenreCodes = await LocalStorage().getfavoriteGenreCodes();
    _favoriteGenreCodesController.add(favoriteGenreCodes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeGridBloc>(
      create: (context) => _homeGridBloc,
      child: StreamBuilder<int>(
        initialData: 0,
        stream: _selectedNavItemController.stream,
        builder: (context, selectedNavigationItemSnapshot) {
          if (!selectedNavigationItemSnapshot.hasData) {
            return Container();
          }

          switch (selectedNavigationItemSnapshot.data) {
            case 0:
              return BooksPage(
                scaffoldKey: _scaffoldKey,
                selectedNavItemController: _selectedNavItemController,
              );
            case 1:
              return GenresView(
                scaffoldKey: _scaffoldKey,
                genresListBloc: _genresListBloc,
                selectedNavItemController: _selectedNavItemController,
                favoriteGenreCodesController: _favoriteGenreCodesController,
              );
              break;
            case 2:
              return DownloadedBooksView(
                scaffoldKey: _scaffoldKey,
                selectedNavItemController: _selectedNavItemController,
              );
              break;
            case 3:
              return ProxySettingsPage(
                scaffoldKey: _scaffoldKey,
                selectedNavItemController: _selectedNavItemController,
              );
            case 4:
              return ProfileView(
                scaffoldKey: _scaffoldKey,
                selectedNavItemController: _selectedNavItemController,
              );
            default:
          }
          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _homeGridBloc?.close();
    _selectedNavItemController?.close();
    _genresListBloc?.dispose();
    _favoriteGenreCodesController?.close();
    super.dispose();
  }
}
