import 'dart:async';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:rxdart/rxdart.dart';

class SelectedViewTypeBloc {
  var _selectedViewTypeController = BehaviorSubject<GridViewType>();

  Stream<GridViewType> get stream => _selectedViewTypeController.stream;
  Sink<GridViewType> get _sink => _selectedViewTypeController.sink;

  changeViewType(GridViewType selectedViewType) {
    if (selectedViewType == null || selectedViewType == _selectedViewTypeController.valueOrNull) {
      return;
    }
    _sink.add(selectedViewType);
  }

  GridViewType get currentViewType {
    return _selectedViewTypeController.valueOrNull;
  }

  close() {
    _selectedViewTypeController.close();
  }
}
