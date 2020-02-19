import 'dart:async';
import 'dart:io';

import 'package:flibusta/blocs/home_grid/components/grid_cards.dart';
import 'package:flibusta/components/loading_indicator.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
  BehaviorSubject<List<BookCard>> downloadedBooksController;

  @override
  void initState() {
    super.initState();
    downloadedBooksController = BehaviorSubject<List<BookCard>>();
    LocalStorage().getDownloadedBooks().then((downloadedBooks) {
      downloadedBooksController.add(downloadedBooks);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'Скачанные книги',
          style: Theme.of(context).textTheme.display1.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.body1.color,
              ),
        ),
      ),
      SizedBox(height: 8),
    ];

    return Scaffold(
      key: widget.scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            var downloadedBooks = await LocalStorage().getDownloadedBooks();
            downloadedBooksController.add(downloadedBooks);
          },
          child: StreamBuilder<List<BookCard>>(
            stream: downloadedBooksController,
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
              return Scrollbar(
                child: ListView.builder(
                  physics: kBouncingAlwaysScrollableScrollPhysics,
                  addSemanticIndexes: false,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 42),
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
                            ButtonBarTheme(
                              data: ButtonBarThemeData(
                                layoutBehavior:
                                    ButtonBarLayoutBehavior.constrained,
                              ),
                              child: ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder(
                                    future:
                                        File(bookCardData.localPath).exists(),
                                    builder: (context, bookFileExistsSnapshot) {
                                      if (bookFileExistsSnapshot.data != true) {
                                        return Container();
                                      }
                                      return FlatButton(
                                        child: Text('Открыть'),
                                        onPressed: () => FileUtils.openFile(
                                          bookCardData.localPath,
                                        ),
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
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        key: Key('HomeBottomNavBar'),
        index: 2,
        selectedNavItemController: widget.selectedNavItemController,
      ),
    );
  }

  @override
  void dispose() {
    downloadedBooksController?.close();
    super.dispose();
  }
}
