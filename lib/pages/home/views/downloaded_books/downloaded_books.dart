import 'dart:async';
import 'dart:io';

import 'package:flibusta/blocs/home_grid/components/grid_cards.dart';
import 'package:flibusta/components/loading_indicator.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class DownloadedBooksView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final StreamController<int> selectedNavItemController;

  const DownloadedBooksView({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  _DownloadedBooksViewState createState() => _DownloadedBooksViewState();
}

class _DownloadedBooksViewState extends State<DownloadedBooksView> {
  StreamController<List<BookCard>> downloadedBooksController;

  @override
  void initState() {
    super.initState();
    downloadedBooksController = StreamController<List<BookCard>>();
    LocalStorage().getDownloadedBooks().then((downloadedBooks) {
      downloadedBooksController.add(downloadedBooks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: Text('Скачанные книги'),
      ),
      body: StreamBuilder<List<BookCard>>(
        stream: downloadedBooksController.stream,
        builder: (context, downloadedBooksSnapshot) {
          if (!downloadedBooksSnapshot.hasData) {
            return LoadingIndicator();
          }
          if (downloadedBooksSnapshot.data.isEmpty) {
            return Center(
              child: Text(
                'Пусто',
                style: Theme.of(context).textTheme.display1,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              var downloadedBooks = await LocalStorage().getDownloadedBooks();
              downloadedBooksController.add(downloadedBooks);
            },
            child: Scrollbar(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4),
                itemCount: downloadedBooksSnapshot.data.length,
                itemBuilder: (context, index) {
                  var bookCardData = downloadedBooksSnapshot.data[index];
                  return Card(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Column(
                          children: [
                            GridCardRow(
                              rowName: 'Название произведения',
                              value: bookCardData.title,
                            ),
                            GridCardRow(
                              rowName: 'Автор(-ы)',
                              value: bookCardData.authors,
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: <Widget>[
                                GridCardRow(
                                  rowName: 'Перевод',
                                  value: bookCardData.translators,
                                ),
                                GridCardRow(
                                  rowName: 'Жанр произведения',
                                  value: bookCardData.genres,
                                ),
                                GridCardRow(
                                  rowName: 'Из серии произведений',
                                  value: bookCardData.sequenceTitle,
                                ),
                                GridCardRow(
                                  rowName: 'Размер книги',
                                  value: bookCardData.size,
                                ),
                                GridCardRow(
                                  rowName: 'Путь к файлу',
                                  value: bookCardData.localPath,
                                ),
                              ],
                            ),
                          ),
                          ButtonTheme.bar(
                            child: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder(
                                  future: File(bookCardData.localPath).exists(),
                                  builder: (context, bookFileExistsSnapshot) {
                                    if (bookFileExistsSnapshot.data != true) {
                                      return Container();
                                    }
                                    return FlatButton(
                                      child: Text('Открыть'),
                                      onPressed: () =>
                                          OpenFile.open(bookCardData.localPath),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: HomeBottomNavBar(
        key: Key('HomeBottomNavBar'),
        index: 2,
        onTap: (index) {
          widget.selectedNavItemController.add(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    downloadedBooksController?.close();
    super.dispose();
  }
}
