import "dart:io";
import 'dart:async';
import 'dart:convert';

import 'package:flibusta/services/local_store_service.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

class ProxyHttpClient {
  static final ProxyHttpClient proxyHttpClient = ProxyHttpClient._internal();

  factory ProxyHttpClient() {
    return proxyHttpClient;
  }
  ProxyHttpClient._internal();

  HttpClient _httpClient = new HttpClient();
  String _proxyHostPort = "";
  Uri _proxylistUri = new Uri.https("ip-adress.com", "/proxy-list");

  HttpClient getHttpClient() {
    return _httpClient;
  }

  void setProxy(String hostPort) {
    if (hostPort == "") {
      _proxyHostPort = "";
      _httpClient.findProxy = null;
      return;
    }

    _proxyHostPort = hostPort;
    _httpClient.findProxy = (url) {
      return HttpClient.findProxyFromEnvironment(
        url, 
        environment: {
          "HTTPS_PROXY": hostPort,
          "HTTP_PROXY": hostPort,
          "https_proxy": hostPort,
          "http_proxy": hostPort
      });
    };
  }

  String getActualProxy() {
    return _proxyHostPort;
  }

  Future<int> connectionCheck(String hostPort) async {
    var httpClientForCheck = new HttpClient();
    httpClientForCheck.findProxy = (url) {
      return HttpClient.findProxyFromEnvironment(
        url, 
        environment: {
          "HTTPS_PROXY": hostPort,
          "HTTP_PROXY": hostPort,
          "https_proxy": hostPort,
          "http_proxy": hostPort
      });
    };

    var result = -1;
    var stopWatch = new Stopwatch()..start();

    try {
      var request = httpClientForCheck.getUrl(new Uri.https("flibusta.is", "/"))
        .timeout(new Duration(seconds: 5))
        .then((r) => r.close());

      var response = await request;
      stopWatch.stop();

      switch (response.statusCode) {
        case 200:
          result = stopWatch.elapsedMilliseconds;
          break;
        default:
          result = -1;
      }
      response.drain();
    } catch (error) {
      result = -1;
      print(error);
    }
    httpClientForCheck.close();
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
    var responseBody = "";
    var proxyList = [];
    var httpClient = new HttpClient();
    httpClient.findProxy = null;

    try {
      var request = httpClient.getUrl(_proxylistUri)
        .timeout(new Duration(seconds: 5))
        .then((r) => r.close());
      var response = await request;

      if (response.statusCode != 200)
        return proxyList;

      await response.transform(utf8.decoder).listen((contents) {
        responseBody += contents;
      }).asFuture();
      htmldom.Document proxyListDocument = parse(responseBody);

      var tbody = proxyListDocument.getElementsByTagName("tbody").first;
      if (tbody == null)
        return null;

      var trs = tbody.getElementsByTagName("tr");
      trs.forEach((tr) => proxyList.add(tr.nodes[1].text));
    } catch (error) {
      print(error);
    }

    httpClient.close();
    return proxyList;
  }
}