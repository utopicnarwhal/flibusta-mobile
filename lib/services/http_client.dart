import 'dart:io';
import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flibusta/model/connectionCheckResult.dart';
import 'package:flutter/foundation.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:path_provider/path_provider.dart';

class ProxyHttpClient {
  static final ProxyHttpClient _httpClientSingleton =
      ProxyHttpClient._internal();

  factory ProxyHttpClient() {
    _httpClientSingleton?._init();
    return _httpClientSingleton;
  }
  ProxyHttpClient._internal();

  static BaseOptions defaultDioOptions = BaseOptions(
    connectTimeout: 10000,
    receiveTimeout: 6000,
  );
  Dio _dio = Dio(defaultDioOptions);

  PersistCookieJar _persistCookieJar;
  CookieManager _cookieManager;

  String _proxyHostPort = '';
  Uri _proxyApiUri = Uri.http('pubproxy.com', '/api/proxy', {
    'https': 'true',
    'not_country': 'RU',
    'LEVEL': 'elite',
    'format': 'txt',
  });

  String _hostAddress = '';

  Dio getDio() {
    return _dio;
  }

  Future<void> initCookieJar() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _persistCookieJar = PersistCookieJar(dir: appDocPath + '/.cookies/');

    _cookieManager = CookieManager(_persistCookieJar);
    _dio.interceptors.add(_cookieManager);
  }

  void _init() {
    if (_dio.interceptors.isNotEmpty) {
      return;
    }

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          if (kReleaseMode == false) {
            print('Send request：path = ${options.path}');
          }
        },
        onError: (dioError) {
          return DsError.fromDioError(dioError: dioError);
        },
      ),
      if (_cookieManager != null) _cookieManager,
    ]);
  }

  Future<void> setProxy(String hostPort) async {
    if (_proxyHostPort == hostPort) {
      return;
    }
    _proxyHostPort = hostPort;
    var newDio = Dio(defaultDioOptions);

    (newDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      if (hostPort == '') {
        client.findProxy = null;
        return;
      }
      client.findProxy = (url) {
        return HttpClient.findProxyFromEnvironment(url, environment: {
          'HTTPS_PROXY': hostPort,
          'HTTP_PROXY': hostPort,
          'https_proxy': hostPort,
          'http_proxy': hostPort
        });
      };
    };
    _dio.clear();
    _dio.close();
    _dio = newDio;
    _init();
  }

  String getActualProxy() {
    return _proxyHostPort;
  }

  void setHostAddress(String hostAddress) {
    _hostAddress = hostAddress;
  }

  String getHostAddress() {
    return _hostAddress;
  }

  Future<ConnectionCheckResult> connectionCheck(
    String hostPort, {
    CancelToken cancelToken,
  }) async {
    var dioForConnectionCheck = Dio(
      BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 6000,
        responseType: ResponseType.plain,
      ),
    );
    if (hostPort != '') {
      (dioForConnectionCheck.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (HttpClient client) {
        client.findProxy = (url) {
          return HttpClient.findProxyFromEnvironment(
            url,
            environment: {
              'HTTPS_PROXY': hostPort,
              'HTTP_PROXY': hostPort,
              'https_proxy': hostPort,
              'http_proxy': hostPort
            },
          );
        };
      };
    }

    var result = ConnectionCheckResult(ping: -1);
    var stopWatch = new Stopwatch()..start();

    try {
      var request = dioForConnectionCheck.getUri(
        Uri.https(getHostAddress(), '/'),
        cancelToken: cancelToken,
      );

      var response = await request;
      stopWatch.stop();

      switch (response.statusCode) {
        case 200:
          result.ping = stopWatch.elapsedMilliseconds;
          break;
        default:
          result.ping = -1;
      }
    } on DioError catch (dioError) {
      stopWatch.stop();
      result.ping = -1;
      result.error = DsError.fromDioError(dioError: dioError);
    }
    dioForConnectionCheck.clear();
    dioForConnectionCheck.close();
    return result;
  }

  Future<List<String>> getNewProxies() async {
    var dioForGetProxyAPI = Dio(
      BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ),
    );
    List<String> result = [];

    try {
      var request = dioForGetProxyAPI.getUri(
        _proxyApiUri,
      );
      var response = await request;

      if (response.statusCode != 200 || response.data == null) {
        return [];
      }

      if (response.data is String) {
        result = (response.data as String).split('\n');
      }
      print(result);
      return result;
    } catch (error) {
      print(error);
    }
    dioForGetProxyAPI.close();
    return result;
  }

  void signOut() {
    _persistCookieJar.deleteAll();
  }

  String getCookies() {
    return _persistCookieJar
        .loadForRequest(Uri.https(getHostAddress(), ''))
        .toString();
  }

  bool isAuthorized() {
    return _persistCookieJar
        .loadForRequest(Uri.https(getHostAddress(), ''))
        .isNotEmpty;
  }
}
