import 'dart:io';

import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/services/transport/book_service.dart';
import 'package:flibusta/utils/file_utils.dart';
import 'package:flibusta/utils/icon_utils.dart';
import 'package:flutter/material.dart';

class FullInfoCard<T> extends StatefulWidget {
  final T data;

  FullInfoCard({
    Key key,
    this.data,
  }) : super(key: key);

  _FullInfoCardState createState() => _FullInfoCardState();
}

class _FullInfoCardState extends State<FullInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.topLeft,
        children: <Widget>[
          Card(
            margin: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kCardBorderRadius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.data is BookCard)
                    Builder(
                      builder: (context) {
                        var expansionTileTitle = [
                          GridCardRow(
                            rowName: 'Название произведения',
                            value: widget.data.title,
                          ),
                          GridCardRow(
                            rowName: 'Автор(-ы)',
                            value: widget.data.authors,
                          ),
                        ];
                        var expansionTileChildren = [
                          GridCardRow(
                            rowName: 'Перевод',
                            value: widget.data.translators,
                          ),
                          GridCardRow(
                            rowName: 'Жанр произведения',
                            value: widget.data.genres,
                          ),
                          GridCardRow(
                            rowName: 'Из серии произведений',
                            value: widget.data.sequenceTitle,
                          ),
                          GridCardRow(
                            rowName: 'Размер книги',
                            value: widget.data.size,
                          ),
                          GridCardRow(
                            rowName: 'Форматы файлов',
                            value: widget.data.downloadFormats,
                            showCustomLeading:
                                widget.data.downloadProgress != null &&
                                    widget.data.localPath == null,
                            customLeading: DsCircularProgressIndicator(
                              value: widget.data.downloadProgress == 0.0
                                  ? null
                                  : widget.data.downloadProgress,
                            ),
                          ),
                          if (widget.data.localPath != null)
                            GridCardRow(
                              rowName: 'Путь к файлу',
                              value: widget.data.localPath,
                            ),
                          ButtonBarTheme(
                            data: ButtonBarThemeData(
                              layoutBehavior:
                                  ButtonBarLayoutBehavior.constrained,
                            ),
                            child: ButtonBar(
                              alignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (widget.data is BookCard &&
                                    widget.data.downloadFormats != null &&
                                    widget.data.localPath == null)
                                  DownloadBookButton(
                                    book: widget.data,
                                    downloadBookCallback: (downloadProgress) {
                                      setState(() {
                                        widget.data.downloadProgress =
                                            downloadProgress;
                                      });
                                    },
                                  ),
                                if (widget.data is BookCard &&
                                    widget.data.localPath != null)
                                  FutureBuilder(
                                    future:
                                        File(widget.data.localPath).exists(),
                                    builder: (context, bookFileExistsSnapshot) {
                                      if (bookFileExistsSnapshot.data != true) {
                                        return Container();
                                      }
                                      return FlatButton(
                                        child: Text('Открыть'),
                                        onPressed: () => FileUtils.openFile(
                                          widget.data.localPath,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ];
                        return ListTile(
                          title: Column(
                            children: <Widget>[
                              ...expansionTileTitle,
                              ...expansionTileChildren,
                            ],
                          ),
                        );
                      },
                    ),
                  if (widget.data is AuthorCard) ...[
                    GridCardRow(
                      rowName: 'Имя автора',
                      value: widget.data.name,
                    ),
                    GridCardRow(
                      rowName: 'Количество книг',
                      value: widget.data.booksCount,
                    ),
                  ],
                  if (widget.data is SequenceCard) ...[
                    GridCardRow(
                      rowName: 'Название серии',
                      value: widget.data.title,
                    ),
                    GridCardRow(
                      rowName: 'Количество книг в серии',
                      value: widget.data.booksCount,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadBookButton extends StatelessWidget {
  final BookCard book;
  final void Function(double) downloadBookCallback;

  const DownloadBookButton({
    Key key,
    @required this.book,
    @required this.downloadBookCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (book.downloadFormats == null || book.downloadFormats.isEmpty) {
      return Container();
    }

    var onPressed = () async {
      BookService.downloadBook(
        context,
        book,
        downloadBookCallback,
      );
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
