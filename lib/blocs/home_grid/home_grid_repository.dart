import 'package:dio/dio.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/bookCard.dart';
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

  Future<List<BookCard>> makeBookList({AdvancedSearchParams advancedSearchParams}) async {
    Map<String, String> queryParams = { "ab" : "ab1", "sort": "sd2" };

    if (advancedSearchParams != null) {
      if (advancedSearchParams.title != null && advancedSearchParams.title.isNotEmpty) {
        queryParams.addAll({ "t": advancedSearchParams.title });
      }
      if (advancedSearchParams.firstname != null && advancedSearchParams.firstname.isNotEmpty) {
        queryParams.addAll({ "fn": advancedSearchParams.firstname });
      }
      if (advancedSearchParams.lastname != null && advancedSearchParams.lastname.isNotEmpty) {
        queryParams.addAll({ "ln": advancedSearchParams.lastname });
      }
      if (advancedSearchParams.middlename != null && advancedSearchParams.middlename.isNotEmpty) {
        queryParams.addAll({ "mn": advancedSearchParams.middlename });
      }
      if (advancedSearchParams.genres != null && advancedSearchParams.genres.isNotEmpty) {
        queryParams.addAll({ "g": advancedSearchParams.genres });
      }
    }
    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/makebooklist", queryParams);

    try {
      var response = await _dio.getUri(url);
      var result = parseHtmlFromMakeBookList(response.data);
      return result;
    } on TimeoutException catch(timeoutError) {
      print(timeoutError);
      return null;
    } catch(error) {
      print(error);
      return null;
    }
  }
}
