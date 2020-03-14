import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/blocs/grid/grid_data/components/first_grid_tile.dart';
import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_state.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flibusta/ds_controls/ui/decor/shimmers.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GridTilesBuilder extends StatelessWidget {
  final GridDataState gridDataState;
  final String errorMessage;
  final GridViewType gridViewType;

  const GridTilesBuilder({
    Key key,
    @required this.gridDataState,
    @required this.gridViewType,
  })  : errorMessage = null,
        super(key: key);

  const GridTilesBuilder.shimmer({
    Key key,
    @required this.gridViewType,
  })  : gridDataState = null,
        errorMessage = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<GridData> gridData;

    gridData = gridDataState?.gridData;
    var uploadingMore = gridDataState?.uploadingMore;

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
                BlocProvider.of<GridDataBloc>(context)?.fetchGridData(),
          ),
        ),
      );
    } else if (gridDataState?.stateCode == GridDataStateCode.Loading) {
      gridListView = ShimmerGridTileBuilder(
        itemCount: shimmerListCount,
        gridViewType: gridViewType,
      );
    } else if (gridData != null) {
      gridListView = ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        addSemanticIndexes: false,
        itemCount: uploadingMore ? (gridData.length + 1) : gridData.length,
        itemBuilder: (context, index) {
          if (index == gridData.length) {
            return Column(
              children: <Widget>[
                Divider(indent: 80),
                ShimmerListTile(
                  index: index,
                  gridViewType: gridViewType,
                ),
              ],
            );
          }
          List<String> genresStrings;
          int score;
          if (gridData[index] is BookCard) {
            genresStrings =
                (gridData[index] as BookCard)?.genres?.list?.map((genre) {
              return genre.values?.first;
            })?.toList();
            score = (gridData[index] as BookCard)?.score;
          }

          return GridDataTile(
            index: index,
            isFirst: index == 0,
            isLast: index == gridData.length - 1,
            title: gridData[index].tileTitle,
            subtitle: gridData[index].tileSubtitle,
            genres: genresStrings,
            score: score,
            onTap: () {
              if (gridData[index] is BookCard) {
                Navigator.of(context).pushNamed(
                  BookPage.routeName,
                  arguments: gridData[index].id,
                );
                return;
              }
              if (gridData[index] is AuthorCard) {
                // Navigator.of(context).pushNamed(
                //   AuthorPage.routeName,
                //   arguments: gridData[index].id,
                // );
                return;
              }
              if (gridData[index] is SequenceCard) {
                // Navigator.of(context).pushNamed(
                //   SequencePage.routeName,
                //   arguments: gridData[index].id,
                // );
                return;
              }
            },
            onLongPress: () {
              if (gridData[index] is BookCard) {
                showCupertinoModalPopup(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  context: context,
                  builder: (context) {
                    return Center(
                      child: FullInfoCard<GridData>(
                        data: gridData[index],
                      ),
                    );
                  },
                );
                return;
              }
              if (gridData[index] is AuthorCard) {
                // Navigator.of(context).pushNamed(
                //   AuthorPage.routeName,
                //   arguments: gridData[index].id,
                // );
                return;
              }
              if (gridData[index] is SequenceCard) {
                // Navigator.of(context).pushNamed(
                //   SequencePage.routeName,
                //   arguments: gridData[index].id,
                // );
                return;
              }
            },
          );
        },
      );
    } else {
      gridListView = ShimmerGridTileBuilder(
        itemCount: shimmerListCount,
        gridViewType: gridViewType,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) =>
          _handleScrollNotification(context, scrollNotification),
      child: RefreshIndicator(
        onRefresh: () async {
          try {
            BlocProvider.of<GridDataBloc>(context).fetchGridData();
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

  bool _handleScrollNotification(
    BuildContext context,
    ScrollNotification notification,
  ) {
    if (notification.depth != 0) return false;

    var uploadingMore = gridDataState?.uploadingMore;

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
      BlocProvider.of<GridDataBloc>(context).uploadMore(
        ((gridDataState.gridData?.length ?? 0) ~/ HomeGridConsts.kPageSize) + 1,
      );
    }
    return false;
  }
}
