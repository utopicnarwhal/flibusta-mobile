import 'package:dio/dio.dart';
import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/model/authorInfo.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/book_list_builder/show_download_format_mbs.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthorPage extends StatefulWidget {
  final int authorId;

  const AuthorPage({Key key, this.authorId}): super(key: key);
  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  Dio _dio = ProxyHttpClient().getDio();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AuthorInfo authorInfo;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();

    getAuthorInfo(widget.authorId).then((response) {
      setState(() {
        authorInfo = response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(authorInfo.name ?? 'Загрузка...'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: authorInfo.books == null ? 0 : authorInfo.books.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Tooltip(message: "Название произведения", preferBelow: false, child: Icon(Icons.title)),
                      title: Text(authorInfo.books[index].title, style: _biggerFont,),
                    ),
                    authorInfo.books[index].translators != null && authorInfo.books[index].translators.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Перевод", preferBelow: false, child: Icon(Icons.translate)),
                      title: Text(authorInfo.books[index].translators.toString(), style: _biggerFont,),
                    ) : Container(),
                    authorInfo.books[index].genres != null && authorInfo.books[index].genres.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Жанр произведения", preferBelow: false, child: Icon(FontAwesomeIcons.americanSignLanguageInterpreting)),
                      title: Text(authorInfo.books[index].genres.toString().replaceAll(RegExp(r'(\[|\])'), ""), style: _biggerFont,),
                    ) : Container(),
                    authorInfo.books[index].sequenceId != null ? ListTile(
                      leading: Tooltip(message: "Из серии произведений", preferBelow: false, child: Icon(Icons.collections_bookmark)),
                      title: Text(authorInfo.books[index].sequenceTitle, style: _biggerFont,),
                    ) : Container(),
                    ListTile(
                      leading: Tooltip(message: "Размер книги", preferBelow: false, child: Icon(Icons.data_usage)),
                      title: Text(authorInfo.books[index].size, style: _biggerFont,),
                    ),
                    authorInfo.books[index].downloadFormats.isNotEmpty ? ListTile(
                      leading: authorInfo.books[index].downloadProgress == null ? Tooltip(message: "Форматы файлов", child: Icon(Icons.file_download)) : 
                        CircularProgressIndicator(value: authorInfo.books[index].downloadProgress == 0.0 ? null : authorInfo.books[index].downloadProgress),
                      title: Text(authorInfo.books[index].downloadFormats.toString(), style: _biggerFont,),
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
                                  builder: (BuildContext context) => BookPage(bookId: authorInfo.books[index].id,),
                                ),
                              );
                            },
                          ),
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Text("СКАЧАТЬ", style: TextStyle(fontSize: 20.0)),
                            onPressed: authorInfo.books[index].downloadProgress != null ? null : () async {
                              var downloadFormat = await showDownloadFormatMBS(_scaffoldKey, authorInfo.books[index]);
                              if (downloadFormat == null) {
                                return;
                              }

                              var _bookBloc = BookBloc(authorInfo.books[index].id);

                              await _bookBloc.downloadBook(downloadFormat,
                                _scaffoldKey,
                                (downloadProgress) {
                                  setState(() {
                                    authorInfo.books[index].downloadProgress = downloadProgress;
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

  Future<AuthorInfo> getAuthorInfo(int authorId) async {
    authorInfo = AuthorInfo(id: authorId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/a/" + authorId.toString());
      var response = await _dio.getUri(url);

      authorInfo = parseHtmlFromAuthorInfo(response.data, authorId);
    } catch(e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Не удалось получить данные об авторе"),
          action: SnackBarAction(
            label: "Попробовать ещё раз",
            onPressed: () {
              getAuthorInfo(widget.authorId).then((response) {
                setState(() {
                  authorInfo = response;
                });
              });
            },
          ),
        )
      );
      print(e);
    }

    return authorInfo;
  }

  @override
  void dispose() {
    super.dispose();
  }
}