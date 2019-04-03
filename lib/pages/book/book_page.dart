import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flutter/material.dart';
import '../../components/loading_indicator.dart';

class BookPage extends StatefulWidget {
  final int bookId;

  const BookPage({Key key, this.bookId}): super(key: key);
  @override
  BookPageState createState() => BookPageState();
}

class BookPageState extends State<BookPage> {
  Dio _dio = ProxyHttpClient().getDio();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BookBloc _bookBloc;

  Image coverImg;
  ImageStream coverImageStream;
  double coverImgHeight = 0;

  Map<String, String> formatForDownload;

  bool coverImageLoading = true;

  @override
  void initState() {
    super.initState();

    _bookBloc = BookBloc(widget.bookId);
    _bookBloc.getBookInfo();
  }

  imageStreamListener(ImageInfo info, bool _) {
    if (mounted) {
      setState(() {
        coverImgHeight = (info.image.height.toDouble() * (MediaQuery.of(context).size.width / info.image.width.toDouble()) - 24);
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
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data.coverImgSrc == null) {
            coverImg = null;
            coverImageLoading = false;
          }
          
          if (snapshot.data != null && coverImageLoading && snapshot.data.coverImgSrc != null) {
            var url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), snapshot.data.coverImgSrc);
            
            _dio.getUri(url, options: Options(
              connectTimeout: 10000,
              receiveTimeout: 6000,
              responseType: ResponseType.bytes,
            )).then((response) {
              if (mounted && coverImageLoading) {
                setState(() {
                  coverImg = Image.memory(Uint8List.fromList(response.data), fit: BoxFit.fitWidth);
                  coverImageStream = coverImg.image.resolve(new ImageConfiguration());
                  coverImageStream.addListener(imageStreamListener);
                });
              }
            });
          }

          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: coverImageLoading ? Colors.grey.shade600 : null,
                  pinned: true,
                  snap: false,
                  floating: false,
                  expandedHeight: coverImageLoading ? MediaQuery.of(context).size.width - 100 : coverImgHeight,
                  title: !coverImageLoading && coverImg == null ? Text("Нет обложки") : Container(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: coverImageLoading ? LoadingIndicator() : coverImg,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                snapshot.data.title ?? "", 
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Center(
                              child: Text(
                                snapshot.data.authors == null ? "" : snapshot.data.authors.toString(), 
                                style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            snapshot.data.translators != null && snapshot.data.translators.isNotEmpty ? Center(
                              child: Text(
                                "Переведено: " + snapshot.data.translators.toString(),
                                style: TextStyle(fontSize: 18, color: Colors.grey.shade800), 
                                textAlign: TextAlign.center,
                              ),
                            ) : Container(),
                            snapshot.data.genres != null && snapshot.data.genres.isNotEmpty ? Center(
                              child: Text(
                                "Жанр: " + snapshot.data.genres.toString(),
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ) : Container(),
                            snapshot.data.sequenceTitle != null ? Center(
                              child: Text(
                                "Серия произведений: " + snapshot.data.sequenceTitle,
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ) : Container(),
                            Center(
                              child: Text(
                                snapshot.data.addedToLibraryDate ?? "",
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Center(
                              child: Text(
                                snapshot.data.size == null ? "" : "Размер: ${snapshot.data.size}",
                                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            snapshot.data.lemma != null ? Text("Аннотация:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),) : Container(),
                            Text(snapshot.data.lemma ?? "", style: TextStyle(fontSize: 18),),
                            snapshot.data.downloadFormats != null ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 12.0, bottom: 12.0, right: 12.0),
                                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                  // decoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(10.0),
                                  //   border: Border.all(
                                  //     color: Colors.grey.shade600,
                                  //   )
                                  // ),
                                  child: DropdownButton(
                                    isDense: false,
                                    value: formatForDownload,
                                    hint: Text("Формат файла"),
                                    items: snapshot.data.downloadFormats.list.map((format) {
                                      return DropdownMenuItem(
                                        value: format,
                                        child: Text(format.keys.first),
                                      );
                                    }).toList(),
                                    onChanged: (choosedFormat) {
                                      setState(() {
                                        formatForDownload = choosedFormat;
                                      });
                                    },
                                  ),
                                ),
                                RaisedButton(
                                  color: Colors.blue,
                                  child: Text("Скачать" ,style: TextStyle(color: Colors.white),),
                                  onPressed: formatForDownload != null && snapshot.data.downloadProgress == null ? () {
                                    _bookBloc.downloadBook(formatForDownload,
                                      _scaffoldKey,
                                      (downloadProgress) {
                                        setState(() {
                                          snapshot.data.downloadProgress = downloadProgress;
                                        });
                                      }
                                    );
                                  } : null,
                                )
                              ],
                            ) : Container(),
                            snapshot.data.downloadProgress != null ? LinearProgressIndicator(
                              value: snapshot.data.downloadProgress == 0.0 ? null : snapshot.data.downloadProgress,
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else {
            return Container();
          }
        }
      ),
    );
  }

  @override
  void dispose() {
    _bookBloc.dispose();
    super.dispose();
  }
}
