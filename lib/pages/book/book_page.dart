import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/pages/book/components/book_app_bar.dart';
import 'package:flibusta/pages/home/components/show_download_format_mbs.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/services/transport/book_service.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/components/loading_indicator.dart';

class BookPage extends StatefulWidget {
  static const routeName = "/BookPage";

  final int bookId;

  const BookPage({Key key, this.bookId}) : super(key: key);
  @override
  BookPageState createState() => BookPageState();
}

class BookPageState extends State<BookPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BookInfo _bookInfo;
  Image _coverImage;

  @override
  void initState() {
    super.initState();

    BookService.getBookInfo(widget.bookId).then((bookInfo) {
      setState(() {
        _bookInfo = bookInfo;
      });
      LocalStorage().addToLastOpenBooks(_bookInfo);
      BookService.getBookCoverImage(bookInfo.coverImgSrc).then((coverImgBytes) {
        setState(() {
          _coverImage = Image.memory(
            coverImgBytes,
            fit: BoxFit.cover,
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Builder(
        builder: (context) {
          if (_bookInfo == null) {
            return LoadingIndicator();
          }

          return CustomScrollView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            slivers: [
              BookAppBar(
                coverImg: _coverImage,
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
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: RaisedButton(
                      child: Text('Скачать'),
                      onPressed: _bookInfo.downloadProgress == null
                          ? () => _onDownloadBookClick(_bookInfo)
                          : null,
                    ),
                  ),
                  _bookInfo.downloadProgress != null
                      ? LinearProgressIndicator(
                          value: _bookInfo.downloadProgress == 0.0
                              ? null
                              : _bookInfo.downloadProgress,
                        )
                      : Container(),
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
        setState(() {
          bookInfo.downloadProgress = downloadProgress;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
