import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import './bloc.dart';

class HomeGridBloc extends Bloc<HomeGridEvent, HomeGridState> {
  @override
  HomeGridState get initialState => UnHomeGridState();

  /// If searchQuery == null then repeat revious query
  void globalSearch({String searchQuery}) {
    this.add(GlobalSearchEvent(searchQuery));
  }

  void getLatestBooks() {
    this.add(GetLatestBooksEvent());
  }

  void advancedSearch({AdvancedSearchParams advancedSearchParams}) {
    this.add(AdvancedSearchEvent(advancedSearchParams: advancedSearchParams));
  }

  @override
  Stream<HomeGridState> mapEventToState(
    HomeGridEvent event,
  ) async* {
    yield LoadingHomeGridState(
      latestBooks: state.latestBooks,
      searchResults: state.searchResults,
      searchQuery: state.searchQuery,
    );
    yield await event.applyAsync(currentState: state, bloc: this);
  }
}
