import 'package:equatable/equatable.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeGridState extends Equatable {
  final List<BookCard> latestBooks;
  final String searchQuery;
  final AdvancedSearchParams advancedSearchParams;
  final SearchResults searchResults;
  final message;

  HomeGridState({
    this.message,
    this.latestBooks,
    this.searchResults,
    this.searchQuery,
    this.advancedSearchParams,
  });

  @override
  List<Object> get props => [searchResults];
}

class LatestBooksState extends HomeGridState {
  LatestBooksState({
    message,
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          message: message,
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'LatestBooksState';
}

class GlobalSearchResultsState extends HomeGridState {
  GlobalSearchResultsState({
    message,
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          message: message,
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'GlobalSearchResultsState';
}

class AdvancedSearchResultsState extends HomeGridState {
  AdvancedSearchResultsState({
    message,
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          message: message,
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'GlobalSearchResultsState';
}

class UnHomeGridState extends HomeGridState {
  UnHomeGridState({
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'UnHomeGridState';
}

class LoadingHomeGridState extends HomeGridState {
  LoadingHomeGridState({
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'LoadingHomeGridState';
}

class GlobalSearchErrorHomeGridState extends GlobalSearchResultsState {
  final String errorMessage;

  GlobalSearchErrorHomeGridState({
    this.errorMessage,
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          message: errorMessage,
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
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
    advancedSearchParams,
  }) : super(
          message: errorMessage,
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'LatestBooksErrorHomeGridState $errorMessage';
}

class AdvancedSearchErrorHomeGridState extends AdvancedSearchResultsState {
  final String errorMessage;

  AdvancedSearchErrorHomeGridState({
    this.errorMessage,
    latestBooks,
    searchResults,
    searchQuery,
    advancedSearchParams,
  }) : super(
          message: errorMessage,
          latestBooks: latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery,
          advancedSearchParams: advancedSearchParams,
        );

  @override
  String toString() => 'AdvancedSearchErrorHomeGridState';
}
