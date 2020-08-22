import 'dart:ui';

import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/error_screen.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/sortBooksByEnum.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/ds_controls/theme.dart';

class GenrePage extends StatefulWidget {
  static const routeName = '/genre_page';

  final Genre genre;

  const GenrePage({Key key, this.genre}) : super(key: key);
  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BookCard> _genreBooks;
  DsError _dsError;
  SortGenreBooksBy _sortBooksBy;

  @override
  void initState() {
    super.initState();

    _getGenreInfo();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_genreBooks == null) {
      if (_dsError != null) {
        body = ErrorScreen(
          errorMessage: _dsError.toString(),
          onTryAgain: () {
            _getGenreInfo();
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
          itemCount: _genreBooks.length,
          padding: EdgeInsets.symmetric(vertical: 20),
          separatorBuilder: (context, index) {
            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: Divider(indent: 16),
            );
          },
          itemBuilder: (context, index) {
            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: GridDataTile(
                index: index,
                isFirst: false,
                isLast: true,
                showTopDivider: index == 0,
                showBottomDivier: index == _genreBooks.length - 1,
                title: _genreBooks[index].tileTitle,
                subtitle: _genreBooks[index].authors?.toString(),
                onTap: () {
                  LocalStorage().addToLastOpenBooks(_genreBooks[index]);
                  Navigator.of(context).pushNamed(
                    BookPage.routeName,
                    arguments: _genreBooks[index].id,
                  );
                },
                onLongPress: () {
                  showCupertinoModalPopup(
                    filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                    context: context,
                    builder: (context) {
                      return Center(
                        child: FullInfoCard<BookCard>(
                          data: _genreBooks[index],
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
          widget.genre?.name ?? 'Загрузка...',
          overflow: TextOverflow.fade,
        ),
        actions: <Widget>[
          PopupMenuButton<SortGenreBooksBy>(
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
                _genreBooks = null;
              });
              _getGenreInfo();
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<SortGenreBooksBy>> entries =
                  SortGenreBooksBy.values.map((sortBooksBy) {
                return PopupMenuItem<SortGenreBooksBy>(
                  child: ListTile(
                    title: Text(
                      sortGenreBooksByToString(sortBooksBy),
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

  Future<void> _getGenreInfo() async {
    List<BookCard> result;

    if (_sortBooksBy == null) {
      _sortBooksBy = await LocalStorage().getPreferredGenreBookSort();
    }

    try {
      Uri url = Uri.https(
        ProxyHttpClient().getHostAddress(),
        '/g/${widget.genre.code}/${sortGenreBooksByToQueryParam(_sortBooksBy)}',
      );

      var response = await ProxyHttpClient().getDio().getUri(url);

      result = parseHtmlFromGetGenreInfo(response.data);

      setState(() {
        _genreBooks = result;
      });
    } on DsError catch (dsError) {
      setState(() {
        _dsError = dsError;
      });
    }
  }
}
