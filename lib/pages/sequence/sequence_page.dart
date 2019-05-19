import 'package:dio/dio.dart';
import 'package:flibusta/blocs/book/book_bloc.dart';
import 'package:flibusta/components/grid_cards.dart';
import 'package:flibusta/model/sequenceInfo.dart';
import 'package:flibusta/pages/book/book_page.dart';
import 'package:flibusta/pages/home/book_list_builder/show_download_format_mbs.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SequencePage extends StatefulWidget {
  static const routeName = "/SequencePage";

  final int sequenceId;

  const SequencePage({Key key, this.sequenceId}) : super(key: key);
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
      body: GridCards(
        scaffoldKey: _scaffoldKey,
        data: sequenceInfo.books,
      ),
    );
  }

  Future<SequenceInfo> getSequenceInfo(int sequenceId) async {
    sequenceInfo = SequenceInfo(id: sequenceId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(),
          "/s/" + sequenceId.toString());
      var response = await _dio.getUri(url);

      sequenceInfo = parseHtmlFromSequenceInfo(response.data, sequenceId);
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
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
      ));
      print(e);
    }

    return sequenceInfo;
  }
}
