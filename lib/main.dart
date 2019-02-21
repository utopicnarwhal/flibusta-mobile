import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flutter/material.dart';
import './route.dart';

main() async {
  ProxyHttpClient().setProxy(await LocalStore().getActualProxy());
  ProxyHttpClient().setFlibustaHostAddress(await LocalStore().getFlibustaHostAddress());
  runApp(FlibustaApp());
}