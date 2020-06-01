import 'dart:math';

import 'package:flibusta/constants.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/model/grid_data/grid_data.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/model/sequenceInfo.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/html_parsers.dart';

class GridDataRepository {
  Future<List<GridData>> getDownloadedBooks(
    int page, [
    String searchString,
  ]) async {
    var downloadedBooks = await LocalStorage().getDownloadedBooks();
    if (searchString?.isNotEmpty == true) {
      downloadedBooks = downloadedBooks.where((book) {
        var lowerCaseSearchString = searchString.toLowerCase();
        return book.sequenceTitle
                .toLowerCase()
                .contains(lowerCaseSearchString) ||
            book.title.toLowerCase().contains(lowerCaseSearchString) ||
            book.authors.list.any((author) => author.values.first
                .toLowerCase()
                .contains(lowerCaseSearchString)) ||
            book.translators.list.any((translator) => translator.values.first
                .toLowerCase()
                .contains(lowerCaseSearchString)) ||
            book.genres.list.any((genre) => genre.values.first
                .toLowerCase()
                .contains(lowerCaseSearchString));
      }).toList();
    }
    return _getPageFromList(downloadedBooks, page);
  }

  static List<Genre> cachedGenreList;

  Future<List<GridData>> makeBookList(
    int page, {
    AdvancedSearchParams advancedSearchParams,
    List<Map<int, String>> lastGenres,
  }) async {
    Map<String, String> queryParams = {'ab': 'ab1', 'sort': 'sd2'};

    if (page != null && page > 1) {
      queryParams.addAll({'page': (page - 1).toString()});
    }
    if (advancedSearchParams?.title?.isNotEmpty == true) {
      queryParams.addAll({'t': advancedSearchParams.title});
    }
    if (advancedSearchParams?.firstname?.isNotEmpty == true) {
      queryParams.addAll({'fn': advancedSearchParams.firstname});
    }
    if (advancedSearchParams?.lastname?.isNotEmpty == true) {
      queryParams.addAll({'ln': advancedSearchParams.lastname});
    }
    if (advancedSearchParams?.middlename?.isNotEmpty == true) {
      queryParams.addAll({'mn': advancedSearchParams.middlename});
    }
    if (advancedSearchParams?.genres?.isNotEmpty == true) {
      queryParams.addAll({'g': advancedSearchParams.genres});
    }
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/makebooklist',
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);
    if (response.data == null || !(response.data is String)) {
      return null;
    }

    var result = parseHtmlFromMakeBookList(response.data, lastGenres);
    return result;
  }

  Future<SearchResults> bookSearch(
    int page,
    String searchQuery, {
    bool isAuthorSearch = false,
    bool isBookSearch = false,
    bool isSequenceSearch = false,
  }) async {
    Map<String, String> queryParams = {
      'page': (page - 1).toString(),
      'ask': searchQuery,
    };
    if (isAuthorSearch) {
      queryParams.addAll({'cha': 'on'});
    }
    if (isBookSearch) {
      queryParams.addAll({'chb': 'on'});
    }
    if (isSequenceSearch) {
      queryParams.addAll({'chs': 'on'});
    }
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/booksearch',
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
    var result = List<AuthorCard>();

    Map<String, String> queryParams = {'ab': 'ab2', 'sort': 'sln1'};

    if (page != null && page > 1) {
      queryParams.addAll({'page': (page - 1).toString()});
    }

    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/makebooklist',
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);

    if (response.data == null || !(response.data is String)) {
      return null;
    }

    result = parseHtmlFromGetAuthors(response.data);
    return result;
  }

  Future<List<SequenceCard>> getSequences(int page) async {
    var result = List<SequenceCard>();

    Map<String, String> queryParams;

    if (page != null && page > 1) {
      queryParams = {'page': (page - 1).toString()};
    }

    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/s',
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);

    if (response.data == null || !(response.data is String)) {
      return null;
    }

    result = parseHtmlFromGetSequences(response.data);
    return result;
  }

  Future<SequenceInfo> getSequence(int sequenceId, int page) async {
    SequenceInfo result;

    Map<String, String> queryParams;

    if (page != null && page > 1) {
      queryParams = {'page': (page - 1).toString()};
    }

    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/s/' + sequenceId.toString(),
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);

    result = parseHtmlFromSequenceInfo(response.data, sequenceId);

    return result;
  }

  Future<List<GridData>> getGenres(int page, {String searchString}) async {
    if (cachedGenreList != null) {
      var result = cachedGenreList;
      if (searchString?.isNotEmpty == true) {
        result = result
            .where(
              (genre) =>
                  genre.name.toLowerCase().contains(searchString.toLowerCase()),
            )
            .toList();
      } else {
        var favoriteGenreCodes = await LocalStorage().getFavoriteGenreCodes();
        result.sort(
          (genre1, genre2) => _genreSorting(favoriteGenreCodes, genre1, genre2),
        );
      }
      if (page != null) {
        return _getPageFromList<GridData>(result, page);
      }
      return result;
    }

    var result = List<Genre>();
    Map<String, String> queryParams = {
      'op': 'getList',
    };
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/ajaxro/genre',
      queryParams,
    );

    var response = await ProxyHttpClient().getDio().getUri(url);

    if (response.data == null || !(response.data is Map<String, dynamic>)) {
      return null;
    }

    response.data.forEach((headIndex, headGenre) {
      headGenre.forEach((genre) {
        result.add(Genre(
          id: int.tryParse(genre['id']),
          name: genre['name'],
          code: genre['code'],
        ));
      });
    });
    cachedGenreList = result;
    if (searchString?.isNotEmpty == true) {
      result = result
          .where(
            (genre) =>
                genre.name.toLowerCase().contains(searchString.toLowerCase()),
          )
          .toList();
    } else {
      var favoriteGenreCodes = await LocalStorage().getFavoriteGenreCodes();
      result.sort(
        (genre1, genre2) => _genreSorting(favoriteGenreCodes, genre1, genre2),
      );
    }

    if (page != null) {
      return _getPageFromList<GridData>(result, page);
    }
    return result;
  }

  static List<T> _getPageFromList<T>(List<T> list, int page) {
    return list.sublist(
      min(HomeGridConsts.kPageSize * (page - 1), list.length),
      min(HomeGridConsts.kPageSize * page, list.length),
    );
  }

  static int _genreSorting(
      List<String> favoriteGenreCodes, Genre genre1, Genre genre2) {
    var isFavorite1 = favoriteGenreCodes?.any((favoriteGenreCode) {
          return favoriteGenreCode == genre1.code;
        }) ??
        false;

    var isFavorite2 = favoriteGenreCodes?.any((favoriteGenreCode) {
          return favoriteGenreCode == genre2.code;
        }) ??
        false;

    if (isFavorite1 && isFavorite2)
      return genre1.name.compareTo(genre2.name);
    else if (isFavorite1)
      return -1;
    else if (isFavorite2)
      return 1;
    else
      return genre1.name.compareTo(genre2.name);
  }
}
