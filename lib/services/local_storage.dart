import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flibusta/model/bookCard.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<String>> getPreviousBookSearches() async {
    var prefs = await _prefs;
    try {
      var previousBookSearches = prefs.getStringList('previousBookSearches');
      return previousBookSearches ?? [];
    } catch (e) {
      print('getPreviousBookSearches Error: ' + e);
      return [];
    }
  }

  Future<bool> setPreviousBookSearches(
      List<String> previousBookSearches) async {
    var prefs = await _prefs;
    try {
      return prefs.setStringList(
          'previousBookSearches', previousBookSearches ?? []);
    } catch (e) {
      print('setPreviousBookSearches Error: ' + e);
      return false;
    }
  }

  Future<bool> getIntroCompleted() async {
    var prefs = await _prefs;
    try {
      var introCompleted = prefs.getBool('IntroCompleted');
      if (introCompleted == null) {
        prefs.setBool('IntroCompleted', false);
        introCompleted = false;
      }
      return introCompleted;
    } catch (e) {
      prefs.setBool('IntroCompleted', false);
      return false;
    }
  }

  Future<bool> setIntroCompleted() async {
    var prefs = await _prefs;
    return prefs.setBool('IntroCompleted', true);
  }

  Future<String> getActualProxy() async {
    var prefs = await _prefs;
    try {
      var actualProxy = prefs.getString('ActualProxy');
      if (actualProxy == null) {
        prefs.setString('ActualProxy', '');
        actualProxy = '';
      }
      return actualProxy;
    } catch (e) {
      prefs.setString('ActualProxy', '');
      return '';
    }
  }

  Future<bool> setActualProxy(String ipPort) async {
    var prefs = await _prefs;
    return prefs.setString('ActualProxy', ipPort);
  }

  Future<List<String>> getProxies() async {
    var prefs = await _prefs;
    try {
      var proxies = prefs.getStringList('Proxies');
      if (proxies == null) {
        prefs.setStringList('Proxies', List<String>());
        proxies = List<String>();
      }
      return proxies;
    } catch (e) {
      prefs.setStringList('Proxies', List<String>());
      return List<String>();
    }
  }

  Future<bool> addProxy(String proxy) async {
    var prefs = await _prefs;
    var proxies = await getProxies();
    if (proxies.contains(proxy)) return true;

    proxies.add(proxy);
    return prefs.setStringList('Proxies', proxies);
  }

  Future<bool> deleteProxy(String proxy) async {
    var prefs = await _prefs;
    var proxies = await getProxies();
    if (!proxies.contains(proxy)) return true;

    proxies.remove(proxy);
    return prefs.setStringList('Proxies', proxies);
  }

  Future<String> getFlibustaHostAddress() async {
    var prefs = await _prefs;
    try {
      var flibustaHostAddress = prefs.getString('FlibustaHostAddress');
      if (flibustaHostAddress == null) {
        prefs.setString('FlibustaHostAddress', 'flibusta.is');
        flibustaHostAddress = 'flibusta.is';
      }
      return flibustaHostAddress;
    } catch (e) {
      prefs.setString('FlibustaHostAddress', 'flibusta.is');
      return '';
    }
  }

  Future<bool> setFlibustaHostAddress(String hostAddress) async {
    var prefs = await _prefs;
    return prefs.setString('FlibustaHostAddress', hostAddress);
  }

  Future<Directory> getBooksDirectory() async {
    var prefs = await _prefs;
    try {
      var booksDirectoryPath = prefs.getString('BooksDirectoryPath');
      var booksDirectory = Directory(booksDirectoryPath);
      return booksDirectory;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setBooksDirectory(Directory booksDirectory) async {
    var prefs = await _prefs;
    return prefs.setString('BooksDirectoryPath', booksDirectory?.path);
  }

  Future<List<String>> getfavoriteGenreCodes() async {
    var prefs = await _prefs;
    try {
      var favoriteGenreCodes = prefs.getStringList('FavoriteGenreCodes');
      if (favoriteGenreCodes == null) {
        prefs.setStringList('FavoriteGenreCodes', List<String>());
        favoriteGenreCodes = List<String>();
      }
      return favoriteGenreCodes;
    } catch (e) {
      prefs.setStringList('FavoriteGenreCodes', List<String>());
      return List<String>();
    }
  }

  Future<bool> addFavoriteGenre(String favoriteGenreCode) async {
    var prefs = await _prefs;
    var favoriteGenreCodes = await getfavoriteGenreCodes();
    if (favoriteGenreCodes.contains(favoriteGenreCode)) return true;

    favoriteGenreCodes.add(favoriteGenreCode);
    return prefs.setStringList('FavoriteGenreCodes', favoriteGenreCodes);
  }

  Future<bool> deleteFavoriteGenre(String favoriteGenreCode) async {
    var prefs = await _prefs;
    var favoriteGenreCodes = await getfavoriteGenreCodes();
    if (!favoriteGenreCodes.contains(favoriteGenreCode)) return true;

    favoriteGenreCodes.remove(favoriteGenreCode);
    return prefs.setStringList('FavoriteGenreCodes', favoriteGenreCodes);
  }

  Future<List<BookCard>> getDownloadedBooks() async {
    var prefs = await _prefs;
    try {
      var downloadedBooksJsonStrings = prefs.getStringList('DownloadedBooks');
      if (downloadedBooksJsonStrings.isEmpty != false) {
        prefs.setStringList('DownloadedBooks', List<String>());
        return List<BookCard>();
      }
      var downloadedBooks = downloadedBooksJsonStrings.map((jsonBookString) {
        return BookCard.fromJson(json.decode(jsonBookString));
      });
      return downloadedBooks;
    } catch (e) {
      prefs.setStringList('DownloadedBooks', List<String>());
      return List<BookCard>();
    }
  }

  Future<bool> addDownloadedBook(BookCard favoriteGenreCode) async {
    var prefs = await _prefs;
    var downloadedBooks = await getDownloadedBooks();
    downloadedBooks.add(favoriteGenreCode);

    return prefs.setStringList(
      'DownloadedBooks',
      downloadedBooks.map((book) => json.encode(book.toJson())).toList(),
    );
  }

  Future<void> checkVersion() async {
    var prefs = await _prefs;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (prefs.getString('VersionCode') != packageInfo.buildNumber) {
      // _clearPrefs(prefs);
      prefs.setString('VersionCode', packageInfo.buildNumber);
    }
  }

  // Future<bool> _clearPrefs(SharedPreferences prefs) async {
  //   return prefs.clear();
  // }
}
