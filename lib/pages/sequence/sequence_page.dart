import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flibusta/model/sequenceInfo.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SequencePage extends StatefulWidget {
  static const routeName = "/SequencePage";

  final int sequenceId;

  const SequencePage({Key key, this.sequenceId}) : super(key: key);
  @override
  _SequencePageState createState() => _SequencePageState();
}

class _SequencePageState extends State<SequencePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SequenceInfo _sequenceInfo;
  DsError _dsError;
  GridDataBloc _gridDataBloc;

  @override
  void initState() {
    super.initState();

    _gridDataBloc = GridDataBloc(GridViewType.suquence);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _gridDataBloc,
      builder: (context, GridDataState gridDataState) {
        Widget body;

        if (_sequenceInfo == null) {
          if (_dsError != null) {
            body = ErrorScreen(
              errorMessage: _dsError.toString(),
              onTryAgain: () {
                _getSequenceInfo();
                setState(() {
                  _dsError = null;
                });
              },
            );
          } else {
            body = Center(
              child: DsCircularProgressIndicator(),
            );
          }
          body = SingleChildScrollView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            child: body,
          );
        } else {
          body = Scrollbar(
            child: ListView.separated(
              physics: kBouncingAlwaysScrollableScrollPhysics,
              addSemanticIndexes: false,
              itemCount: _sequenceInfo.books.length,
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
                    _sequenceInfo.books[index]?.genres?.list?.map((genre) {
                  return genre.values?.first;
                })?.toList();
                var score = _sequenceInfo.books[index]?.score;

                return Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.zero,
                  child: GridDataTile(
                    index: index,
                    isFirst: false,
                    isLast: true,
                    showTopDivider: index == 0,
                    showBottomDivier: index == _sequenceInfo.books.length - 1,
                    title: _sequenceInfo.books[index].tileTitle,
                    subtitle: _sequenceInfo.books[index].tileSubtitle,
                    genres: genresStrings,
                    score: score,
                    onTap: () {
                      LocalStorage()
                          .addToLastOpenBooks(_sequenceInfo.books[index]);
                      Navigator.of(context).pushNamed(
                        BookPage.routeName,
                        arguments: _sequenceInfo.books[index].id,
                      );
                    },
                    onLongPress: () {
                      showCupertinoModalPopup(
                        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        context: context,
                        builder: (context) {
                          return Center(
                            child: FullInfoCard<BookCard>(
                              data: _sequenceInfo.books[index],
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
          appBar: DsAppBar(
            title: Text(
              _sequenceInfo?.title ?? 'Загрузка...',
              overflow: TextOverflow.fade,
            ),
            // actions: <Widget>[
            //   PopupMenuButton<SortBooksBy>(
            //     tooltip: 'Сортировать по...',
            //     icon: Icon(Icons.filter_list),
            //     captureInheritedThemes: true,
            //     onSelected: (newSortBooksBy) {
            //       if (newSortBooksBy == null || newSortBooksBy == _sortBooksBy) {
            //         return;
            //       }
            //       setState(() {
            //         _sortBooksBy = newSortBooksBy;
            //         _dsError = null;
            //         _authorInfo = null;
            //       });
            //       _getAuthorInfo();
            //     },
            //     itemBuilder: (context) {
            //       List<PopupMenuEntry<SortBooksBy>> entries =
            //           SortBooksBy.values.map((sortBooksBy) {
            //         return PopupMenuItem<SortBooksBy>(
            //           child: ListTile(
            //             title: Text(
            //               sortBooksByToString(sortBooksBy),
            //             ),
            //             trailing: sortBooksBy == _sortBooksBy
            //                 ? Icon(
            //                     Icons.check,
            //                     color: kSecondaryColor(context),
            //                   )
            //                 : null,
            //           ),
            //           value: sortBooksBy,
            //         );
            //       }).toList();

            //       return entries.expand((entry) {
            //         if (entries.indexOf(entry) != entries.length - 1) {
            //           return [
            //             entry,
            //             PopupMenuDivider(height: 1),
            //           ];
            //         }
            //         return [entry];
            //       }).toList();
            //     },
            //   ),
            // ],
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
