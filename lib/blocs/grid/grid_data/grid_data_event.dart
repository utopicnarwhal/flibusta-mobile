import 'dart:async';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_repository.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GridDataEvent {
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc});

  final GridDataRepository _gridDataRepository = GridDataRepository();
}

class LoadGridDataEvent extends GridDataEvent {
  final String searchString;
  final AdvancedSearchParams advancedSearchParams;

  LoadGridDataEvent({this.searchString, this.advancedSearchParams});

  @override
  String toString() => 'LoadGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      List<GridData> _gridData = [];
      String sequenceTitle;
      var hasReachedMax = true;
      var currentSearchString = searchString ?? currentState.searchString;

      switch (bloc.gridViewType) {
        case GridViewType.downloaded:
          _gridData = await _gridDataRepository.getDownloadedBooks(
            1,
            currentSearchString,
          );
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.newBooks:
          if (currentSearchString?.isNotEmpty == true) {
            var bookSearch = await _gridDataRepository.bookSearch(
              1,
              currentSearchString,
              isBookSearch: true,
            );
            _gridData = bookSearch.books;
            hasReachedMax = (_gridData?.length ?? 0) < 30;
          } else {
            _gridData = await _gridDataRepository.makeBookList(
              1,
            );
            hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
            if (_gridData.isEmpty == true) throw new DsError(userMessage: 'На что-то сломалось. Попробуйте зайти позже.');
          }
          break;
        case GridViewType.authors:
          if (currentSearchString?.isNotEmpty == true) {
            var bookSearch = await _gridDataRepository.bookSearch(
              1,
              currentSearchString,
              isAuthorSearch: true,
            );
            _gridData = bookSearch.authors;
            hasReachedMax = (_gridData?.length ?? 0) < 30;
          } else {
            _gridData = await _gridDataRepository.getAuthors(1);
            hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          }
          break;
        case GridViewType.genres:
          _gridData = await _gridDataRepository.getGenres(
            1,
            searchString: currentSearchString,
          );
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.suquence:
          var sequenceInfo =
              await _gridDataRepository.getSequence(bloc.sequenceId, 1);
          _gridData = sequenceInfo.books;
          sequenceTitle = sequenceInfo.title;
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.sequences:
          if (currentSearchString?.isNotEmpty == true) {
            var bookSearch = await _gridDataRepository.bookSearch(
              1,
              currentSearchString,
              isSequenceSearch: true,
            );
            _gridData = bookSearch.sequences;
            hasReachedMax = (_gridData?.length ?? 0) < 30;
          } else {
            _gridData = await _gridDataRepository.getSequences(1);
            hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          }
          break;
        case GridViewType.advancedSearch:
          var searchResult = await _gridDataRepository.makeBookList(
            1,
            advancedSearchParams: advancedSearchParams,
          );
          _gridData = searchResult;
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        default:
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
        sequenceTitle: sequenceTitle,
        message: '',
      );
    } on DsError catch (dsError) {
      return currentState.copyWith(
        stateCode: GridDataStateCode.Error,
        uploadingMore: false,
        message: dsError.toString(),
      );
    }
  }
}

class SearchGridDataEvent extends GridDataEvent {
  final String searchString;

  SearchGridDataEvent(this.searchString);
  @override
  String toString() => 'SearchGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      List<GridData> _gridData = [];
      String sequenceTitle;
      var hasReachedMax = true;

