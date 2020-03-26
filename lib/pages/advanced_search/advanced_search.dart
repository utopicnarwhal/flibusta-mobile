import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/advanced_search/advanced_search_drawer.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';

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

  bool _isRequestWaiting = true;
  List<BookCard> _searchResult;
  DsError _dsError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.advancedSearchParams == null) {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_isRequestWaiting) {
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
    } else if (_searchResult == null) {
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
    } else {
      body = Scrollbar(
        child: ListView.separated(
          physics: kBouncingAlwaysScrollableScrollPhysics,
          addSemanticIndexes: false,
          itemCount: _searchResult.length,
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
                _searchResult[index]?.genres?.list?.map((genre) {
              return genre.values?.first;
            })?.toList();
            var score = _searchResult[index]?.score;

            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: GridDataTile(
                index: index,
                isFirst: false,
                isLast: true,
                showTopDivider: index == 0,
                showBottomDivier: index == _searchResult.length - 1,
                title: _searchResult[index].tileTitle,
                subtitle: _searchResult[index].tileSubtitle,
                genres: genresStrings,
                score: score,
                onTap: () {
                  LocalStorage().addToLastOpenBooks(_searchResult[index]);
                  Navigator.of(context).pushNamed(
                    BookPage.routeName,
                    arguments: _searchResult[index].id,
                  );
                },
                onLongPress: () {
                  showCupertinoModalPopup(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    context: context,
                    builder: (context) {
                      return Center(
                        child: FullInfoCard<BookCard>(
                          data: _searchResult[index],
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
          _searchResult == null && !_isRequestWaiting
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
  }

  Future<void> _getSequenceInfo() async {
    List<BookCard> result;

    try {
      // var queryParams = {
      //   'lang': '__',
      //   'order': sortBooksByToQueryParam(_sortBooksBy),
      //   'hg1': '1',
      //   'sa1': '1',
      //   'hr1': '1',
      // };

      // Uri url = Uri.https(
      //   ProxyHttpClient().getHostAddress(),
      //   '/s/' + widget.sequenceId.toString(),
      //   // queryParams,
      // );

      // var response = await ProxyHttpClient().getDio().getUri(url);

      // result = parseHtmlFromSequenceInfo(response.data, widget.sequenceId);

      setState(() {
        _searchResult = result;
      });
    } on DsError catch (dsError) {
      setState(() {
        _dsError = dsError;
      });
    }
  }
}
