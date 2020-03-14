import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/fields/selector.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/pages/home/components/show_download_format_mbs.dart';
import 'package:flibusta/services/http_client.dart';
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

  BookBloc _bookBloc;

  Image coverImg;
  ImageStream coverImageStream;
  double coverImgHeight = 0;

  bool coverImageLoading = true;

  @override
  void initState() {
    super.initState();

    _bookBloc = BookBloc(widget.bookId);
    _bookBloc.getBookInfo();
  }

  void imageStreamListener(ImageInfo info, bool _) {
    if (mounted) {
      setState(() {
        coverImgHeight = (info.image.height.toDouble() *
                (MediaQuery.of(context).size.width /
                    info.image.width.toDouble()) -
            24);
        coverImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: StreamBuilder<BookInfo>(
        stream: _bookBloc.outBookInfo,
        builder: (context, outBookInfoSnapshot) {
          if (outBookInfoSnapshot.data != null &&
              outBookInfoSnapshot.data.coverImgSrc == null) {
            coverImg = null;
            coverImageLoading = false;
          }

          if (outBookInfoSnapshot.data != null &&
              coverImageLoading &&
              outBookInfoSnapshot.data.coverImgSrc != null) {
            var url = Uri.https(
              ProxyHttpClient().getHostAddress(),
              outBookInfoSnapshot.data.coverImgSrc,
            );

            ProxyHttpClient()
                .getDio()
                .getUri(
                  url,
                  options: Options(
                    sendTimeout: 15000,
                    receiveTimeout: 8000,
                    responseType: ResponseType.bytes,
                  ),
                )
                .then((response) {
              if (mounted && coverImageLoading) {
                setState(() {
                  coverImg = Image.memory(Uint8List.fromList(response.data),
                      fit: BoxFit.fitWidth);
                  coverImageStream =
                      coverImg.image.resolve(new ImageConfiguration());
                  coverImageStream
                      .addListener(ImageStreamListener(imageStreamListener));
                });
              }
            });
          }

          if (!outBookInfoSnapshot.hasData) {
            return LoadingIndicator();
          }

          return CustomScrollView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            slivers: <Widget>[
              SliverAppBar(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).cardColor
                        : null,
                pinned: true,
                snap: false,
                floating: false,
                expandedHeight: coverImageLoading
                    ? MediaQuery.of(context).size.width - 100
                    : coverImgHeight,
                title: !coverImageLoading && coverImg == null
                    ? Text('Нет обложки')
                    : Text(outBookInfoSnapshot.data.title ?? ''),
                flexibleSpace: FlexibleSpaceBar(
                  background: coverImageLoading ? LoadingIndicator() : coverImg,
                ),
                bottom: DsAppBarBottomDivider(),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    ListTile(
                      title: Text(outBookInfoSnapshot.data.title ?? ''),
                      subtitle: Text('Название произведения'),
                    ),
                    Divider(indent: 16),
                    ListTile(
                      title: Text(
                          outBookInfoSnapshot.data.authors?.toString() ?? ''),
                      subtitle: Text('Автор(-ы)'),
                    ),
                    if (outBookInfoSnapshot.data.translators?.isNotEmpty ==
                        true) ...[
                      Divider(indent: 16),
                      ListTile(
                        title: Text(
                          outBookInfoSnapshot.data.translators.toString(),
                        ),
                        subtitle: Text('Переведено'),
                      ),
                    ],
                    if (outBookInfoSnapshot.data.genres?.isNotEmpty ==
                        true) ...[
                      Divider(indent: 16),
                      ListTile(
                        title: Text(
                          outBookInfoSnapshot.data.genres.toString(),
                        ),
                        subtitle: Text('Жанр(-ы)'),
                      ),
                    ],
                    if (outBookInfoSnapshot.data.sequenceTitle?.isNotEmpty ==
                        true) ...[
                      Divider(indent: 16),
                      ListTile(
                        title: Text(
                          outBookInfoSnapshot.data.sequenceTitle,
                        ),
                        subtitle: Text('Серия произведений'),
                      ),
                    ],
                    if (outBookInfoSnapshot
                            .data.addedToLibraryDate?.isNotEmpty ==
                        true) ...[
                      Divider(indent: 16),
                      ListTile(
                        title: Text(
                          outBookInfoSnapshot.data.addedToLibraryDate,
                        ),
                      ),
                    ],
                    if (outBookInfoSnapshot.data.size?.isNotEmpty == true) ...[
                      Divider(indent: 16),
                      ListTile(
                        title: Text(
                          outBookInfoSnapshot.data.size,
                        ),
                        subtitle: Text('Размер файла'),
                      ),
                    ],
                    if (outBookInfoSnapshot.data.lemma?.isNotEmpty == true) ...[
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
                          outBookInfoSnapshot.data.lemma,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: RaisedButton(
                        child: Text('Скачать'),
                        onPressed: outBookInfoSnapshot.data.downloadProgress ==
                                null
                            ? () async {
                                var formatForDownload =
                                    await showDownloadFormatMBS(
                                        context, outBookInfoSnapshot.data);
                                _bookBloc.downloadBook(
                                  context,
                                  outBookInfoSnapshot.data,
                                  formatForDownload,
                                  (downloadProgress) {
                                    setState(() {
                                      outBookInfoSnapshot.data.downloadProgress =
                                          downloadProgress;
                                    });
                                  },
                                );
                              }
                            : null,
                      ),
                    ),
                    outBookInfoSnapshot.data.downloadProgress != null
                        ? LinearProgressIndicator(
                            value:
                                outBookInfoSnapshot.data.downloadProgress == 0.0
                                    ? null
                                    : outBookInfoSnapshot.data.downloadProgress,
                          )
                        : Container(),
                    SizedBox(height: 56),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bookBloc.dispose();
    super.dispose();
  }
}