      switch (bloc.gridViewType) {
        case GridViewType.downloaded:
          _gridData = await _gridDataRepository.getDownloadedBooks(
            1,
            searchString,
          );
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.newBooks:
          var bookSearch = await _gridDataRepository.bookSearch(
            1,
            searchString,
            isBookSearch: true,
          );
          _gridData = bookSearch.books;
          hasReachedMax = (_gridData?.length ?? 0) < 30;
          break;
        case GridViewType.authors:
          var authorSearch = await _gridDataRepository.bookSearch(
            1,
            searchString,
            isAuthorSearch: true,
          );
          _gridData = authorSearch.authors;
          hasReachedMax = (_gridData?.length ?? 0) < 30;
          break;
        case GridViewType.genres:
          _gridData = await _gridDataRepository.getGenres(
            1,
            searchString: searchString,
          );
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.suquence:
          var sequenceInfo =
              await _gridDataRepository.getSequence(bloc.sequenceId, 1);
          _gridData = sequenceInfo.books;
          sequenceTitle = sequenceInfo.title;
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.sequences:
          var sequenceSearch = await _gridDataRepository.bookSearch(
            1,
            searchString,
            isSequenceSearch: true,
          );
          _gridData = sequenceSearch.sequences;
          hasReachedMax = (_gridData?.length ?? 0) < 30;
          break;
        default:
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        searchString: searchString,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
        sequenceTitle: sequenceTitle,
        message: '',
      );
    } catch (e) {
      return currentState.copyWith(
        stateCode: GridDataStateCode.Error,
        searchString: searchString,
        uploadingMore: false,
        message: e.toString(),
      );
    }
  }
}

class UploadMoreGridDataEvent extends GridDataEvent {
  final int pageNumber;
  final AdvancedSearchParams advancedSearchParams;

  UploadMoreGridDataEvent(this.pageNumber, [this.advancedSearchParams]);

  @override
  String toString() => 'UploadMoreGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      List<GridData> _gridData = [];
      var hasReachedMax = true;
      String sequenceTitle;

      switch (bloc.gridViewType) {
        case GridViewType.downloaded:
          _gridData = await _gridDataRepository.getDownloadedBooks(
            pageNumber,
            currentState.searchString,
          );
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.newBooks:
          if (currentState.searchString?.isNotEmpty == true) {
            var bookSearch = await _gridDataRepository.bookSearch(
              pageNumber,
              currentState.searchString,
              isBookSearch: true,
            );
            _gridData = bookSearch.books;
            hasReachedMax = (_gridData?.length ?? 0) < 30;
          } else {
            _gridData = await _gridDataRepository.makeBookList(
              pageNumber,
            );
            hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          }
          break;
        case GridViewType.authors:
          if (currentState.searchString?.isNotEmpty == true) {
            var bookSearch = await _gridDataRepository.bookSearch(
              pageNumber,
              currentState.searchString,
              isAuthorSearch: true,
            );
            _gridData = bookSearch.authors;
            hasReachedMax = (_gridData?.length ?? 0) < 30;
          } else {
            _gridData = await _gridDataRepository.getAuthors(pageNumber);
            hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          }
          break;
        case GridViewType.genres:
          _gridData = await _gridDataRepository.getGenres(
            pageNumber,
            searchString: currentState.searchString,
          );
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.suquence:
          var sequenceInfo = await _gridDataRepository.getSequence(
              bloc.sequenceId, pageNumber);
          _gridData = sequenceInfo.books;
          sequenceTitle = sequenceInfo.title;
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        case GridViewType.sequences:
          if (currentState.searchString?.isNotEmpty == true) {
            var bookSearch = await _gridDataRepository.bookSearch(
              pageNumber,
              currentState.searchString,
              isSequenceSearch: true,
            );
            _gridData = bookSearch.sequences;
            hasReachedMax = (_gridData?.length ?? 0) < 30;
          } else {
            _gridData = await _gridDataRepository.getSequences(pageNumber);
            hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          }
          break;
        case GridViewType.advancedSearch:
          var searchResult = await _gridDataRepository.makeBookList(
            pageNumber,
            advancedSearchParams: advancedSearchParams,
          );
          _gridData = searchResult;
          hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;
          break;
        default:
      }
      if (currentState.uploadingMore == true) {
        _gridData = [...currentState.gridData, ..._gridData];
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: pageNumber,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
        sequenceTitle: sequenceTitle,
        message: '',
      );
    } catch (e) {
      return currentState.copyWith(
        stateCode: GridDataStateCode.Error,
        uploadingMore: false,
        message: e.toString(),
      );
    }
  }
}
