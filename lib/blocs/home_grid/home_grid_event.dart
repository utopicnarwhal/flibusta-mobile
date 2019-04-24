import 'package:equatable/equatable.dart';
import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeGridEvent extends Equatable {
  HomeGridEvent([List props = const []]) : super(props);

  Future<HomeGridState> applyAsync({HomeGridState currentState, HomeGridBloc bloc});

  final HomeGridRepository _homeGridRepository = HomeGridRepository();
}

class FetchBooks extends HomeGridEvent {
  final String searchQuery;

  FetchBooks(this.searchQuery);

  @override
  String toString() => 'FetchBooks';

  @override
  Future<HomeGridState> applyAsync({HomeGridState currentState, HomeGridBloc bloc}) async {
    try {
      var searchResults = await _homeGridRepository.bookSearch(searchQuery);
      return InHomeGridState(searchResults, searchQuery);
    } catch (e) {
      print(this.toString() + ' error: ' + e);
    }
    return UnHomeGridState(currentState.searchResults, currentState.searchQuery);
  }
}
