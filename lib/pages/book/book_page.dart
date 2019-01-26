import 'dart:convert';
import 'dart:io';

import 'package:flibusta_app/services/http_client_service.dart';
import 'package:flutter/material.dart';
import '../../components/loading_indicator.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

class BookPage extends StatefulWidget {
  final int bookId;

  const BookPage({Key key, this.bookId}): super(key: key);
  @override
  BookPageState createState() => BookPageState();
}

class BookPageState extends State<BookPage> {
  HttpClient _httpClient = ProxyHttpClient().getHttpClient();
  Image coverImg;
  ImageStream coverImageStream;
  double coverImgHeight = 0;
  String bookTitle = "";
  String publishDate = "";
  String lemma = "";

  bool coverImageLoading = true;

  @override
  void initState() {
    super.initState();
    getBookInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getBookInfo() async {
    try {
      Uri url = Uri.https("flibusta.is", "/b/" + widget.bookId.toString());
      var superRealResponse = "";
      var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 5)).then((r) => r.close());
      await response.transform(utf8.decoder).listen((contents) {
        superRealResponse += contents;
      }).asFuture();
      htmldom.Document document = parse(superRealResponse);
      
      if (mounted) {
        setState(() {
          bookTitle = document.getElementById("main-wrapper")?.getElementsByClassName("title")?.first?.innerHtml ?? "";
          var publishDateStringStarts = document.body.text.indexOf("Добавлена:");
          publishDate = document.body.text.substring(publishDateStringStarts, publishDateStringStarts + 21);
          var lemmaStringStarts = document.body.text.indexOf("Аннотация") + 10;
          var lemmaStringEnds = document.body.text.indexOf("Рекомендации:") - 2;
          lemma = document.body.text.substring(lemmaStringStarts, lemmaStringEnds);
        });
      }

      var temp = document.getElementsByClassName("fb2info-content");
      if (temp.isEmpty) {
        if (mounted) {
          setState(() {
            coverImageLoading = false;
          });
        }
        return;
      }
      var temp2 = temp?.first?.nextElementSibling?.nextElementSibling;
      var temp3 = temp2?.attributes["src"];

      coverImg = Image.network("http://cn.flibusta.is" + temp3, fit: BoxFit.fitWidth);

      // if (coverImg == null && temp3 != null) {
      //   url = Uri.https("flibusta.is", temp3);
      //   response = await _httpClient.getUrl(url).timeout(Duration(seconds: 5)).then((r) => r.close());
      //   var result = List<int>();
      //   await response.listen((contents) {
      //       result.addAll(contents);
      //   }).asFuture();

      //   setState(() {
      //     coverImg = Image.memory(Uint8List.fromList(result), fit: BoxFit.fitWidth);
      //   });
      // }

      coverImageStream = coverImg.image.resolve(new ImageConfiguration());
      coverImageStream.addListener(imageStreamListener);
    } catch(e) {
      print(e);
      if (mounted) {
        setState(() {
          coverImageLoading = false;
        });
      }
    }
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
                        child: Text(bookTitle, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                      ),
                      Center(
                        child: Text(publishDate, style: TextStyle(fontSize: 18, color: Colors.grey.shade700), textAlign: TextAlign.center,),
                      ),
                      lemma.isNotEmpty ? Text("Аннотация:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),) : Container(),
                      Text(lemma, style: TextStyle(fontSize: 18),),
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
