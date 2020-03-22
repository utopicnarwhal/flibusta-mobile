import 'package:dio/dio.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/model/authorInfo.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:utopic_toast/utopic_toast.dart';
import 'package:flutter/material.dart';

class AuthorPage extends StatefulWidget {
  static const routeName = "/AuthorPage";

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
    return Scaffold(
      key: _scaffoldKey,
      appBar: DsAppBar(
        title: Text(authorInfo.name ?? 'Загрузка...'),
      ),
      // body: GridDataScreen(
      //   scaffoldKey: _scaffoldKey,
      //   data: authorInfo.books,
      // ),
    );
  }

  Future<AuthorInfo> getAuthorInfo(int authorId) async {
    authorInfo = AuthorInfo(id: authorId);
    try {
      Uri url = Uri.https(
        ProxyHttpClient().getHostAddress(),
        "/a/" + authorId.toString(),
      );

      var response = await ProxyHttpClient().getDio().getUri(url);

      authorInfo = parseHtmlFromAuthorInfo(response.data, authorId);
    } catch (e) {
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
      print(e);
    }

    return authorInfo;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
