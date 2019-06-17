import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/route.dart';

main() async {
  LocalStorage().checkVersion();
  ProxyHttpClient().setProxy(await LocalStorage().getActualProxy());
  ProxyHttpClient().setFlibustaHostAddress(await LocalStorage().getFlibustaHostAddress());
  runApp(FlibustaApp());
}