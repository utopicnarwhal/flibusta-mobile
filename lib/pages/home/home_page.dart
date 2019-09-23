import 'dart:async';

import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/intro.dart';
import 'package:flibusta/pages/home/books.dart';
import 'package:flibusta/pages/home/proxy_settings/proxy_settings_page.dart';
import 'package:flibusta/pages/home/settings/settings_page.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  static const routeName = "/Home";

  @override
  createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeGridBloc _homeGridBloc = HomeGridBloc();
  StreamController<int> _selectedNavItemController = StreamController<int>();

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeGridBloc>(
      builder: (context) => _homeGridBloc,
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
                selectedNavItemController: _selectedNavItemController,
              );
            case 1:
              return ProxySettingsPage(
                selectedNavItemController: _selectedNavItemController,
              );
            case 2:
              return SettingsPage(
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
    _homeGridBloc?.dispose();
    _selectedNavItemController?.close();
    super.dispose();
  }
}