import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flibusta/constants.dart';

part 'my_http_impl.dart';

typedef OnHttpClientCreate = dynamic Function(HttpClient client);

/// The default HttpClientAdapter for Dio.
class SocksHttpClientAdapter extends DefaultHttpClientAdapter {
  /// [Dio] will create HttpClient when it is needed.
  /// If [onHttpClientCreate] is provided, [Dio] will call
  /// it when a HttpClient created.
  OnHttpClientCreate onHttpClientCreate;

  HttpClient _defaultHttpClient;

  bool _closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>> requestStream,
    Future cancelFuture,
  ) async {
    if (_closed) {
      throw Exception(
          "Can't establish connection after [HttpClientAdapter] closed!");
    }
    var uri = options.uri;

    if (options.uri.host == kFlibustaOnionUrl) {
      uri = Uri.http(kFlibustaOnionUrl, uri.path, uri.queryParameters);
    }

    var _httpClient = _configHttpClient(cancelFuture, options.connectTimeout);
    Future requestFuture = _httpClient.openUrl(options.method, uri);

    void _throwConnectingTimeout() {
      throw DioError(
        request: options,
        error: 'Connecting timed out [${options.connectTimeout}ms]',
        type: DioErrorType.CONNECT_TIMEOUT,
      );
    }

    HttpClientRequest request;
    try {
      request = await requestFuture;
      //Set Headers
      options.headers.forEach((k, v) => request.headers.set(k, v));
    } on SocketException catch (e) {
      if (e.message.contains('timed out')) _throwConnectingTimeout();
      rethrow;
    }

    request.followRedirects = options.followRedirects;
    request.maxRedirects = options.maxRedirects;

    if (options.method != 'GET' && requestStream != null) {
      // Transform the request data
      await request.addStream(requestStream);
    }
    Future future = request.close();
    if (options.connectTimeout > 0) {
      future = future.timeout(Duration(milliseconds: options.connectTimeout));
    }
    HttpClientResponse responseStream;
    try {
      responseStream = await future;
    } on TimeoutException {
      _throwConnectingTimeout();
    }

    // https://github.com/dart-lang/co19/issues/383
    var stream =
        responseStream.transform<Uint8List>(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(Uint8List.fromList(data));
      },
    ));

    var headers = <String, List<String>>{};
    responseStream.headers.forEach((key, values) {
      headers[key] = values;
    });
    return ResponseBody(
      stream,
      responseStream.statusCode,
      headers: headers,
      isRedirect: responseStream.isRedirect,
      redirects: responseStream.redirects
          .map((e) => RedirectRecord(e.statusCode, e.method, e.location))
          .toList(),
      statusMessage: responseStream.reasonPhrase,
    );
  }

  HttpClient _configHttpClient(Future cancelFuture, int connectionTimeout) {
    var _connectionTimeout = connectionTimeout > 0
        ? Duration(milliseconds: connectionTimeout)
        : null;
    if (cancelFuture != null) {
      var _httpClient = _HttpClient(SecurityContext.defaultContext);
      if (onHttpClientCreate != null) {
        //user can return a HttpClient instance
        _httpClient = onHttpClientCreate(_httpClient) ?? _httpClient;
      }
      _httpClient.idleTimeout = Duration(seconds: 0);
      cancelFuture.whenComplete(() {
        Future.delayed(Duration(seconds: 0)).then((e) {
          try {
            _httpClient.close(force: true);
          } catch (e) {
            //...
          }
        });
      });
      return _httpClient..connectionTimeout = _connectionTimeout;
    } else if (_defaultHttpClient == null) {
      _defaultHttpClient = _HttpClient(SecurityContext.defaultContext);
      _defaultHttpClient.idleTimeout = Duration(seconds: 3);
      if (onHttpClientCreate != null) {
        //user can return a HttpClient instance
        _defaultHttpClient =
            onHttpClientCreate(_defaultHttpClient) ?? _defaultHttpClient;
      }
      _defaultHttpClient.connectionTimeout = _connectionTimeout;
    }
    return _defaultHttpClient;
  }

  @override
  void close({bool force = false}) {
    _closed = _closed;
    _defaultHttpClient?.close(force: force);
  }
}
