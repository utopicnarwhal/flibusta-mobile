import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flibusta/blocs/home_grid/bloc.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeGridEvent extends Equatable {
  HomeGridEvent([List props = const []]);

  @override
  List<Object> get props => props;

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
      var searchResults = await _homeGridRepository
          .bookSearch(searchQuery ?? currentState.searchQuery);
      if (searchResults == null) {
        throw Exception('searchResults == null');
      }
      return GlobalSearchResultsState(
          latestBooks: currentState.latestBooks,
          searchResults: searchResults,
          searchQuery: searchQuery);
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
    } on DioError catch (dioError) {
      var errorMessage = '';
      switch (dioError.type) {
        case DioErrorType.CONNECT_TIMEOUT:
          errorMessage = 'Время ожидания подключения к серверу истекло';
          break;
        case DioErrorType.SEND_TIMEOUT:
          errorMessage = 'Время ожидания подключения к серверу истекло';
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorMessage = 'Время ожидания ответа от сервера истекло';
          break;
        case DioErrorType.CANCEL:
          errorMessage = 'Запрос отменён';
          break;
        case DioErrorType.RESPONSE:
        case DioErrorType.DEFAULT:
          if (dioError.response?.statusCode == 502) {
            errorMessage = '''Сайт flibusta.is не работает. Попробуйте зайти в приложение позже или воспользуйтесь кнопкой "Перейти на сайт" ниже.''';
          }
          else if (dioError.error is SocketException) {
            errorMessage = '''Время ожидания подключения к серверу истекло.
Возможные проблемы:
1. Нет подключения к интернету
2. Выбранный прокси сервер не работает, поменяйте на работающий в настройках прокси
3. Сайт flibusta.is не работает
''';
          } else {
            errorMessage = dioError.message;
          }
      }
      return LatestBooksErrorHomeGridState(
        errorMessage: errorMessage,
        latestBooks: currentState.latestBooks,
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

class AdvancedSearchEvent extends HomeGridEvent {
  @override
  String toString() => 'AdvancedSearchEvent';

  final AdvancedSearchParams advancedSearchParams;

  AdvancedSearchEvent({this.advancedSearchParams});

  @override
  Future<HomeGridState> applyAsync(
      {HomeGridState currentState, HomeGridBloc bloc}) async {
    try {
      var searchResultsBooks = await _homeGridRepository.makeBookList(
          advancedSearchParams:
              advancedSearchParams ?? currentState.advancedSearchParams);
      return AdvancedSearchResultsState(
        latestBooks: currentState.latestBooks,
        searchResults: SearchResults(books: searchResultsBooks),
        searchQuery: currentState.searchQuery,
        advancedSearchParams:
            advancedSearchParams ?? currentState.advancedSearchParams,
      );
    } catch (e) {
      return AdvancedSearchErrorHomeGridState(
        errorMessage: this.toString() + ' error: ' + e.toString(),
        latestBooks: currentState.latestBooks,
        searchResults: currentState.searchResults,
        searchQuery: currentState.searchQuery,
        advancedSearchParams:
            advancedSearchParams ?? currentState.advancedSearchParams,
      );
    }
  }
}
