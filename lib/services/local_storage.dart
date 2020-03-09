import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flibusta/constants.dart';
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
      return await prefs.setStringList(
          'previousBookSearches', previousBookSearches ?? []);
    } catch (e) {
      print('setPreviousBookSearches Error: ' + e);
      return false;
    }
  }

  Future<bool> getIntroCompleted() async {
    var prefs = await _prefs;
    try {
      var introCompleted = prefs.getBool('Intro2Completed');
      if (introCompleted == null) {
        await prefs.setBool('Intro2Completed', false);
        introCompleted = false;
      }
      return introCompleted;
    } catch (e) {
      await prefs.setBool('Intro2Completed', false);
      return false;
    }
  }

  Future<bool> setIntroCompleted() async {
    var prefs = await _prefs;
    return await prefs.setBool('Intro2Completed', true);
  }

  Future<bool> putLatestHomeViewNum(int latestHomeView) async {
    try {
      var prefs = await _prefs;
      return await prefs.setInt('latestHomeView', latestHomeView);
    } catch (e) {
      print(e);
      return true;
    }
  }

  Future<int> getLatestHomeViewNum() async {
    try {
      var prefs = await _prefs;
      return prefs.getInt('latestHomeView') ?? 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<List<BookCard>> getLastOpenBooks() async {
    var prefs = await _prefs;
    try {
      var lastOpenBooksJsonStrings = prefs.getStringList('LastOpenBooks');
      if (lastOpenBooksJsonStrings?.isEmpty != false) {
        await prefs.setStringList('LastOpenBooks', List<String>());
        return List<BookCard>();
      }
      var lastOpenBooks = lastOpenBooksJsonStrings.map((jsonBookString) {
        return BookCard.fromJson(json.decode(jsonBookString));
      }).toList();
      return lastOpenBooks;
    } catch (e) {
      await prefs.setStringList('LastOpenBooks', List<String>());
      return List<BookCard>();
    }
  }

  Future<bool> addToLastOpenBooks(BookCard book) async {
    var prefs = await _prefs;
    var lastOpenBooks = await getLastOpenBooks();
    lastOpenBooks.add(book);
    if (lastOpenBooks.length > 3) {
      lastOpenBooks = lastOpenBooks.sublist(
        lastOpenBooks.length - 3,
        lastOpenBooks.length,
      );
    }

    return await prefs.setStringList(
      'LastOpenBooks',
      lastOpenBooks.map((book) => json.encode(book.toJson())).toList(),
    );
  }

  Future<bool> getShowAdditionalBookInfo() async {
    var prefs = await _prefs;
    try {
      var showAdditionalBookInfo = prefs.getBool('ShowAdditionalBookInfo');
      if (showAdditionalBookInfo == null) {
        await prefs.setBool('ShowAdditionalBookInfo', true);
        showAdditionalBookInfo = true;
      }
      return showAdditionalBookInfo;
    } catch (e) {
      await prefs.setBool('ShowAdditionalBookInfo', true);
      return true;
    }
  }

  Future<bool> setShowAdditionalBookInfo(bool showAdditionalBookInfo) async {
    var prefs = await _prefs;
    return await prefs.setBool(
        'ShowAdditionalBookInfo', showAdditionalBookInfo ?? true);
  }

  Future<String> getActualProxy() async {
    var prefs = await _prefs;
    try {
      var actualProxy = prefs.getString('ActualProxy');
      if (actualProxy == null) {
        await prefs.setString('ActualProxy', '');
        actualProxy = '';
      }
      return actualProxy;
    } catch (e) {
      await prefs.setString('ActualProxy', '');
      return '';
    }
  }

  Future<bool> setActualProxy(String ipPort) async {
    var prefs = await _prefs;
    return await prefs.setString('ActualProxy', ipPort);
  }

  Future<List<String>> getProxies() async {
    var prefs = await _prefs;
    try {
      var proxies = prefs.getStringList('Proxies');
      if (proxies == null) {
        await prefs.setStringList('Proxies', List<String>());
        proxies = List<String>();
      }
      return proxies;
    } catch (e) {
      await prefs.setStringList('Proxies', List<String>());
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
    return await prefs.setStringList('Proxies', proxies);
  }

  Future<String> getHostAddress() async {
    var prefs = await _prefs;
    try {
      var flibustaHostAddress = prefs.getString('FlibustaHostAddress');
      if (flibustaHostAddress == null) {
        await prefs.setString('FlibustaHostAddress', '');
        flibustaHostAddress = '';
      }
      return flibustaHostAddress;
    } catch (e) {
      await prefs.setString('FlibustaHostAddress', '');
      return '';
    }
  }

  Future<bool> setHostAddress(String hostAddress) async {
    var prefs = await _prefs;
    return await prefs.setString('FlibustaHostAddress', hostAddress);
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
    return await prefs.setString('BooksDirectoryPath', booksDirectory?.path);
  }

  Future<List<String>> getfavoriteGenreCodes() async {
    var prefs = await _prefs;
    try {
      var favoriteGenreCodes = prefs.getStringList('FavoriteGenreCodes');
      if (favoriteGenreCodes == null) {
        await prefs.setStringList('FavoriteGenreCodes', List<String>());
        favoriteGenreCodes = List<String>();
      }
      return favoriteGenreCodes;
    } catch (e) {
      await prefs.setStringList('FavoriteGenreCodes', List<String>());
      return List<String>();
    }
  }

  Future<bool> addFavoriteGenre(String favoriteGenreCode) async {
    var prefs = await _prefs;
    var favoriteGenreCodes = await getfavoriteGenreCodes();
    if (favoriteGenreCodes.contains(favoriteGenreCode)) return true;

    favoriteGenreCodes.add(favoriteGenreCode);
    return await prefs.setStringList('FavoriteGenreCodes', favoriteGenreCodes);
  }

  Future<bool> deleteFavoriteGenre(String favoriteGenreCode) async {
    var prefs = await _prefs;
    var favoriteGenreCodes = await getfavoriteGenreCodes();
    if (!favoriteGenreCodes.contains(favoriteGenreCode)) return true;

    favoriteGenreCodes.remove(favoriteGenreCode);
    return await prefs.setStringList('FavoriteGenreCodes', favoriteGenreCodes);
  }

  Future<List<BookCard>> getDownloadedBooks() async {
    var prefs = await _prefs;
    try {
      var downloadedBooksJsonStrings = prefs.getStringList('DownloadedBooks');
      if (downloadedBooksJsonStrings.isEmpty != false) {
        await prefs.setStringList('DownloadedBooks', List<String>());
        return List<BookCard>();
      }
      var downloadedBooks = downloadedBooksJsonStrings.map((jsonBookString) {
        return BookCard.fromJson(json.decode(jsonBookString));
      }).toList();
      return downloadedBooks;
    } catch (e) {
      await prefs.setStringList('DownloadedBooks', List<String>());
      return List<BookCard>();
    }
  }

  Future<bool> addDownloadedBook(BookCard book) async {
    var prefs = await _prefs;
    var downloadedBooks = await getDownloadedBooks();
    downloadedBooks.add(book);

    return await prefs.setStringList(
      'DownloadedBooks',
      downloadedBooks.map((book) => json.encode(book.toJson())).toList(),
    );
  }

  Future<void> checkVersion() async {
    var prefs = await _prefs;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (prefs.getString('VersionCode') != packageInfo.buildNumber) {
      // _clearPrefs(prefs);
      await prefs.setString('VersionCode', packageInfo.buildNumber);
    }
  }

  // Future<bool> _clearPrefs(SharedPreferences prefs) async {
  //   return prefs.clear();
  // }
}
