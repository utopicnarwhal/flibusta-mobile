import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/pages/author/author_page.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/book_list_builder/show_download_format_mbs.dart';
import 'package:flibusta/pages/sequence/sequence_page.dart';
import 'package:flibusta/utils/text_to_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridCards<T> extends StatefulWidget {
  final List<T> data;
  final GlobalKey<ScaffoldState> scaffoldKey;

  GridCards({Key key, this.data, @required this.scaffoldKey}) : super(key: key);

  _GridCardsState createState() => _GridCardsState();
}

class _GridCardsState extends State<GridCards> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
          ),
        ),
        Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: widget.data == null ? 0 : widget.data.length,
            itemBuilder: (BuildContext context, int index) {
              List<Widget> cardRows = [];

              if (widget.data[index] is BookCard) {
                cardRows.addAll([
                  GridCardRow(
                    rowName: 'Название произведения',
                    value: widget.data[index].title,
                  ),
                  GridCardRow(
                    rowName: 'Автор(-ы)',
                    value: widget.data[index].authors,
                  ),
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
                ]);
              }
              if (widget.data[index] is AuthorCard) {
                cardRows.addAll([
                  GridCardRow(
                    rowName: 'Имя автора',
                    value: widget.data[index].name,
                  ),
                  GridCardRow(
                    rowName: 'Количество книг',
                    value: widget.data[index].booksCount,
                  ),
                ]);
              }
              if (widget.data[index] is SequenceCard) {
                cardRows.addAll([
                  GridCardRow(
                    rowName: 'Название серии',
                    value: widget.data[index].title,
                  ),
                  GridCardRow(
                    rowName: 'Количество книг в серии',
                    value: widget.data[index].booksCount,
                  ),
                ]);
              }
              List<Widget> cardButtonBar = [
                AdditionalInfoButton(
                  element: widget.data[index],
                ),
              ];
              if (widget.data[index] is BookCard &&
                  widget.data[index].downloadFormats != null) {
                cardButtonBar.add(
                  DownloadBookButton(
                    scaffoldKey: widget.scaffoldKey,
                    book: widget.data[index],
                    downloadBookCallback: (downloadProgress) {
                      setState(() {
                        widget.data[index].downloadProgress = downloadProgress;
                      });
                    },
                  ),
                );
              }
              cardRows.add(
                ButtonTheme.bar(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.spaceAround,
                    children: cardButtonBar,
                  ),
                ),
              );

              return Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: Column(
                      children: cardRows,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text("ПОДРОБНЕЕ", style: TextStyle(fontSize: 20.0)),
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
        downloadFormat,
        scaffoldKey,
        downloadBookCallback,
      );

      _bookBloc.dispose();
    };

    return FlatButton(
      padding: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      child: Text(
        "СКАЧАТЬ",
        style: TextStyle(fontSize: 20.0),
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
