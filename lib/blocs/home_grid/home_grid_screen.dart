import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/components/grid_book_card.dart';
import 'package:flutter/material.dart';

class HomeGridScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final HomeGridState homeGridState;

  HomeGridScreen({this.homeGridState, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    if (homeGridState is LoadingHomeGridState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (homeGridState is GlobalSearchResultsState) {
      return GridBookCard(
        data: homeGridState.searchResults.books,
      );
    }

    if (homeGridState is LatestBooksState) {
      return GridBookCard(
        data: homeGridState.latestBooks,
      );
    }

    if (homeGridState is ErrorHomeGridState) {
      return Center(
        child: Text('Ошибка ${homeGridState.toString()}'),
      );
    }
    return Placeholder();
  }
}
