import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import './bloc.dart';

class HomeGridBloc extends Bloc<HomeGridEvent, HomeGridState> {
  @override
  HomeGridState get initialState => UnHomeGridState();

  /// If searchQuery == null then repeat revious query
  void globalSearch({String searchQuery}) {
    this.dispatch(GlobalSearchEvent(searchQuery));
  }

  void getLatestBooks() {
    this.dispatch(GetLatestBooksEvent());
  }

  void advancedSearch({AdvancedSearchParams advancedSearchParams}) {
    this.dispatch(AdvancedSearchEvent(advancedSearchParams: advancedSearchParams));
  }

  @override
  Stream<HomeGridState> mapEventToState(
    HomeGridEvent event,
  ) async* {
    yield LoadingHomeGridState(
      latestBooks: currentState.latestBooks,
      searchResults: currentState.searchResults,
      searchQuery: currentState.searchQuery,
    );
    yield await event.applyAsync(currentState: currentState, bloc: this);
  }
}
