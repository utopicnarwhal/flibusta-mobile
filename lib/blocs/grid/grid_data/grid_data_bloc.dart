import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/model/enums/gridViewType.dart';

class GridDataBloc extends Bloc<GridDataEvent, GridDataState> {
  final GridViewType gridViewType;

  GridDataBloc(this.gridViewType);

  @override
  GridDataState get initialState => GridDataState(
        searchString: null,
        page: 1,
        hasReachedMax: false,
        gridData: null,
        uploadingMore: false,
        message: null,
        stateCode: GridDataStateCode.Empty,
      );

  void fetchGridData() {
    this.add(LoadGridDataEvent());
  }

  void searchByString(String searchString) {
    this.add(SearchGridDataEvent(searchString));
  }

  void refreshGridData() {
    this.add(RefreshGridDataEvent());
  }

  void uploadMore(int nextPageNumber) {
    this.add(UploadMoreGridDataEvent(nextPageNumber));
  }

  @override
  Stream<GridDataState> mapEventToState(GridDataEvent event) async* {
    try {
      var searchString = state?.searchString;
      if (event is SearchGridDataEvent) {
        searchString = event.searchString;
      }
      if (event is UploadMoreGridDataEvent) {
        if (state?.stateCode == GridDataStateCode.Normal ||
            state?.stateCode == GridDataStateCode.Error) {
          yield state.copyWith(
            uploadingMore: true,
            message: '',
          );
        }
      } else {
        yield state.copyWith(
          searchString: searchString,
          page: state?.page ?? 1,
          hasReachedMax: state?.hasReachedMax ?? false,
          stateCode: GridDataStateCode.Loading,
          message: '',
        );
      }

      yield await event.applyAsync(currentState: state, bloc: this);
    } catch (e) {
      yield state.copyWith(
        stateCode: GridDataStateCode.Error,
        searchString: state.searchString ?? null,
        page: state?.page ?? 1,
        hasReachedMax: state?.hasReachedMax ?? false,
        message: e.toString(),
      );
    }
  }
}
