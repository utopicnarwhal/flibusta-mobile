import 'package:equatable/equatable.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeGridState extends Equatable {
  final List<BookCard> latestBooks;
  final String searchQuery;
  final SearchResults searchResults;

  HomeGridState({
    this.latestBooks,
    this.searchResults,
    this.searchQuery,
  }) : super([searchResults]);
}

class LatestBooksState extends HomeGridState {
  LatestBooksState({
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'LatestBooksState';
}

class GlobalSearchResultsState extends HomeGridState {
  GlobalSearchResultsState({
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'GlobalSearchResultsState';
}

class UnHomeGridState extends HomeGridState {
  UnHomeGridState({
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'UnHomeGridState';
}

class LoadingHomeGridState extends HomeGridState {
  LoadingHomeGridState({
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'LoadingHomeGridState';
}

class ErrorHomeGridState extends HomeGridState {
  final String errorMessage;

  ErrorHomeGridState({
    this.errorMessage,
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'ErrorHomeGridState';
}

class GlobalSearchErrorHomeGridState extends GlobalSearchResultsState {
  final String errorMessage;

  GlobalSearchErrorHomeGridState({
    this.errorMessage,
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'GlobalSearchErrorHomeGridState';
}

class LatestBooksErrorHomeGridState extends LatestBooksState {
  final String errorMessage;

  LatestBooksErrorHomeGridState({
    this.errorMessage,
    latestBooks,
    searchResults,
    searchQuery,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
        );

  @override
  String toString() => 'LatestBooksErrorHomeGridState $errorMessage';
}

// class AdvancedSearchErrorHomeGridState extends ErrorHomeGridState {
//   final String errorMessage;

//   AdvancedSearchErrorHomeGridState({
//     this.errorMessage,
//     latestBooks,
//     searchResults,
//     searchQuery,
//   }) : super(
//           latestBooks: latestBooks,
//           searchResults: searchResults,
//           searchQuery: searchQuery,
//         );

//   @override
//   String toString() => 'AdvancedSearchErrorHomeGridState';
// }
