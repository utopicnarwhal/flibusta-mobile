import 'dart:async';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_repository.dart';
import 'package:flibusta/constants.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GridDataEvent {
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc});

  final GridDataRepository _gridDataRepository = new GridDataRepository();
}

class LoadGridDataEvent extends GridDataEvent {
  @override
  String toString() => 'LoadGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      var _gridData = await this._gridDataRepository.getGridData(
          bloc.userViewTypeNum, 1,
          searchString: currentState?.searchString);
      var hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
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

class SearchGridDataEvent extends GridDataEvent {
  final String searchString;

  SearchGridDataEvent(this.searchString);
  @override
  String toString() => 'SearchGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      var _gridData = await this
          ._gridDataRepository
          .getGridData(bloc.userViewTypeNum, 1, searchString: searchString);
      var hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        searchString: searchString,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
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

class RefreshGridDataEvent extends GridDataEvent {
  RefreshGridDataEvent();

  @override
  String toString() => 'RefreshGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      var _gridData = await this._gridDataRepository.getGridData(
          bloc.userViewTypeNum, 1,
          searchString: currentState?.searchString);
      var hasReachedMax = (_gridData?.length ?? 0) < HomeGridConsts.kPageSize;

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: 1,
        hasReachedMax: hasReachedMax,
        gridData: _gridData,
        uploadingMore: false,
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

class UploadMoreGridDataEvent extends GridDataEvent {
  final int pageNumber;

  UploadMoreGridDataEvent(this.pageNumber);

  @override
  String toString() => 'UploadMoreGridDataEvent';

  @override
  Future<GridDataState> applyAsync(
      {GridDataState currentState, GridDataBloc bloc}) async {
    try {
      var gridData = await this._gridDataRepository.getGridData(
          bloc.userViewTypeNum, pageNumber,
          searchString: currentState?.searchString);
      var hasReachedMax = (gridData?.length ?? 0) < HomeGridConsts.kPageSize;
      if (currentState.uploadingMore == true) {
        gridData = [...currentState.gridData, ...gridData];
      }

      return currentState.copyWith(
        stateCode: GridDataStateCode.Normal,
        page: pageNumber,
        hasReachedMax: hasReachedMax,
        gridData: gridData,
        uploadingMore: false,
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