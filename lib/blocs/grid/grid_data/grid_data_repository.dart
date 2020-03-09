import 'dart:math';

import 'package:flibusta/constants.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/html_parsers.dart';

class GridDataRepository {
  Future<List<GridData>> getDownloadedBooks(int page) async {
    return _getPageFromList(await LocalStorage().getDownloadedBooks(), page);
  }

  List<Genre> cachedGenreList;

  Future<List<GridData>> makeBookList(
    int page, {
    AdvancedSearchParams advancedSearchParams,
  }) async {
    Map<String, String> queryParams = {"ab": "ab1", "sort": "sd2"};

    if (page != null && page > 1) {
      queryParams.addAll({"page": (page - 1).toString()});
    }
    if (advancedSearchParams?.title?.isNotEmpty == true) {
      queryParams.addAll({"t": advancedSearchParams.title});
    }
    if (advancedSearchParams?.firstname?.isNotEmpty == true) {
      queryParams.addAll({"fn": advancedSearchParams.firstname});
    }
    if (advancedSearchParams?.lastname?.isNotEmpty == true) {
      queryParams.addAll({"ln": advancedSearchParams.lastname});
    }
    if (advancedSearchParams?.middlename?.isNotEmpty == true) {
      queryParams.addAll({"mn": advancedSearchParams.middlename});
    }
    if (advancedSearchParams?.genres?.isNotEmpty == true) {
      queryParams.addAll({"g": advancedSearchParams.genres});
    }
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      "/makebooklist",
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);
    if (response.data == null || !(response.data is String)) {
      return null;
    }

    var result = parseHtmlFromMakeBookList(response.data);
    return result;
  }

  Future<SearchResults> bookSearch(String searchQuery) async {
    Map<String, String> queryParams = {
      "page": "0",
      "ask": searchQuery,
      "chs": "on",
      "cha": "on",
      "chb": "on"
    };
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      "/booksearch",
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);

    if (response?.data == null || !(response.data is String)) {
      return null;
    }

    var result = parseHtmlFromBookSearch(response.data);
    return result;
  }

  Future<List<AuthorCard>> getAuthors(int page) async {
    var _dio = ProxyHttpClient().getDio();

    var result = List<AuthorCard>();

    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      "/a",
    );

    var response = await _dio.getUri(url);

    if (response.data == null || !(response.data is String)) {
      return null;
    }
  }

  Future<List<GridData>> getAllGenres(int page) async {
    if (cachedGenreList != null) {
      return _getPageFromList<GridData>(cachedGenreList, page);
    }

    var _dio = ProxyHttpClient().getDio();

    var result = List<Genre>();
    Map<String, String> queryParams = {
      "op": "getList",
    };
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      "/ajaxro/genre",
      queryParams,
    );

    var response = await _dio.getUri(url);

    if (response.data == null || !(response.data is Map<String, dynamic>)) {
      return null;
    }

    response.data.forEach((headIndex, headGenre) {
      headGenre.forEach((genre) {
        result.add(Genre(
          id: int.tryParse(genre["id"]),
          name: genre["name"],
          code: genre["code"],
        ));
      });
    });
    cachedGenreList = result;

    return _getPageFromList<GridData>(cachedGenreList, page);
  }

  static List<T> _getPageFromList<T>(List<T> list, int page) {
    return list.sublist(
      max(HomeGridConsts.kPageSize * (page - 1), list.length),
      max(HomeGridConsts.kPageSize * page, list.length),
    );
  }
}
