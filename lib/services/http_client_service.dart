import "dart:io";
import 'dart:async';
import 'package:dio/dio.dart';

class ProxyHttpClient {
  static final ProxyHttpClient proxyDio = ProxyHttpClient._internal();

  factory ProxyHttpClient() {
    return proxyDio;
  }
  ProxyHttpClient._internal();

  static BaseOptions defaultDioOptions = BaseOptions(
    connectTimeout: 10000,
    receiveTimeout: 6000,
  );
  Dio _dio = Dio(defaultDioOptions);
  String _proxyHostPort = "";
  Uri _proxyApiUri = Uri.http('pubproxy.com', '/api/proxy', {
    'api': 'ZU9KYkwrMGtXcVhBN2tqbzBwTjFUQT09',
    'https': 'true',
    'not_country': 'RU',
    'format': 'txt',
  });

  String _flibustaHostAddress = 'flibusta.is';

  Dio getDio() {
    return _dio;
  }

  void setProxy(String hostPort) {
    _proxyHostPort = hostPort;

    if (hostPort == "") {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.findProxy = null;
      };
      return;
    }

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.findProxy = (url) {
        return HttpClient.findProxyFromEnvironment(url, environment: {
          "HTTPS_PROXY": hostPort,
          "HTTP_PROXY": hostPort,
          "https_proxy": hostPort,
          "http_proxy": hostPort
        });
      };
    };
  }

  String getActualProxy() {
    return _proxyHostPort;
  }

  void setFlibustaHostAddress(String hostAddress) {
    _flibustaHostAddress = hostAddress;
  }

  String getFlibustaHostAddress() {
    return _flibustaHostAddress;
  }

  Future<int> connectionCheck(String hostPort, {CancelToken cancelToken}) async {
    var dioForConnectionCheck = Dio();
    if (hostPort != "") {
      (dioForConnectionCheck.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (HttpClient client) {
        client.findProxy = (url) {
          return HttpClient.findProxyFromEnvironment(
            url,
            environment: {
              "HTTPS_PROXY": hostPort,
              "HTTP_PROXY": hostPort,
              "https_proxy": hostPort,
              "http_proxy": hostPort
            },
          );
        };
      };
    }

    var result = -1;
    var stopWatch = new Stopwatch()..start();

    try {
      var request = dioForConnectionCheck.getUri(
        Uri.https(getFlibustaHostAddress(), "/"),
        options: Options(
          connectTimeout: 10000,
          receiveTimeout: 6000,
        ),
        cancelToken: cancelToken,
      );

      var response = await request;
      stopWatch.stop();

      switch (response.statusCode) {
        case 200:
          result = stopWatch.elapsedMilliseconds;
          break;
        default:
          result = -1;
      }
    } catch (error) {
      stopWatch.stop();
      result = -1;
      print(error);
    }
    dioForConnectionCheck.clear();
    return result;
  }

  Future<List<String>> getNewProxies() async {
    var dioForGetProxyAPI = Dio();
    List<String> result = [];

    try {
      var request = dioForGetProxyAPI.getUri(
        _proxyApiUri,
        options: Options(
          connectTimeout: 5000,
          receiveTimeout: 3000,
        ),
      );
      var response = await request;

      if (response.statusCode != 200 ||
          response.data == null) {
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
    dioForGetProxyAPI.clear();
    return result;
  }
}
