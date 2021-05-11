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
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains(kFlibustaOnionUrl)) {
      options.path = options.path.replaceFirst('https://', 'http://');
    }

    if (printRequests && !kReleaseMode && kPrintRequests) {
      debugPrint('Send request：path = ${options.path}');
    }
    handler.next(options);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    handler.next(response);
  }

  @override
  Future onError(DioError dioError, ErrorInterceptorHandler handler) async {
    if (dioError?.message?.contains('Proxy failed to establish tunnel (302 Found)') == true) {
      return handler.resolve(
        await ProxyHttpClient().getDio().requestUri(
              dioError.requestOptions.uri,
              data: dioError.requestOptions.data,
              options: Options(
                method: dioError.requestOptions.method,
                responseType: dioError.requestOptions.responseType,
                contentType: dioError.requestOptions.contentType,
              ),
              onReceiveProgress: dioError.requestOptions.onReceiveProgress,
              onSendProgress: dioError.requestOptions.onSendProgress,
              cancelToken: dioError.requestOptions.cancelToken,
            ),
      );
    }
    return handler.next(DsError.fromDioError(dioError: dioError));
  }
}
