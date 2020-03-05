import 'package:flibusta/blocs/grid/grid_data/components/grid_tiles_builder.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_state.dart';
import 'package:flibusta/utils/toast_utils.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:flutter_bloc/flutter_bloc.dart';

class GridDataScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GridDataBloc gridDataBloc;

  const GridDataScreen({
    Key key,
    @required this.scaffoldKey,
    @required this.gridDataBloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GridDataBloc>.value(
      value: gridDataBloc,
      child: BlocListener(
        bloc: gridDataBloc,
        listener: (BuildContext context, GridDataState gridDataState) {
          if (gridDataState?.message?.isEmpty != false) {
            return;
          }
          var toastType = ToastType.notification;
          if (gridDataState.stateCode == GridDataStateCode.Error) {
            toastType = ToastType.error;
          } else {
            toastType = ToastType.success;
          }
          ToastUtils.showToast(
            gridDataState.message,
            type: toastType,
          );
        },
        child: BlocBuilder(
          bloc: gridDataBloc,
          builder: (BuildContext context, GridDataState gridDataState) {
            return GridTilesBuilder(
              gridViewType: gridDataBloc.gridViewType,
              gridDataState: gridDataState,
            );
          },
        ),
      ),
    );
  }
}
