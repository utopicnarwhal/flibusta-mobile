import 'package:dio/dio.dart';
import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/model/sequenceInfo.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/book_list_builder/show_download_format_mbs.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SequencePage extends StatefulWidget {
  static const routeName = "/SequencePage";

  final int sequenceId;

  const SequencePage({Key key, this.sequenceId}): super(key: key);
  @override
  _SequencePageState createState() => _SequencePageState();
}

class _SequencePageState extends State<SequencePage> {
  Dio _dio = ProxyHttpClient().getDio();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  SequenceInfo sequenceInfo;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();

    getSequenceInfo(widget.sequenceId).then((response) {
      setState(() {
        sequenceInfo = response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(sequenceInfo.title ?? 'Загрузка...'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: sequenceInfo.books == null ? 0 : sequenceInfo.books.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Tooltip(message: "Название произведения", preferBelow: false, child: Icon(Icons.title)),
                      title: Text(sequenceInfo.books[index].title, style: _biggerFont,),
                    ),
                    sequenceInfo.books[index].translators != null && sequenceInfo.books[index].translators.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Перевод", preferBelow: false, child: Icon(Icons.translate)),
                      title: Text(sequenceInfo.books[index].translators.toString(), style: _biggerFont,),
                    ) : Container(),
                    sequenceInfo.books[index].genres != null && sequenceInfo.books[index].genres.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Жанр произведения", preferBelow: false, child: Icon(FontAwesomeIcons.americanSignLanguageInterpreting)),
                      title: Text(sequenceInfo.books[index].genres.toString().replaceAll(RegExp(r'(\[|\])'), ""), style: _biggerFont,),
                    ) : Container(),
                    sequenceInfo.books[index].sequenceId != null ? ListTile(
                      leading: Tooltip(message: "Из серии произведений", preferBelow: false, child: Icon(Icons.collections_bookmark)),
                      title: Text(sequenceInfo.books[index].sequenceTitle, style: _biggerFont,),
                    ) : Container(),
                    ListTile(
                      leading: Tooltip(message: "Размер книги", preferBelow: false, child: Icon(Icons.data_usage)),
                      title: Text(sequenceInfo.books[index].size, style: _biggerFont,),
                    ),
                    sequenceInfo.books[index].downloadFormats.isNotEmpty ? ListTile(
                      leading: sequenceInfo.books[index].downloadProgress == null ? Tooltip(message: "Форматы файлов", child: Icon(Icons.file_download)) : 
                        CircularProgressIndicator(value: sequenceInfo.books[index].downloadProgress == 0.0 ? null : sequenceInfo.books[index].downloadProgress),
                      title: Text(sequenceInfo.books[index].downloadFormats.toString(), style: _biggerFont,),
                    ) : Container(),
                    ButtonTheme.bar(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Text("ПОДРОБНЕЕ", style: TextStyle(fontSize: 20.0)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => BookPage(bookId: sequenceInfo.books[index].id,),
                                ),
                              );
                            },
                          ),
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Text("СКАЧАТЬ", style: TextStyle(fontSize: 20.0)),
                            onPressed: sequenceInfo.books[index].downloadProgress != null ? null : () async {
                              var downloadFormat = await showDownloadFormatMBS(_scaffoldKey, sequenceInfo.books[index]);
                              if (downloadFormat == null) {
                                return;
                              }

                              var _bookBloc = BookBloc(sequenceInfo.books[index].id);

                              await _bookBloc.downloadBook(downloadFormat,
                                _scaffoldKey,
                                (downloadProgress) {
                                  setState(() {
                                    sequenceInfo.books[index].downloadProgress = downloadProgress;
                                  });
                                },
                              );

                              _bookBloc.dispose();
                            },
                          )
                        ],
                      )
                    )
                  ],
                )
              ),
              Divider(height: 1,)
            ]
          );
        }
      ),
    );
  }

  Future<SequenceInfo> getSequenceInfo(int sequenceId) async {
    sequenceInfo = SequenceInfo(id: sequenceId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/s/" + sequenceId.toString());
      var response = await _dio.getUri(url);

      sequenceInfo = parseHtmlFromSequenceInfo(response.data, sequenceId);
    } catch(e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Не удалось получить данные о серии"),
          action: SnackBarAction(
            label: "Попробовать ещё раз",
            onPressed: () {
              getSequenceInfo(widget.sequenceId).then((response) {
                setState(() {
                  sequenceInfo = response;
                });
              });
            },
          ),
        )
      );
      print(e);
    }

    return sequenceInfo;
  }
}