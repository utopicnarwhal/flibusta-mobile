import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/home/book_list_builder/show_download_format_mbs.dart';
import 'package:flibusta/services/book_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flibusta/pages/book/book_page.dart';

class BookListBuilder extends StatefulWidget {
  final List<BookCard> data;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BookListBuilder({Key key, this.data, this.scaffoldKey}): super(key: key);
  
  @override
  _BookListBuilderState createState() => _BookListBuilderState();
}

class _BookListBuilderState extends State<BookListBuilder> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: widget.data == null ? 0 : widget.data.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Tooltip(message: "Название произведения", preferBelow: false, child: Icon(Icons.title)),
                      title: Text(widget.data[index].title, style: _biggerFont,),
                    ),
                    widget.data[index].authors.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Автор(-ы)", preferBelow: false, child: Icon(Icons.assignment_ind)),
                      title: Text(widget.data[index].authors.toString(), style: _biggerFont,),
                    ) : Container(),
                    widget.data[index].translators != null && widget.data[index].translators.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Перевод", preferBelow: false, child: Icon(Icons.translate)),
                      title: Text(widget.data[index].translators.toString(), style: _biggerFont,),
                    ) : Container(),
                    widget.data[index].genres != null && widget.data[index].genres.isNotEmpty ? ListTile(
                      leading: Tooltip(message: "Жанр произведения", preferBelow: false, child: Icon(FontAwesomeIcons.americanSignLanguageInterpreting)),
                      title: Text(widget.data[index].genres.toString().replaceAll(RegExp(r'(\[|\])'), ""), style: _biggerFont,),
                    ) : Container(),
                    widget.data[index].sequenceId != null ? ListTile(
                      leading: Tooltip(message: "Из серии произведений", preferBelow: false, child: Icon(Icons.collections_bookmark)),
                      title: Text(widget.data[index].sequenceTitle, style: _biggerFont,),
                    ) : Container(),
                    ListTile(
                      leading: Tooltip(message: "Размер книги", preferBelow: false, child: Icon(Icons.data_usage)),
                      title: Text(widget.data[index].size, style: _biggerFont,),
                    ),
                    widget.data[index].downloadFormats.isNotEmpty ? ListTile(
                      leading: widget.data[index].downloadProgress == null ? Tooltip(message: "Форматы файлов", child: Icon(Icons.file_download)) : 
                        CircularProgressIndicator(value: widget.data[index].downloadProgress == 0.0 ? null : widget.data[index].downloadProgress),
                      title: Text(widget.data[index].downloadFormats.toString(), style: _biggerFont,),
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
                                  builder: (BuildContext context) => BookPage(bookId: widget.data[index].id,),
                                ),
                              );
                            },
                          ),
                          FlatButton(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Text("СКАЧАТЬ", style: TextStyle(fontSize: 20.0)),
                            onPressed: widget.data[index].downloadProgress != null ? null : () async {
                              var downloadFormat = await showDownloadFormatMBS(widget.scaffoldKey, widget.data[index]);
                              if (downloadFormat == null) {
                                return;
                              }

                              BookService.downloadBook(widget.data[index].id, downloadFormat,
                                (downloadProgress) {
                                  setState(() {
                                    widget.data[index].downloadProgress = downloadProgress;
                                  });
                                },
                                (alertText, alertDuration) {
                                  widget.scaffoldKey.currentState.hideCurrentSnackBar();
                                  if (alertText.isEmpty) {
                                    return;
                                  }

                                  widget.scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(alertText),
                                      duration: alertDuration,
                                    )
                                  );
                              });
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
        },
      ),
    );
  }
}