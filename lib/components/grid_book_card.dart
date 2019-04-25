import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/book_list_builder/show_download_format_mbs.dart';
import 'package:flibusta/utils/text_to_icons.dart';
import 'package:flutter/material.dart';

class GridBookCard extends StatefulWidget {
  final List<BookCard> data;
  final GlobalKey<ScaffoldState> scaffoldKey;

  GridBookCard({Key key, this.data, this.scaffoldKey}) : super(key: key);

  _GridBookCardState createState() => _GridBookCardState();
}

class _GridBookCardState extends State<GridBookCard> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
          ),
        ), // это задний фон
        Scrollbar(
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: widget.data == null ? 0 : widget.data.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor),
                    child: Column(
                      children: <Widget>[
                        GridBookCardRow(
                          rowName: 'Название произведения',
                          value: widget.data[index].title,
                        ),
                        GridBookCardRow(
                          rowName: 'Автор(-ы)',
                          value: widget.data[index].authors,
                        ),
                        GridBookCardRow(
                          rowName: 'Перевод',
                          value: widget.data[index].translators,
                        ),
                        GridBookCardRow(
                          rowName: 'Жанр произведения',
                          value: widget.data[index].genres,
                        ),
                        GridBookCardRow(
                          rowName: 'Из серии произведений',
                          value: widget.data[index].sequenceTitle,
                        ),
                        GridBookCardRow(
                          rowName: 'Размер книги',
                          value: widget.data[index].size,
                        ),
                        widget.data[index].downloadFormats != null &&
                                widget.data[index].downloadFormats.isNotEmpty
                            ? ListTile(
                                leading:
                                    widget.data[index].downloadProgress == null
                                        ? Tooltip(
                                            message: "Форматы файлов",
                                            child: Icon(Icons.file_download))
                                        : CircularProgressIndicator(
                                            value: widget.data[index]
                                                        .downloadProgress ==
                                                    0.0
                                                ? null
                                                : widget.data[index]
                                                    .downloadProgress),
                                title: Text(
                                  widget.data[index].downloadFormats.toString(),
                                  style: _biggerFont,
                                ),
                              )
                            : Container(),
                        ButtonTheme.bar(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              FlatButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                child: Text("ПОДРОБНЕЕ",
                                    style: TextStyle(fontSize: 20.0)),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BookPage(
                                            bookId: widget.data[index].id,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              FlatButton(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "СКАЧАТЬ",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                onPressed:
                                    widget.data[index].downloadProgress != null
                                        ? null
                                        : () async {
                                            var downloadFormat =
                                                await showDownloadFormatMBS(
                                                    widget.scaffoldKey,
                                                    widget.data[index]);
                                            if (downloadFormat == null) {
                                              return;
                                            }

                                            var _bookBloc =
                                                BookBloc(widget.data[index].id);

                                            await _bookBloc.downloadBook(
                                              downloadFormat,
                                              widget.scaffoldKey,
                                              (downloadProgress) {
                                                setState(() {
                                                  widget.data[index]
                                                          .downloadProgress =
                                                      downloadProgress;
                                                });
                                              },
                                            );

                                            _bookBloc.dispose();
                                          },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class GridBookCardRow extends StatelessWidget {
  final String rowName;
  final dynamic value;

  const GridBookCardRow({Key key, @required this.rowName, @required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null || value.isEmpty) {
      return Container();
    }

    return ListTile(
      leading: Tooltip(
        message: rowName,
        preferBelow: false,
        child: Icon(gridRowNameToIcon(rowName)),
      ),
      title: Text(
        value.toString(),
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}
