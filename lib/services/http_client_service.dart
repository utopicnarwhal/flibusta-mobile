import "dart:io";
import 'dart:async';
import 'package:dio/dio.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

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
  Uri _proxylistUri = Uri.https("ip-adress.com", "/proxy-list");

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
    dioForConnectionCheck.clear();
    return result;
  }

  Future<String> getWorkingProxyHost() async {
    var proxyList = [];
    var result = "";
    proxyList = await _getNewProxyList();

    for (var proxyHostPort in proxyList) {
      if (result != "") {
        break;
      }
      
      if (await connectionCheck(proxyHostPort) >= 0) {
        _proxyHostPort = proxyHostPort;
        return _proxyHostPort;
      }
    }

    return _proxyHostPort;
  }

  Future<List<dynamic>> _getNewProxyList() async {
    var proxyList = [];
    var dioForGetProxyList = Dio();

    try {
      var request = dioForGetProxyList.getUri(
        _proxylistUri,
        options: Options(
          connectTimeout: 5000,
          receiveTimeout: 3000,
        ),
      );
      var response = await request;

      if (response.statusCode != 200)
        return proxyList;

      htmldom.Document proxyListDocument = parse(response.data);

      var tbody = proxyListDocument.getElementsByTagName("tbody").first;
      if (tbody == null)
        return null;

      var trs = tbody.getElementsByTagName("tr");
      trs.forEach((tr) => proxyList.add(tr.nodes[1].text));
    } catch (error) {
      print(error);
    }

    dioForGetProxyList.clear();
    return proxyList;
  }
}