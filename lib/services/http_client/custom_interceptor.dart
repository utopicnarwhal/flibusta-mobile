import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flutter/foundation.dart';

class CustomInterceptor extends Interceptor {
  final bool printRequests;

  CustomInterceptor({this.printRequests = true});

  @override
  Future onRequest(RequestOptions options) async {
    if (options.path.contains(kFlibustaOnionUrl)) {
      options.path = options.path.replaceFirst('https://', 'http://');
    }

    if (printRequests && !kReleaseMode && kPrintRequests) {
      print('Send request：path = ${options.path}');
    }
  }

  @override
  Future onResponse(Response response) async {}

  @override
  Future onError(DioError dioError) async {
    if (dioError?.message
            ?.contains('Proxy failed to establish tunnel (302 Found)') ==
        true) {
      return ProxyHttpClient().getDio().requestUri(
            dioError.request.uri,
            data: dioError.request.data,
            options: Options(
              method: dioError.request.method,
              responseType: dioError.request.responseType,
              contentType: dioError.request.contentType,
            ),
            onReceiveProgress: dioError.request.onReceiveProgress,
            onSendProgress: dioError.request.onSendProgress,
            cancelToken: dioError.request.cancelToken,
          );
    }
    return DsError.fromDioError(dioError: dioError);
  }
}
