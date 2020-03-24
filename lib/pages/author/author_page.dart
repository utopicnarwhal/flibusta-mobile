import 'dart:ui';

import 'package:flibusta/blocs/grid/grid_data/components/full_info_card.dart';
import 'package:flibusta/blocs/grid/grid_data/components/grid_data_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/authorInfo.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/cupertino.dart';
import 'package:utopic_toast/utopic_toast.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';

class AuthorPage extends StatefulWidget {
  static const routeName = "/author_page";

  final int authorId;

  const AuthorPage({Key key, this.authorId}) : super(key: key);
  @override
  _AuthorPageState createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AuthorInfo authorInfo;

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
    Widget body;

    if (authorInfo == null) {
      body = Center(
        child: DsCircularProgressIndicator(),
      );
    } else {
      body = ListView.builder(
        physics: kBouncingAlwaysScrollableScrollPhysics,
        shrinkWrap: true,
        addSemanticIndexes: false,
        itemCount: authorInfo.books.length,
        itemBuilder: (context, index) {
          List<String> genresStrings =
              authorInfo.books[index]?.genres?.list?.map((genre) {
            return genre.values?.first;
          })?.toList();
          var score = authorInfo.books[index]?.score;

          return GridDataTile(
            index: index,
            isFirst: false,
            isLast: false,
            title: authorInfo.books[index].tileTitle,
            subtitle: authorInfo.books[index].tileSubtitle,
            genres: genresStrings,
            score: score,
            onTap: () {
              LocalStorage().addToLastOpenBooks(authorInfo.books[index]);
              Navigator.of(context).pushNamed(
                BookPage.routeName,
                arguments: authorInfo.books[index].id,
              );
            },
            onLongPress: () {
              showCupertinoModalPopup(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                context: context,
                builder: (context) {
                  return Center(
                    child: FullInfoCard<BookCard>(
                      data: authorInfo.books[index],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: DsAppBar(
        title: Text(authorInfo?.name ?? 'Загрузка...'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: body,
    );
  }

  Future<AuthorInfo> getAuthorInfo(int authorId) async {
    AuthorInfo result;

    try {
      var queryParams = {
        '': '',
      };

      Uri url = Uri.https(
        ProxyHttpClient().getHostAddress(),
        "/a/" + authorId.toString(),
      );

      var response = await ProxyHttpClient().getDio().getUri(url);

      result = parseHtmlFromAuthorInfo(response.data, authorId);
    } on DsError catch (dsError) {
      ToastManager().showToast(
        'Не удалось получить данные об авторе',
        action: ToastAction(
          label: "Попробовать ещё раз",
          onPressed: (_) {
            getAuthorInfo(widget.authorId).then((response) {
              setState(() {
                authorInfo = response;
              });
            });
          },
        ),
      );
    }

    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
