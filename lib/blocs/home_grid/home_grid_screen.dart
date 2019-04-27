import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/components/grid_cards.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flutter/material.dart';

class HomeGridScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final HomeGridState homeGridState;
  final TabController tabController;

  HomeGridScreen(
      {this.homeGridState, this.scaffoldKey, @required this.tabController});

  @override
  Widget build(BuildContext context) {
    if (homeGridState is ErrorHomeGridState) {
      return Center(
        child: Text('Ошибка ${homeGridState.toString()}'),
      );
    }

    if (homeGridState is LoadingHomeGridState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (homeGridState is LatestBooksState) {
      if (homeGridState is LatestBooksErrorHomeGridState) {
        return Center(
          child: Text('Ошибка ${homeGridState.toString()}'),
        );
      }
      return GridCards(
        scaffoldKey: scaffoldKey,
        data: homeGridState.latestBooks,
      );
    }

    if (homeGridState is GlobalSearchResultsState) {
      return TabBarView(
        controller: tabController,
        children: <Widget>[
          GridCards<BookCard>(
            scaffoldKey: scaffoldKey,
            data: homeGridState.searchResults.books,
          ),
          GridCards<AuthorCard>(
            scaffoldKey: scaffoldKey,
            data: homeGridState.searchResults.authors,
          ),
          GridCards<SequenceCard>(
            scaffoldKey: scaffoldKey,
            data: homeGridState.searchResults.sequences,
          ),
        ],
      );
    }
    return Placeholder();
  }
}
