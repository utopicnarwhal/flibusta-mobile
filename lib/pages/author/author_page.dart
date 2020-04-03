import 'dart:ui';

import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/authorInfo.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/sortBooksByEnum.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/ds_controls/theme.dart';

class AuthorPage extends StatefulWidget {
  static const routeName = "/author_page";

  final int authorId;

  const AuthorPage({Key key, this.authorId}) : super(key: key);
  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AuthorInfo _authorInfo;
  DsError _dsError;
  SortBooksBy _sortBooksBy = SortBooksBy.sequence;

  @override
  void initState() {
    super.initState();

    _getAuthorInfo();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_authorInfo == null) {
      if (_dsError != null) {
        body = ErrorScreen(
          errorMessage: _dsError.toString(),
          onTryAgain: () {
            _getAuthorInfo();
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
          itemCount: _authorInfo.books.length,
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
                _authorInfo.books[index]?.genres?.list?.map((genre) {
              return genre.values?.first;
            })?.toList();
            var score = _authorInfo.books[index]?.fileScore;

            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: GridDataTile(
                index: index,
                isFirst: false,
                isLast: true,
                showTopDivider: index == 0,
                showBottomDivier: index == _authorInfo.books.length - 1,
                title: _authorInfo.books[index].tileTitle,
                subtitle: _authorInfo.books[index].sequenceTitle,
                genres: genresStrings,
                score: score,
                onTap: () {
                  LocalStorage().addToLastOpenBooks(_authorInfo.books[index]);
                  Navigator.of(context).pushNamed(
                    BookPage.routeName,
                    arguments: _authorInfo.books[index].id,
                  );
                },
                onLongPress: () {
                  showCupertinoModalPopup(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    context: context,
                    builder: (context) {
                      return Center(
                        child: FullInfoCard<BookCard>(
                          data: _authorInfo.books[index],
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
          _authorInfo?.name ?? 'Загрузка...',
          overflow: TextOverflow.fade,
        ),
        actions: <Widget>[
          PopupMenuButton<SortBooksBy>(
            tooltip: 'Сортировать по...',
            icon: Icon(Icons.filter_list),
            captureInheritedThemes: true,
            onSelected: (newSortBooksBy) {
              if (newSortBooksBy == null || newSortBooksBy == _sortBooksBy) {
                return;
              }
              setState(() {
                _sortBooksBy = newSortBooksBy;
                _dsError = null;
                _authorInfo = null;
              });
              _getAuthorInfo();
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<SortBooksBy>> entries =
                  SortBooksBy.values.map((sortBooksBy) {
                return PopupMenuItem<SortBooksBy>(
                  child: ListTile(
                    title: Text(
                      sortBooksByToString(sortBooksBy),
                    ),
                    trailing: sortBooksBy == _sortBooksBy
                        ? Icon(
                            Icons.check,
                            color: kSecondaryColor(context),
                          )
                        : null,
                  ),
                  value: sortBooksBy,
                );
              }).toList();

              return entries.expand((entry) {
                if (entries.indexOf(entry) != entries.length - 1) {
                  return [
                    entry,
                    PopupMenuDivider(height: 1),
                  ];
                }
                return [entry];
              }).toList();
            },
          ),
        ],
      ),
      body: body,
    );
  }

  Future<void> _getAuthorInfo() async {
    AuthorInfo result;

    try {
      var queryParams = {
        'lang': '__',
        'order': sortBooksByToQueryParam(_sortBooksBy),
        'hg1': '1',
        'sa1': '1',
        'hr1': '1',
      };

      Uri url = Uri.https(
        ProxyHttpClient().getHostAddress(),
        "/a/" + widget.authorId.toString(),
        queryParams,
      );

      var response = await ProxyHttpClient().getDio().getUri(url);

      result = parseHtmlFromAuthorInfo(response.data, widget.authorId);

      setState(() {
        _authorInfo = result;
      });
    } on DsError catch (dsError) {
      setState(() {
        _dsError = dsError;
      });
    }
  }
}
