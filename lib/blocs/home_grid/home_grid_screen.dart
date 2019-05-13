import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/components/grid_cards.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          if (_homeGridBloc.currentState is LatestBooksState) {
            _homeGridBloc.getLatestBooks();
          }
          if (_homeGridBloc.currentState is GlobalSearchResultsState) {
            _homeGridBloc.globalSearch();
          }
        });
      },
      child: BlocBuilder(
        bloc: _homeGridBloc,
        builder: (BuildContext context, HomeGridState _homeGridState) {
          if (_homeGridState is LatestBooksErrorHomeGridState ||
              _homeGridState is GlobalSearchErrorHomeGridState) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Ошибка $_homeGridState',
                    textAlign: TextAlign.center,
                  ),
                  RaisedButton(
                    child: Text('Попробовать ещё раз'),
                    onPressed: () => _homeGridBloc.getLatestBooks(),
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
            if (_homeGridState is LatestBooksErrorHomeGridState) {
              return Center(
                child: Text('Ошибка ${_homeGridState.toString()}'),
              );
            }
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
          return Center(
            child: Text('Ошибка ${_homeGridState.toString()}'),
          );
        },
      ),
    );
  }
}
