import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/blocs/grid/grid_data/grid_data_repository.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/pages/advanced_search/advanced_search_drawer.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
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

  GridDataBloc _gridDataBloc;

  @override
  void initState() {
    super.initState();
    _gridDataBloc = GridDataBloc(GridViewType.advancedSearch);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _gridDataBloc,
      builder: (context, GridDataState gridDataState) {
        Widget body;

        if (gridDataState.stateCode == GridDataStateCode.Empty) {
          body = Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
              child: FlareActor(
                'assets/animations/books_placeholder.flr',
                fit: BoxFit.contain,
                animation: 'Animations',
              ),
            ),
          );
        } else if (gridDataState.gridData == null) {
          if (gridDataState.stateCode == GridDataStateCode.Error) {
            body = ErrorScreen(
              errorMessage: gridDataState.message,
              onTryAgain: () {
                _gridDataBloc.fetchGridData();
              },
            );
          } else {
            body = Center(
              child: DsCircularProgressIndicator(),
            );
          }
        } else {
          body = Scrollbar(
            child: ListView.separated(
              physics: kBouncingAlwaysScrollableScrollPhysics,
              addSemanticIndexes: false,
              itemCount: gridDataState.gridData.length,
              padding: EdgeInsets.symmetric(vertical: 20),
              separatorBuilder: (context, index) {
                return Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.zero,
                  child: Divider(indent: 16),
                );
              },
              itemBuilder: (context, index) {
                List<String> genresStrings =
                    (gridDataState.gridData[index] as BookCard)
                        ?.genres
                        ?.list
                        ?.map((genre) {
                  return genre.values?.first;
                })?.toList();
                var score = (gridDataState.gridData[index] as BookCard)?.score;

                return Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.zero,
                  child: GridDataTile(
                    index: index,
                    isFirst: false,
                    isLast: true,
                    showTopDivider: index == 0,
                    showBottomDivier:
                        index == gridDataState.gridData.length - 1,
                    title: gridDataState.gridData[index].tileTitle,
                    subtitle: gridDataState.gridData[index].tileSubtitle,
                    genres: genresStrings,
                    score: score,
                    onTap: () {
                      LocalStorage()
                          .addToLastOpenBooks(gridDataState.gridData[index]);
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
          );
        }
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: AdvancedSearchDrawer(
            advancedSearchParams: widget.advancedSearchParams,
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

  @override
  void dispose() {
    _gridDataBloc?.close();
    super.dispose();
  }
}
