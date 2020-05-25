import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServerStatusChecker extends StatefulWidget {
  const ServerStatusChecker({Key key}) : super(key: key);

  @override
  ServerStatusCheckerState createState() => ServerStatusCheckerState();
}

class ServerStatusCheckerState extends State<ServerStatusChecker> {
  Error _error;
  Map<String, dynamic> _serverStatus;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _error = null;
      _serverStatus = null;
    });

    Dio dioForCheck = Dio();
    Uri uri = Uri.https(
      'api.downfor.cloud',
      '/httpcheck/${ProxyHttpClient().getHostAddress()}',
    );
    try {
      var response = await dioForCheck.getUri(
        uri,
        options: Options(responseType: ResponseType.json),
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        _serverStatus = response.data;
      }
    } catch (e) {
      _error = e;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_serverStatus == null && _error == null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: DsCircularProgressIndicator(),
                ),
              ),
            if (_serverStatus != null && _serverStatus['isDown'] == false)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  FontAwesomeIcons.check,
                  color: Colors.green,
                  size: 28,
                ),
              ),
            if (_serverStatus != null && _serverStatus['isDown'] == true)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  FontAwesomeIcons.ban,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  FontAwesomeIcons.question,
                  color: Theme.of(context).disabledColor,
                  size: 30,
                ),
              ),
          ],
        ),
        title: Text('Состояние сайта:'),
        subtitle: Text(
          _serverStatus != null
              ? _serverStatus['statusText']
              : (_error != null ? 'Неизвестно' : 'Проверка...'),
        ),
        trailing: IconButton(
          icon: Icon(
            FontAwesomeIcons.redoAlt,
          ),
          tooltip: 'Обновить информацию',
          color: Theme.of(context).iconTheme.color,
          onPressed: _serverStatus != null || _error != null ? _check : null,
        ),
      ),
    );
  }
}
