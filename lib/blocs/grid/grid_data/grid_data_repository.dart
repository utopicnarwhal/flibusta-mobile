import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/html_parsers.dart';

class GridDataRepository {
  Future<List<GridData>> getDownloadedBooks(int page) async {
    return LocalStorage().getDownloadedBooks(page);
  }

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
      ProxyHttpClient().getFlibustaHostAddress(),
      "/makebooklist",
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);
    var result = parseHtmlFromMakeBookList(response.data);
    return result;
  }

  // Future<SearchResults> bookSearch(String searchQuery) async {
  //   Map<String, String> queryParams = {
  //     "page": "0",
  //     "ask": searchQuery,
  //     "chs": "on",
  //     "cha": "on",
  //     "chb": "on"
  //   };
  //   Uri url = Uri.https(
  //       ProxyHttpClient().getFlibustaHostAddress(), "/booksearch", queryParams);
  //   try {
  //     var response = await ProxyHttpClient().getDio().getUri(url);
  //     var result = parseHtmlFromBookSearch(response.data);
  //     return result;
  //   } on TimeoutException catch (timeoutError) {
  //     print(timeoutError);
  //     return null;
  //   } catch (error) {
  //     print(error);
  //     return null;
  //   }
  // }

  Future<List<GridData>> getAllGenres() async {
    var _dio = ProxyHttpClient().getDio();

    var result = List<Genre>();
    Map<String, String> queryParams = {
      "op": "getList",
    };
    Uri url = Uri.https(
      ProxyHttpClient().getFlibustaHostAddress(),
      "/ajaxro/genre",
      queryParams,
    );

    var response = await _dio.getUri(url);
    response.data.forEach((headIndex, headGenre) {
      headGenre.forEach((genre) {
        result.add(Genre(
          id: int.tryParse(genre["id"]),
          name: genre["name"],
          code: genre["code"],
        ));
      });
    });
    return result;
  }
}
