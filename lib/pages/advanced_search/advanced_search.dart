import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/decor/shimmers.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/pages/advanced_search/advanced_search_drawer.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdvancedSearchPage extends StatefulWidget {
  static const String routeName = '/advanced_search_page';

  final AdvancedSearchParams advancedSearchParams;

  const AdvancedSearchPage({
    Key key,
    this.advancedSearchParams,
  }) : super(key: key);

  @override
  _AdvancedSearchPageState createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AdvancedSearchParams _advancedSearchParams;
  GridDataBloc _gridDataBloc;

  @override
  void initState() {
    super.initState();
    _gridDataBloc = GridDataBloc(GridViewType.advancedSearch);

    _advancedSearchParams = widget.advancedSearchParams;
    if (_advancedSearchParams != null) {
      _gridDataBloc.fetchGridData(_advancedSearchParams);
    } else {
      _advancedSearchParams = AdvancedSearchParams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridDataBloc, GridDataState>(
      bloc: _gridDataBloc,
      builder: (context, gridDataState) {
        Widget body;

        int shimmerListCount =
            (MediaQuery.of(context).size.height / 110).round();

        if (gridDataState.stateCode == GridDataStateCode.Empty) {
          body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
                  child: FlareActor(
                    'assets/animations/books_placeholder.flr',
                    fit: BoxFit.contain,
                    animation: 'Animations',
                  ),
                ),
                DsOutlineButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Открыть параметры поиска'),
                  onPressed: () {
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                ),
              ],
            ),
          );
        } else if ((gridDataState.stateCode == GridDataStateCode.Normal ||
                gridDataState.stateCode == GridDataStateCode.Error) &&
            gridDataState.gridData?.isEmpty == true) {
          body = Column(
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
                  color: Theme.of(context).textTheme.bodyText2.color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Не удалось ничего найти',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        } else if (gridDataState?.stateCode == GridDataStateCode.Error &&
            gridDataState.gridData == null) {
          body = ErrorScreen(
            errorMessage: gridDataState.message,
            onTryAgain: () {
              _gridDataBloc.fetchGridData();
            },
          );
        } else if (gridDataState?.stateCode == GridDataStateCode.Loading) {
          body = ShimmerGridTileBuilder(
            itemCount: shimmerListCount,
            gridViewType: GridViewType.suquence,
          );
        } else if (gridDataState.gridData != null) {
          body = NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) => _handleScrollNotification(
                context, gridDataState, scrollNotification),
            child: RefreshIndicator(
              onRefresh: () async {
                _gridDataBloc.fetchGridData();
              },
              child: Scrollbar(
                child: ListView.separated(
                  physics: kBouncingAlwaysScrollableScrollPhysics,
                  addSemanticIndexes: false,
                  itemCount: gridDataState.uploadingMore
                      ? (gridDataState.gridData.length + 1)
                      : gridDataState.gridData.length,
                  padding: EdgeInsets.only(top: 20),
                  separatorBuilder: (context, index) {
                    return Material(
                      type: MaterialType.card,
                      borderRadius: BorderRadius.zero,
                      child: Divider(indent: 16),
                    );
                  },
                  itemBuilder: (context, index) {
                    if (index == gridDataState.gridData.length) {
                      return Material(
                        type: MaterialType.card,
                        borderRadius: BorderRadius.zero,
                        child: Column(
                          children: <Widget>[
                            ShimmerListTile(
                              index: index,
                              gridViewType: GridViewType.suquence,
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    }

                    List<String> genresStrings =
                        (gridDataState.gridData[index] as BookCard)
                            ?.genres
                            ?.list
                            ?.map((genre) {
                      return genre.values?.first;
                    })?.toList();
                    var score =
                        (gridDataState.gridData[index] as BookCard)?.fileScore;

                    return Material(
                      type: MaterialType.card,
                      borderRadius: BorderRadius.zero,
                      child: GridDataTile(
                        index: index,
                        isFirst: false,
                        isLast: true,
                        showTopDivider: index == 0,
                        showBottomDivier: !gridDataState.uploadingMore &&
                            index == gridDataState.gridData.length - 1,
                        title: gridDataState.gridData[index].tileTitle,
                        subtitle: gridDataState.gridData[index].tileSubtitle,
                        genres: genresStrings,
                        score: score,
                        onTap: () {
                          LocalStorage().addToLastOpenBooks(
                              gridDataState.gridData[index]);
                          Navigator.of(context).pushNamed(
                            BookPage.routeName,
                            arguments: gridDataState.gridData[index].id,
                          );
                        },
                        onLongPress: () {
                          showCupertinoModalPopup(
                            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            context: context,
                            builder: (context) {
                              return Center(
                                child: FullInfoCard<BookCard>(
                                  data: gridDataState.gridData[index],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          body = ShimmerGridTileBuilder(
            itemCount: shimmerListCount,
            gridViewType: GridViewType.suquence,
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: AdvancedSearchDrawer(
            advancedSearchParams: _advancedSearchParams,
            onSearch: () {
              _gridDataBloc.fetchGridData(_advancedSearchParams);
            },
          ),
          appBar: DsAppBar(
            title: Text(
              gridDataState.stateCode == GridDataStateCode.Loading
                  ? 'Поиск...'
                  : 'Расширенный поиск',
              overflow: TextOverflow.fade,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  _scaffoldKey.currentState.openEndDrawer();
                },
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  bool _handleScrollNotification(
    BuildContext context,
    GridDataState gridDataState,
    ScrollNotification notification,
  ) {
    if (notification.depth != 0) return false;

    var uploadingMore = gridDataState?.uploadingMore;

    if (gridDataState?.hasReachedMax != false ||
        uploadingMore != false ||
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
      _gridDataBloc.uploadMore(_advancedSearchParams);
    }
    return false;
  }

  @override
  void dispose() {
    _gridDataBloc?.close();
    super.dispose();
  }
}
