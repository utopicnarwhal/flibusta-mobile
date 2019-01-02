import './services/http_client_service.dart';
import './services/local_store_service.dart';

import 'package:flutter/material.dart';
import './route.dart';

void main() async {
  ProxyHttpClient().setProxy(await LocalStore().getActualProxy());
  runApp(FlibustaApp());
}