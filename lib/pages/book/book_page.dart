import 'dart:io';
import 'dart:typed_data';

import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/services/book_service.dart';
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
  HttpClient _httpClient = ProxyHttpClient().getHttpClient();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BookInfo bookInfo;

  Image coverImg;
  ImageStream coverImageStream;
  double coverImgHeight = 0;

  Map<String, String> formatForDownload;

  bool coverImageLoading = true;

  @override
  void initState() {
    super.initState();

    bookInfo = BookInfo(id: widget.bookId);

    BookService.getBookInfo(widget.bookId).then((response) async {
      if (mounted) {
        setState(() {
          bookInfo = response;
        });
      }

      if (bookInfo.coverImgSrc == null) {
        coverImageLoading = false;
        return;
      }

      coverImg = Image.network("https://cn-dot-flibusta.appspot.com" + bookInfo.coverImgSrc, fit: BoxFit.fitWidth);

      coverImageStream = coverImg.image.resolve(new ImageConfiguration());
      coverImageStream.addListener(imageStreamListener);

      if (coverImageLoading && bookInfo.coverImgSrc != null) {
        var url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), bookInfo.coverImgSrc);
        var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 5)).then((r) => r.close());
        var result = List<int>();
        await response.listen((contents) {
          if (!coverImageLoading) {
            return;
          }
          result.addAll(contents);
        }).asFuture();

        if (mounted && coverImageLoading) {
          setState(() {
            coverImg = Image.memory(Uint8List.fromList(result), fit: BoxFit.fitWidth);
            coverImageStream = coverImg.image.resolve(new ImageConfiguration());
            coverImageStream.addListener(imageStreamListener);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
      body: CustomScrollView(
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
                          bookInfo.title ?? "", 
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          bookInfo.authors == null ? "" : bookInfo.authors.toString(), 
                          style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      bookInfo.translators != null && bookInfo.translators.isNotEmpty ? Center(
                        child: Text(
                          "Переведено: " + bookInfo.translators.toString(),
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade800), 
                          textAlign: TextAlign.center,
                        ),
                      ) : Container(),
                      bookInfo.genres != null && bookInfo.genres.isNotEmpty ? Center(
                        child: Text(
                          "Жанр: " + bookInfo.genres.toString(),
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ) : Container(),
                      bookInfo.sequenceTitle != null ? Center(
                        child: Text(
                          "Серия произведений: " + bookInfo.sequenceTitle,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                          textAlign: TextAlign.center,
                        ),
                      ) : Container(),
                      Center(
                        child: Text(
                          bookInfo.addedToLibraryDate ?? "",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          bookInfo.size == null ? "" : "Размер: ${bookInfo.size}",
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      bookInfo.lemma != null ? Text("Аннотация:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),) : Container(),
                      Text(bookInfo.lemma ?? "", style: TextStyle(fontSize: 18),),
                      bookInfo.downloadFormats != null ? Row(
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
                              items: bookInfo.downloadFormats.list.map((format) {
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
                            onPressed: formatForDownload != null && bookInfo.downloadProgress == null ? () {
                              BookService.downloadBook(bookInfo.id, formatForDownload, 
                                (downloadProgress) {
                                  setState(() {
                                    bookInfo.downloadProgress = downloadProgress;
                                  });
                                }, 
                                (alertText, alertDuration) {
                                  _scaffoldKey.currentState.hideCurrentSnackBar();
                                  if (alertText.isEmpty) {
                                    return;
                                  }

                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(alertText),
                                      duration: alertDuration,
                                    )
                                  );
                                }
                              );
                            } : null,
                          )
                        ],
                      ) : Container(),
                      bookInfo.downloadProgress != null ? LinearProgressIndicator(
                        value: bookInfo.downloadProgress == 0.0 ? null : bookInfo.downloadProgress,
                      ) : Container(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
