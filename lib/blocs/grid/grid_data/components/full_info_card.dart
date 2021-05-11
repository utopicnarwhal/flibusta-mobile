import 'dart:io';

import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/services/transport/book_service.dart';
import 'package:flibusta/utils/file_utils.dart';
import 'package:flibusta/utils/icon_utils.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FullInfoCard<T> extends StatefulWidget {
  final T data;
  final bool isDeletable;

  FullInfoCard({
    Key key,
    this.data,
    this.isDeletable = false,
  }) : super(key: key);

  _FullInfoCardState createState() => _FullInfoCardState();
}

class _FullInfoCardState extends State<FullInfoCard> {
  BehaviorSubject<double> _downloadProgressController;

  @override
  void initState() {
    super.initState();
    _downloadProgressController = BehaviorSubject<double>();
    if (widget.data is BookCard) {
      LocalStorage().getDownloadedBooks().then((downloadedBooks) {
        var downloadedBook = downloadedBooks?.firstWhere(
          (book) => book.id == (widget.data as BookCard).id,
          orElse: () => null,
        );
        if (downloadedBook != null) {
          if (!mounted) return;
          setState(() {
            (widget.data as BookCard).localPath = downloadedBook.localPath;
          });
        }
      });
    }
    LocalStorage().setLongTapTutorialCompleted();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> infoListWidgets;

    if (widget.data is AuthorCard) {
      var authorCard = widget.data as AuthorCard;

      infoListWidgets = [
        GridCardRow(
          rowName: 'Имя автора',
          value: authorCard.name,
        ),
        GridCardRow(
          rowName: 'Количество книг',
          value: authorCard.booksCount,
        ),
      ];
    } else if (widget.data is SequenceCard) {
      var sequenceCard = widget.data as SequenceCard;

      infoListWidgets = [
        GridCardRow(
          rowName: 'Название серии',
          value: sequenceCard.title,
        ),
        GridCardRow(
          rowName: 'Количество книг в серии',
          value: sequenceCard.booksCount,
        ),
      ];
    } else if (widget.data is BookCard) {
      var bookCard = widget.data as BookCard;

      infoListWidgets = [
        GridCardRow(
          rowName: 'Название произведения',
          value: bookCard.title,
        ),
        GridCardRow(
          rowName: 'Автор(-ы)',
          value: bookCard.authors,
        ),
        GridCardRow(
          rowName: 'Перевод',
          value: bookCard.translators,
        ),
        GridCardRow(
          rowName: 'Жанр произведения',
          value: bookCard.genres,
        ),
        GridCardRow(
          rowName: 'Из серии произведений',
          value: bookCard.sequenceTitle,
        ),
        GridCardRow(
          rowName: 'Размер книги',
          value: bookCard.size,
        ),
        GridCardRow(
          rowName: 'Оценка файла',
          value: fileScoreToString(bookCard.fileScore),
        ),
        GridCardRow(
          rowName: 'Добавлена в библиотеку',
          value: bookCard.addedToLibraryDate,
        ),
        GridCardRow(
          rowName: 'Форматы файлов',
          value: bookCard.downloadFormats,
        ),
        if (bookCard.downloadFormats?.list?.isEmpty == false)
          StreamBuilder<double>(
            stream: _downloadProgressController,
            builder: (context, downloadProgressSnapshot) {
              if (downloadProgressSnapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kCardBorderRadius),
                    child: LinearProgressIndicator(
                      value: downloadProgressSnapshot.data == 0.0 ? null : downloadProgressSnapshot.data,
                      minHeight: 16,
                    ),
                  ),
                );
              }

              List<Widget> downloadBlockWidgets = [];
              if (bookCard.localPath != null) {
                downloadBlockWidgets.add(
                  FutureBuilder(
                    future: File(bookCard.localPath).exists(),
                    builder: (context, bookFileExistsSnapshot) {
                      if (bookFileExistsSnapshot.data != true) {
                        return SizedBox();
                      }
                      return GridCardRow(
                        rowName: 'Путь к файлу',
                        value: bookCard.localPath,
                      );
                    },
                  ),
                );
              }
              Widget buttonBarChild;
              var downloadButton = DownloadBookButton(
                book: bookCard,
                downloadBookCallback: (downloadProgress) {
                  if (_downloadProgressController.isClosed) return;
                  _downloadProgressController.add(downloadProgress);
                },
              );

              if (bookCard.localPath == null) {
                buttonBarChild = downloadButton;
              } else {
                buttonBarChild = FutureBuilder(
                  future: File(bookCard.localPath).exists(),
                  builder: (context, bookFileExistsSnapshot) {
                    if (!bookFileExistsSnapshot.hasData) {
                      return SizedBox();
                    }
                    if (bookFileExistsSnapshot.data == false) {
                      return downloadButton;
                    }
                    return TextButton(
                      child: Text(
                        'ОТКРЫТЬ',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      onPressed: () => FileUtils.openFile(
                        bookCard.localPath,
                      ),
                    );
                  },
                );
              }

              downloadBlockWidgets.add(
                ButtonBarTheme(
                  data: ButtonBarThemeData(
                    layoutBehavior: ButtonBarLayoutBehavior.constrained,
                  ),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.spaceAround,
                    children: [
                      buttonBarChild,
                      if (widget.isDeletable)
                        TextButton(
                          child: Text(
                            'УДАЛИТЬ',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                    ],
                  ),
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: downloadBlockWidgets,
              );
            },
          ),
      ];
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Center(
        child: Card(
          margin: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 8),
              children: infoListWidgets,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _downloadProgressController?.close();
    super.dispose();
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

    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      ),
      child: Text(
        'СКАЧАТЬ',
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
      {Key key, @required this.rowName, @required this.value, this.showCustomLeading = false, this.customLeading})
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
        leading: showCustomLeading && customLeading != null ? customLeading : Icon(gridRowNameToIcon(rowName)),
        title: Text(
          value.toString(),
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
