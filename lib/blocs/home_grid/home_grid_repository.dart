import 'package:dio/dio.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';

import 'dart:async';

class HomeGridRepository {
  Dio _dio = ProxyHttpClient().getDio();

  Future<SearchResults> bookSearch(String searchQuery) async {
    Map<String, String> queryParams = {
      "page": "0",
      "ask": searchQuery,
      "chs": "on",
      "cha": "on",
      "chb": "on"
    };
    Uri url = Uri.https(
        ProxyHttpClient().getFlibustaHostAddress(), "/booksearch", queryParams);
    try {
      var response = await _dio.getUri(url);
      var result = parseHtmlFromBookSearch(response.data);
      return result;
    } on TimeoutException catch (timeoutError) {
      print(timeoutError);
      return null;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
