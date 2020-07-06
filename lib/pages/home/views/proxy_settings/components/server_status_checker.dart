import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
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
  DioError _error;
  Map<String, dynamic> _serverStatus;
  Dio _dioForCheck;

  @override
  void initState() {
    super.initState();

    _dioForCheck = Dio();
    _dioForCheck.interceptors.add(CookieManager(CookieJar()));

    _check();
  }

  Future<void> _check() async {
    setState(() {
      _error = null;
      _serverStatus = null;
    });

    try {
      var response = await _dioForCheck.get(
        'https://api.downfor.cloud/httpcheck/${ProxyHttpClient().getHostAddress()}',
        options: Options(
          headers: {
            'user-agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36',
            'accept-language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          },
        ),
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        _serverStatus = response.data;
      }
    } on DioError catch (dioError) {
      _error = dioError;
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
