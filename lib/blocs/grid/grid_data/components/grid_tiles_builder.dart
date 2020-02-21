import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/blocs/grid/grid_data/components/first_grid_tile.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_state.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GridTilesBuilder extends StatefulWidget {
  final GridDataState gridDataState;
  final String errorMessage;

  const GridTilesBuilder({
    Key key,
    @required this.gridDataState,
  })  : errorMessage = null,
        super(key: key);

  const GridTilesBuilder.shimmer({Key key})
      : gridDataState = null,
        errorMessage = null,
        super(key: key);

  @override
  _GridTilesBuilderState createState() => _GridTilesBuilderState();
}

class _GridTilesBuilderState extends State<GridTilesBuilder> {
  bool uploadingMore = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var gridDataState = widget.gridDataState;
    List<GridData> gridData;

    gridData = gridDataState?.gridData;
    uploadingMore = gridDataState?.uploadingMore;

    Widget gridListView;

    int shimmerListCount = (MediaQuery.of(context).size.height / 110).round();

    if ((gridDataState?.stateCode == GridDataStateCode.Normal ||
            gridDataState?.stateCode == GridDataStateCode.Error) &&
        gridData?.isEmpty == true) {
      gridListView = FirstGridTile(
        isFirst: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 230,
              width: 300,
              child: FlareActor(
                'assets/animations/empty_state.flr',
                alignment: Alignment.topCenter,
                fit: BoxFit.contain,
                animation: 'idle',
                color: Theme.of(context).textTheme.body1.color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                gridDataState.searchString?.isEmpty == false
                    ? 'По вашему запросу\nничего не найдено'
                    : 'Пока тут пусто',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (gridDataState?.stateCode == GridDataStateCode.Error &&
        gridData == null) {
      gridListView = FirstGridTile(
        isFirst: true,
        child: Center(
          heightFactor: 7,
          child: DsOutlineButton(
            child: Text('Повторить'),
            onPressed: () =>
                BlocProvider.of<GridDataBloc>(context)?.refreshGridData(),
          ),
        ),
      );
    } else if (gridDataState?.stateCode == GridDataStateCode.Loading) {
      gridListView = ShimmerLeadList(
        listCount: shimmerListCount,
        hasFirst: true,
      );
    } else if (gridData != null && widget.selectedleadIds != null) {
      gridListView = ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        addSemanticIndexes: false,
        itemBuilder: (context, index) {
          if (index == gridData.length) {
            return Column(
              children: <Widget>[
                Divider(indent: 80),
                ShimmerLeadList(
                  listCount: 1,
                  hasFirst: false,
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GridDataTile(
                index: index,
                isFirst: index == 0,
                isLast: index == gridData.length - 1,
                onTap: () async {
                  
                },
                onLongPress: () {
                  
                },
              ),
            ],
          );
        },
        itemCount: uploadingMore ? (gridData.length + 1) : gridData.length,
      );
    } else {
      gridListView = ShimmerLeadList(
        listCount: shimmerListCount,
        hasFirst: true,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            BlocProvider.of<GridDataBloc>(context).refreshGridData();
          } on FlutterError catch (_) {}
        },
        child: ListFadeInSlideStagger(
          index: 0,
          child: CustomScrollView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    color: Theme.of(context).cardColor,
                    child: gridListView,
                  ),
                ]),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Container(
                  color: Theme.of(context).cardColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    var gridDataState = widget.gridDataState;

    if (gridDataState?.hasReachedMax != false ||
        uploadingMore ||
        gridDataState?.gridData?.isEmpty != false) {
      return false;
    }
    double maxScroll = notification.metrics.maxScrollExtent;
    double currentScroll = notification.metrics.pixels;
    bool isScrollingDown =
        notification.metrics.axisDirection == AxisDirection.down;
    double delta = 100.0;
    if ((gridDataState?.stateCode == GridDataStateCode.Normal ||
            gridDataState?.stateCode == GridDataStateCode.Error) &&
        isScrollingDown &&
        maxScroll - currentScroll <= delta) {
      uploadingMore = true;

      BlocProvider.of<GridDataBloc>(context).uploadMore(
        ((gridDataState.gridData?.length ?? 0) ~/ HomeGridConsts.kPageSize) + 1,
      );
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
