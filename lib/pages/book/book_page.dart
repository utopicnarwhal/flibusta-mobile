import 'dart:io';

import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/pages/book/components/book_app_bar.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/services/transport/book_service.dart';
import 'package:flibusta/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/components/loading_indicator.dart';
import 'package:rxdart/rxdart.dart';

class BookPage extends StatefulWidget {
  static const routeName = "/BookPage";

  final int bookId;

  const BookPage({Key key, this.bookId}) : super(key: key);
  @override
  BookPageState createState() => BookPageState();
}

class BookPageState extends State<BookPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BehaviorSubject<double> _downloadProgressController;

  BookInfo _bookInfo;
  Image _coverImage;

  DsError _getBookInfoError;
  DsError _getBookCoverImageError;

  @override
  void initState() {
    super.initState();

    _downloadProgressController = BehaviorSubject<double>();

    BookService.getBookInfo(widget.bookId).then((bookInfo) {
      if (!mounted) return;
      setState(() {
        _bookInfo = bookInfo;
      });
      LocalStorage().getDownloadedBooks().then((downloadedBooks) {
        var downloadedBook = downloadedBooks?.firstWhere(
          (book) => book.id == _bookInfo.id,
          orElse: () => null,
        );
        if (downloadedBook != null) {
          if (!mounted) return;
          setState(() {
            _bookInfo.localPath = downloadedBook.localPath;
          });
        }
      });
      BookService.getBookCoverImage(bookInfo.coverImgSrc).then((coverImgBytes) {
        if (!mounted) return;
        setState(() {
          _coverImage = Image.memory(
            coverImgBytes,
            fit: BoxFit.cover,
          );
        });
      }, onError: (dsError) {
        if (!mounted) return;
        setState(() {
          _getBookCoverImageError = dsError;
        });
      });
    }, onError: (dsError) {
      if (!mounted) return;
      setState(() {
        _getBookInfoError = dsError;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_getBookInfoError != null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: DsAppBar(),
        body: Center(
          child: Text(
            _getBookInfoError.toString(),
            style: Theme.of(context).textTheme.headline,
          ),
        ),
      );
    }
    if (_bookInfo == null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: DsAppBar(),
        body: LoadingIndicator(),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      body: Builder(
        builder: (context) {
          Widget appBarBackground;
          if (_getBookCoverImageError != null) {
            appBarBackground = Center(
              child: Text(
                _getBookCoverImageError.toString(),
                style: Theme.of(context).textTheme.headline,
              ),
            );
          } else if (_coverImage == null) {
            appBarBackground = LoadingIndicator();
          } else {
            appBarBackground = _coverImage;
          }

          return CustomScrollView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            slivers: [
              BookAppBar(
                coverImg: appBarBackground,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  ListTile(
                    title: Text(_bookInfo.title ?? ''),
                    subtitle: Text('Название произведения'),
                  ),
                  Divider(indent: 16),
                  ListTile(
                    title: Text(_bookInfo.authors?.toString() ?? ''),
                    subtitle: Text('Автор(-ы)'),
                  ),
                  if (_bookInfo.translators?.isNotEmpty == true) ...[
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        _bookInfo.translators.toString(),
                      ),
                      subtitle: Text('Переведено'),
                    ),
                  ],
                  if (_bookInfo.genres?.isNotEmpty == true) ...[
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        _bookInfo.genres.toString(),
                      ),
                      subtitle: Text('Жанр(-ы)'),
                    ),
                  ],
                  if (_bookInfo.sequenceTitle?.isNotEmpty == true) ...[
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        _bookInfo.sequenceTitle,
                      ),
                      subtitle: Text('Серия произведений'),
                    ),
                  ],
                  if (_bookInfo.addedToLibraryDate?.isNotEmpty == true) ...[
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        _bookInfo.addedToLibraryDate,
                      ),
                    ),
                  ],
                  if (_bookInfo.size?.isNotEmpty == true) ...[
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                        _bookInfo.size,
                      ),
                      subtitle: Text('Размер файла'),
                    ),
                  ],
                  if (_bookInfo.lemma?.isNotEmpty == true) ...[
                    Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Text(
                        'Аннотация:',
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      child: Text(
                        _bookInfo.lemma,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                  if (_bookInfo.downloadFormats != null &&
                      _bookInfo.localPath == null)
                    StreamBuilder<double>(
                      builder: (context, downloadProgressSnapshot) {
                        if (!downloadProgressSnapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: DsOutlineButton(
                              child: Text('Скачать'),
                              onPressed: () => _onDownloadBookClick(_bookInfo),
                            ),
                          );
                        }
                        return LinearProgressIndicator(
                          value: downloadProgressSnapshot.data == 0.0
                              ? null
                              : downloadProgressSnapshot.data,
                        );
                      },
                    ),
                  if (_bookInfo.localPath != null)
                    FutureBuilder(
                      future: File(_bookInfo.localPath).exists(),
                      builder: (context, bookFileExistsSnapshot) {
                        if (bookFileExistsSnapshot.data != true) {
                          return StreamBuilder<double>(
                            builder: (context, downloadProgressSnapshot) {
                              if (!downloadProgressSnapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: DsOutlineButton(
                                    child: Text('Скачать'),
                                    onPressed: () =>
                                        _onDownloadBookClick(_bookInfo),
                                  ),
                                );
                              }
                              return LinearProgressIndicator(
                                value: downloadProgressSnapshot.data == 0.0
                                    ? null
                                    : downloadProgressSnapshot.data,
                              );
                            },
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: DsOutlineButton(
                            child: Text('Открыть'),
                            onPressed: () => FileUtils.openFile(
                              _bookInfo.localPath,
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 56),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onDownloadBookClick(BookInfo bookInfo) async {
    BookService.downloadBook(
      context,
      bookInfo,
      (downloadProgress) {
        if (!mounted) return;
        _downloadProgressController.add(downloadProgress);
      },
    );
  }

  @override
  void dispose() {
    _downloadProgressController?.close();
    super.dispose();
  }
}
