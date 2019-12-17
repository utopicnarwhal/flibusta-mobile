import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/components/show_download_format_mbs.dart';
import 'package:flibusta/pages/home/components/no_results.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flibusta/utils/text_to_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/local_storage.dart';

class GridCards<T> extends StatefulWidget {
  final List<T> data;
  final GlobalKey<ScaffoldState> scaffoldKey;

  GridCards({Key key, this.data, @required this.scaffoldKey}) : super(key: key);

  _GridCardsState createState() => _GridCardsState();
}

class _GridCardsState extends State<GridCards> {
  bool _showAdditionalBookInfo;

  @override
  void initState() {
    super.initState();
    LocalStorage().getShowAdditionalBookInfo().then((showAdditionalBookInfo) {
      setState(() {
        _showAdditionalBookInfo = showAdditionalBookInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data != null && widget.data.length == 0) {
      return NoResults();
    }
    
    if (_showAdditionalBookInfo == null) {
      return Container();
    }

    return Scrollbar(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 4),
        itemCount: widget.data == null ? 0 : widget.data.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: _showAdditionalBookInfo ? 0 : null,
            margin: _showAdditionalBookInfo ? EdgeInsets.zero : null,
            shape: _showAdditionalBookInfo
                ? RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                : null,
            child: Column(
              children: [
                if (widget.data[index] is BookCard)
                  Builder(
                    builder: (context) {
                      var expansionTileTitle = [
                        GridCardRow(
                          rowName: 'Название произведения',
                          value: widget.data[index].title,
                        ),
                        GridCardRow(
                          rowName: 'Автор(-ы)',
                          value: widget.data[index].authors,
                        ),
                      ];
                      var expansionTileChildren = [
                        GridCardRow(
                          rowName: 'Перевод',
                          value: widget.data[index].translators,
                        ),
                        GridCardRow(
                          rowName: 'Жанр произведения',
                          value: widget.data[index].genres,
                        ),
                        GridCardRow(
                          rowName: 'Из серии произведений',
                          value: widget.data[index].sequenceTitle,
                        ),
                        GridCardRow(
                          rowName: 'Размер книги',
                          value: widget.data[index].size,
                        ),
                        GridCardRow(
                          rowName: 'Форматы файлов',
                          value: widget.data[index].downloadFormats,
                          showCustomLeading:
                              widget.data[index].downloadProgress != null,
                          customLeading: CircularProgressIndicator(
                            value: widget.data[index].downloadProgress == 0.0
                                ? null
                                : widget.data[index].downloadProgress,
                          ),
                        ),
                        ButtonBarTheme(
                          data: ButtonBarThemeData(
                            layoutBehavior: ButtonBarLayoutBehavior.constrained,
                          ),
                          child: ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: [
                              AdditionalInfoButton(
                                element: widget.data[index],
                              ),
                              if (widget.data[index] is BookCard &&
                                  widget.data[index].downloadFormats != null)
                                DownloadBookButton(
                                  scaffoldKey: widget.scaffoldKey,
                                  book: widget.data[index],
                                  downloadBookCallback: (downloadProgress) {
                                    setState(() {
                                      widget.data[index].downloadProgress =
                                          downloadProgress;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ];
                      if (_showAdditionalBookInfo) {
                        return ListTile(
                          title: Column(
                            children: <Widget>[
                              ...expansionTileTitle,
                              ...expansionTileChildren,
                            ],
                          ),
                        );
                      }
                      return Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _showAdditionalBookInfo,
                          title: Column(
                            children: expansionTileTitle,
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  ...expansionTileChildren,
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (widget.data[index] is AuthorCard) ...[
                  GridCardRow(
                    rowName: 'Имя автора',
                    value: widget.data[index].name,
                  ),
                  GridCardRow(
                    rowName: 'Количество книг',
                    value: widget.data[index].booksCount,
                  ),
                  ButtonBarTheme(
                    data: ButtonBarThemeData(
                      layoutBehavior: ButtonBarLayoutBehavior.constrained,
                    ),
                    child: ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoButton(
                          element: widget.data[index],
                        ),
                        if (widget.data[index] is BookCard &&
                            widget.data[index].downloadFormats != null)
                          DownloadBookButton(
                            scaffoldKey: widget.scaffoldKey,
                            book: widget.data[index],
                            downloadBookCallback: (downloadProgress) {
                              setState(() {
                                widget.data[index].downloadProgress =
                                    downloadProgress;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                if (widget.data[index] is SequenceCard) ...[
                  GridCardRow(
                    rowName: 'Название серии',
                    value: widget.data[index].title,
                  ),
                  GridCardRow(
                    rowName: 'Количество книг в серии',
                    value: widget.data[index].booksCount,
                  ),
                  ButtonBarTheme(
                    data: ButtonBarThemeData(
                      layoutBehavior: ButtonBarLayoutBehavior.constrained,
                    ),
                    child: ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoButton(
                          element: widget.data[index],
                        ),
                        if (widget.data[index] is BookCard &&
                            widget.data[index].downloadFormats != null)
                          DownloadBookButton(
                            scaffoldKey: widget.scaffoldKey,
                            book: widget.data[index],
                            downloadBookCallback: (downloadProgress) {
                              setState(() {
                                widget.data[index].downloadProgress =
                                    downloadProgress;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                if (index != widget.data.length - 1 && _showAdditionalBookInfo)
                  Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdditionalInfoButton extends StatelessWidget {
  final dynamic element;
  const AdditionalInfoButton({Key key, this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var routeName;
    if (element is BookCard) {
      routeName = BookPage.routeName;
    }
    if (element is AuthorCard) {
      routeName = AuthorPage.routeName;
    }
    if (element is SequenceCard) {
      routeName = SequencePage.routeName;
    }
    return FlatButton(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Text("ПОДРОБНЕЕ", style: TextStyle(fontSize: 16.0)),
      onPressed: () {
        Navigator.of(context).pushNamed(routeName, arguments: element.id);
      },
    );
  }
}

class DownloadBookButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BookCard book;
  final void Function(double) downloadBookCallback;

  const DownloadBookButton(
      {Key key,
      @required this.scaffoldKey,
      @required this.book,
      @required this.downloadBookCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (book.downloadFormats == null || book.downloadFormats.isEmpty) {
      return Container();
    }

    var onPressed = () async {
      var downloadFormat = await showDownloadFormatMBS(scaffoldKey, book);
      if (downloadFormat == null) {
        return;
      }

      var _bookBloc = BookBloc(book.id);

      await _bookBloc.downloadBook(
        book,
        downloadFormat,
        scaffoldKey,
        downloadBookCallback,
      );

      _bookBloc.dispose();
    };

    return FlatButton(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Text(
        "СКАЧАТЬ",
        style: TextStyle(fontSize: 16.0),
      ),
      onPressed: book.downloadProgress != null ? null : onPressed,
    );
  }
}

class GridCardRow extends StatelessWidget {
  final String rowName;
  final dynamic value;
  final bool showCustomLeading;
  final Widget customLeading;

  const GridCardRow(
      {Key key,
      @required this.rowName,
      @required this.value,
      this.showCustomLeading = false,
      this.customLeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null || value.isEmpty) {
      return Container();
    }

    return Tooltip(
      message: rowName,
      preferBelow: false,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        dense: true,
        leading: showCustomLeading && customLeading != null
            ? customLeading
            : Icon(gridRowNameToIcon(rowName)),
        title: Text(
          value.toString(),
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
