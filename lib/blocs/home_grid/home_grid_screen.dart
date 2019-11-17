import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/blocs/home_grid/components/grid_cards.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeGridScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final HomeGridBloc _homeGridBloc;
  final TabController _tabController;

  HomeGridScreen({
    homeGridBloc,
    scaffoldKey,
    @required tabController,
  })  : _scaffoldKey = scaffoldKey,
        _homeGridBloc = homeGridBloc,
        _tabController = tabController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.microtask(() {
          if (_homeGridBloc.state is LatestBooksState) {
            _homeGridBloc.getLatestBooks();
          }
          if (_homeGridBloc.state is GlobalSearchResultsState) {
            _homeGridBloc.globalSearch();
          }
        });
      },
      child: BlocBuilder(
        bloc: _homeGridBloc,
        builder: (BuildContext context, HomeGridState _homeGridState) {
          if (_homeGridState is LatestBooksErrorHomeGridState ||
              _homeGridState is GlobalSearchErrorHomeGridState ||
              _homeGridState is AdvancedSearchErrorHomeGridState) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Ошибка.\n${_homeGridState.message}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  RaisedButton(
                    child: Text('Попробовать ещё раз'),
                    onPressed: () {
                      if (_homeGridState is LatestBooksErrorHomeGridState)
                        _homeGridBloc.getLatestBooks();
                      if (_homeGridState is GlobalSearchErrorHomeGridState)
                        _homeGridBloc.globalSearch();
                      if (_homeGridState is AdvancedSearchErrorHomeGridState)
                        _homeGridBloc.advancedSearch();
                    },
                  ),
                  RaisedButton(
                    child: Text('Перейти на сайт'),
                    onPressed: () async {
                      await launch('https://flibusta.appspot.com');
                    },
                  ),
                ],
              ),
            );
          }

          if (_homeGridState is LoadingHomeGridState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_homeGridState is LatestBooksState) {
            return GridCards(
              scaffoldKey: _scaffoldKey,
              data: _homeGridState.latestBooks,
            );
          }

          if (_homeGridState is GlobalSearchResultsState &&
              _homeGridState.searchResults != null) {
            return TabBarView(
              controller: _tabController,
              children: <Widget>[
                GridCards<BookCard>(
                  scaffoldKey: _scaffoldKey,
                  data: _homeGridState.searchResults.books,
                ),
                GridCards<AuthorCard>(
                  scaffoldKey: _scaffoldKey,
                  data: _homeGridState.searchResults.authors,
                ),
                GridCards<SequenceCard>(
                  scaffoldKey: _scaffoldKey,
                  data: _homeGridState.searchResults.sequences,
                ),
              ],
            );
          }

          if (_homeGridState is AdvancedSearchResultsState) {
            return GridCards(
              scaffoldKey: _scaffoldKey,
              data: _homeGridState.searchResults.books,
            );
          }

          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Ошибка ${_homeGridState.toString()}',
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  child: Text('Попробовать ещё раз'),
                  onPressed: () {
                    if (_homeGridState is LatestBooksErrorHomeGridState)
                      _homeGridBloc.getLatestBooks();
                    if (_homeGridState is GlobalSearchErrorHomeGridState)
                      _homeGridBloc.globalSearch();
                    if (_homeGridState is AdvancedSearchErrorHomeGridState)
                      _homeGridBloc.advancedSearch();
                  },
                ),
                RaisedButton(
                  child: Text('Перейти на сайт'),
                  onPressed: () async {
                    await launch('https://flibusta.appspot.com');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
