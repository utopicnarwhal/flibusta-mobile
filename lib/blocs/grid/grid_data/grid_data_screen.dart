part of 'grid_data_bloc.dart';

class GridDataScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GridDataBloc gridDataBloc;
  final TextEditingController searchTextController;
  final BehaviorSubject<List<String>> favoriteGenreCodesController;

  const GridDataScreen({
    Key key,
    @required this.scaffoldKey,
    @required this.gridDataBloc,
    @required this.searchTextController,
    @required this.favoriteGenreCodesController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GridDataBloc>.value(
      value: gridDataBloc,
      child: BlocListener<GridDataBloc, GridDataState>(
        bloc: gridDataBloc,
        listener: (context, gridDataState) {
          if (gridDataState?.message?.isEmpty != false) {
            return;
          }
          var toastType = ToastType.notification;
          if (gridDataState.stateCode == GridDataStateCode.Error) {
            toastType = ToastType.error;
          } else {
            toastType = ToastType.success;
          }
          ToastManager().showToast(
            gridDataState.message,
            type: toastType,
          );
        },
        child: BlocBuilder<GridDataBloc, GridDataState>(
          bloc: gridDataBloc,
          builder: (context, gridDataState) {
            return GridTilesBuilder(
              gridViewType: gridDataBloc.gridViewType,
              gridDataState: gridDataState,
              searchTextController: searchTextController,
              favoriteGenreCodesController: favoriteGenreCodesController,
            );
          },
        ),
      ),
    );
  }
}
