import 'package:equatable/equatable.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeGridState extends Equatable {
  final String searchQuery;
  final SearchResults searchResults;

  HomeGridState(this.searchResults, this.searchQuery, [List props = const []])
      : super(props);
}

class InHomeGridState extends HomeGridState {
  InHomeGridState(SearchResults searchResults, String searchQuery)
      : super(searchResults, searchQuery);

  @override
  String toString() => 'InHomeGridState';
}

class UnHomeGridState extends HomeGridState {
  UnHomeGridState(SearchResults searchResults, String searchQuery)
      : super(searchResults, searchQuery);

  @override
  String toString() => 'UnHomeGridState';
}

class LoadingHomeGridState extends HomeGridState {
  LoadingHomeGridState(SearchResults searchResults, String searchQuery)
      : super(searchResults, searchQuery);

  @override
  String toString() => 'LoadingHomeGridState';
}
