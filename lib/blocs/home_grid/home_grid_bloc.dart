import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class HomeGridBloc extends Bloc<HomeGridEvent, HomeGridState> {
  @override
  HomeGridState get initialState => UnHomeGridState(null, null);

  void searchAllByQuery(String searchQuery) {
    this.dispatch(FetchBooks(searchQuery));
  }

  @override
  Stream<HomeGridState> mapEventToState(
    HomeGridEvent event,
  ) async* {
    yield LoadingHomeGridState(currentState.searchResults, currentState.searchQuery);
    if (event is FetchBooks) {
      yield await event.applyAsync(currentState: currentState, bloc: this);
    }
  }
}
