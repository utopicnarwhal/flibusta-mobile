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
  Uri _proxyApiUri = Uri.https("api.getproxylist.com", "/proxy", {
    "lastTested": "900",
    "allowsHttps": "1",
    "notCountry": "RU",
    "maxConnectTime": "6",
  });

  String _flibustaHostAddress = "flibusta.is";

  Dio getDio() {
    return _dio;
  }

  void setProxy(String hostPort) {
    _proxyHostPort = hostPort;

    if (hostPort == "") {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.findProxy = null;
      };
      return;
    }

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.findProxy = (url) {
        return HttpClient.findProxyFromEnvironment(
          url, 
          environment: {
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

  Future<int> connectionCheck(String hostPort) async {
    var dioForConnectionCheck = Dio();
    if (hostPort != "") {
      (dioForConnectionCheck.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.findProxy = (url) {
          return HttpClient.findProxyFromEnvironment(
            url, 
            environment: {
              "HTTPS_PROXY": hostPort,
              "HTTP_PROXY": hostPort,
              "https_proxy": hostPort,
              "http_proxy": hostPort
          });
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
      result = -1;
      print(error);
    }
    return result;
  }

  Future<String> getFreeWorkingProxyHost() async {
    var _result = "";
    var _newFreeProxy = "";

    while (_result == "") {
      _newFreeProxy = await getNewProxy();
      
      var latency = await connectionCheck(_newFreeProxy);
      if (latency >= 0 && latency <= 7000) {
        return _newFreeProxy;
      }
    }

    return "";
  }

  Future<String> getNewProxy() async {
    var dioForGetProxyAPI = Dio();

    try {
      var request = dioForGetProxyAPI.getUri(
        _proxyApiUri,
        options: Options(
          connectTimeout: 5000,
          receiveTimeout: 3000,
        ),
      );
      var response = await request;

      if (response.statusCode != 200 || response.data == null) {
        return "";
      }

      print(response.data);
      var ip = response.data["ip"];
      var port = response.data["port"].toString();

      return "$ip:$port";
    } catch (error) {
      print(error);
    }

    return "";
  }
}