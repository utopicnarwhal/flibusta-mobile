import 'package:equatable/equatable.dart';
import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeGridEvent extends Equatable {
  HomeGridEvent([List props = const []]) : super(props);

  Future<HomeGridState> applyAsync(
      {HomeGridState currentState, HomeGridBloc bloc});

  final HomeGridRepository _homeGridRepository = HomeGridRepository();
}

class GlobalSearchEvent extends HomeGridEvent {
  final String searchQuery;

  GlobalSearchEvent(this.searchQuery);

  @override
  String toString() => 'GlobalSearchEvent';

  @override
  Future<HomeGridState> applyAsync(
      {HomeGridState currentState, HomeGridBloc bloc}) async {
    try {
      var searchResults = await _homeGridRepository.bookSearch(searchQuery ?? currentState.searchQuery);
      if (searchResults == null) {
        throw Exception('searchResults == null');
      }
      return GlobalSearchResultsState(latestBooks: currentState.latestBooks, searchResults: searchResults, searchQuery: searchQuery);
    } catch (e) {
      return GlobalSearchErrorHomeGridState(
        errorMessage: this.toString() + ' error: ' + e.toString(),
        latestBooks: currentState.latestBooks,
        searchResults: currentState.searchResults,
        searchQuery: currentState.searchQuery,
      );
    }
  }
}

class GetLatestBooksEvent extends HomeGridEvent {
  @override
  String toString() => 'GetLatestBooksEvent';

  @override
  Future<HomeGridState> applyAsync(
      {HomeGridState currentState, HomeGridBloc bloc}) async {
    try {
      var latestBooks = await _homeGridRepository.makeBookList();
      return LatestBooksState(
        latestBooks: latestBooks,
        searchResults: currentState.searchResults,
        searchQuery: currentState.searchQuery,
      );
    } catch (e) {
      return LatestBooksErrorHomeGridState(
        errorMessage: this.toString() + ' error: ' + e.toString(),
        latestBooks: currentState.latestBooks,
        searchResults: currentState.searchResults,
        searchQuery: currentState.searchQuery,
      );
    }
  }
}
