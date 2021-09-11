import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/sortBooksByEnum.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _localStorageSingleton = LocalStorage._internal();
  factory LocalStorage() {
    return _localStorageSingleton;
  }
  LocalStorage._internal();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<String>> getPreviousBookSearches() async {
    var prefs = await _prefs;
    try {
      var previousBookSearches = prefs.getStringList('previousBookSearches');
      return previousBookSearches ?? [];
    } catch (e) {
      debugPrint('getPreviousBookSearches Error: ' + e);
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
      debugPrint('setPreviousBookSearches Error: ' + e);
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
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> setIntroCompleted() async {
    var prefs = await _prefs;
    return await prefs.setBool('Intro2Completed', true);
  }

  Future<bool> getLongTapTutorialCompleted() async {
    var prefs = await _prefs;
    try {
      var longTapTutorialCompleted = prefs.getBool('LongTapTutorialCompleted');
      if (longTapTutorialCompleted == null) {
        await prefs.setBool('LongTapTutorialCompleted', false);
        longTapTutorialCompleted = false;
      }
      return longTapTutorialCompleted;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> setLongTapTutorialCompleted() async {
    var prefs = await _prefs;
    return await prefs.setBool('LongTapTutorialCompleted', true);
  }

  Future<bool> putLatestHomeViewNum(int latestHomeView) async {
    try {
      var prefs = await _prefs;
      return await prefs.setInt('latestHomeView', latestHomeView);
    } catch (e) {
      debugPrint(e.toString());
      return true;
    }
  }

  Future<int> getLatestHomeViewNum() async {
    try {
      var prefs = await _prefs;
      return prefs.getInt('latestHomeView') ?? 0;
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
  }

  Future<List<BookCard>> getLastOpenBooks() async {
    var prefs = await _prefs;
    try {
      var lastOpenBooksJsonStrings = prefs.getStringList('LastOpenBooks');
      if (lastOpenBooksJsonStrings?.isEmpty != false) {
        await prefs.setStringList('LastOpenBooks', []);
        return [];
      }
      var lastOpenBooks = lastOpenBooksJsonStrings.map((jsonBookString) {
        return BookCard.fromJson(json.decode(jsonBookString));
      }).toList();
      return lastOpenBooks;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> addToLastOpenBooks(BookCard book) async {
    var prefs = await _prefs;
    var lastOpenBooks = await getLastOpenBooks();
    if (lastOpenBooks.contains(book)) {
      return true;
    }
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

  Future<String> getPreferredBookExt() async {
    var prefs = await _prefs;
    try {
      var preferredBookExt = prefs.getString('PreferredBookExt');
      return preferredBookExt;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> setPreferredBookExt(String preferredBookExt) async {
    var prefs = await _prefs;
    try {
      await prefs.setString('PreferredBookExt', preferredBookExt);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<SortAuthorBooksBy> getPreferredAuthorBookSort() async {
    var prefs = await _prefs;
    try {
      var preferredAuthorBookSort =
          prefs.getInt('PreferredAuthorBookSort') ?? 0;
      if (SortAuthorBooksBy.values.length > preferredAuthorBookSort) {
        return SortAuthorBooksBy.values[preferredAuthorBookSort];
      }
      return SortAuthorBooksBy.values[0];
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> setPreferredAuthorBookSort(
      SortAuthorBooksBy preferredAuthorBookSort) async {
    var prefs = await _prefs;
    try {
      await prefs.setInt(
        'PreferredAuthorBookSort',
        preferredAuthorBookSort.index,
      );
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<SortGenreBooksBy> getPreferredGenreBookSort() async {
    var prefs = await _prefs;
    try {
      var preferredGenreBookSort = prefs.getInt('PreferredGenreBookSort') ?? 0;
      if (SortGenreBooksBy.values.length > preferredGenreBookSort) {
        return SortGenreBooksBy.values[preferredGenreBookSort];
      }
      return SortGenreBooksBy.values[0];
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> setPreferredGenreBookSort(
      SortGenreBooksBy preferredGenreBookSort) async {
    var prefs = await _prefs;
    try {
      await prefs.setInt(
        'PreferredGenreBookSort',
        preferredGenreBookSort.index,
      );
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
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
      debugPrint(e.toString());
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
        await prefs.setStringList('Proxies', []);
        proxies = [];
      }
      return proxies;
    } catch (e) {
      debugPrint(e.toString());
      return [];
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
      debugPrint(e.toString());
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
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> setBooksDirectory(Directory booksDirectory) async {
    var prefs = await _prefs;
    return await prefs.setString('BooksDirectoryPath', booksDirectory?.path);
  }

  Future<List<String>> getFavoriteGenreCodes() async {
    var prefs = await _prefs;
    try {
      var favoriteGenreCodes = prefs.getStringList('FavoriteGenreCodes');
      if (favoriteGenreCodes == null) {
        await prefs.setStringList('FavoriteGenreCodes', []);
        favoriteGenreCodes = [];
      }
      return favoriteGenreCodes;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> addFavoriteGenre(String favoriteGenreCode) async {
    var prefs = await _prefs;
    var favoriteGenreCodes = await getFavoriteGenreCodes();
    if (favoriteGenreCodes.contains(favoriteGenreCode)) return true;

    favoriteGenreCodes.add(favoriteGenreCode);
    return await prefs.setStringList('FavoriteGenreCodes', favoriteGenreCodes);
  }

  Future<bool> deleteFavoriteGenre(String favoriteGenreCode) async {
    var prefs = await _prefs;
    var favoriteGenreCodes = await getFavoriteGenreCodes();
    if (!favoriteGenreCodes.contains(favoriteGenreCode)) return true;

    favoriteGenreCodes.remove(favoriteGenreCode);
    return await prefs.setStringList('FavoriteGenreCodes', favoriteGenreCodes);
  }

  Future<List<BookCard>> getFavoriteBooks() async {
    var prefs = await _prefs;
    try {
      List<BookCard> result = [];

      var favoriteBooksJson = prefs.getStringList('FavoriteBooks');
      if (favoriteBooksJson?.isNotEmpty != true) {
        return result;
      }

      favoriteBooksJson.forEach((element) {
        result.add(BookCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> setFavoriteBooks(List<BookCard> bookCards) async {
    if (bookCards == null) return true;

    var prefs = await _prefs;
    try {
      List<String> favoritesBooksJsonStrings = [];
      bookCards.forEach((element) {
        favoritesBooksJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'FavoriteBooks',
        favoritesBooksJsonStrings,
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> isFavoriteBook(int bookId) async {
    var prefs = await _prefs;
    try {
      var favoriteBookIds = prefs.getStringList('FavoriteBooks');
      if (favoriteBookIds?.isNotEmpty != true) {
        return false;
      }

      return favoriteBookIds.any((element) {
        return BookCard.fromJson(json.decode(element)).id == bookId;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> addFavoriteBook(BookCard bookCard) async {
    var favoriteBooks = await getFavoriteBooks();
    if (favoriteBooks.any((element) => element.id == bookCard.id)) return true;

    favoriteBooks.add(bookCard);
    return await setFavoriteBooks(favoriteBooks);
  }

  Future<bool> deleteFavoriteBook(int bookId) async {
    var favoriteBooks = await getFavoriteBooks();
    if (!favoriteBooks.any((element) => element.id == bookId)) return true;

    favoriteBooks.removeWhere((element) => element.id == bookId);
    return await setFavoriteBooks(favoriteBooks);
  }

  Future<List<BookCard>> getPostponeBooks() async {
    var prefs = await _prefs;
    try {
      List<BookCard> result = [];

      var postponeBooksJson = prefs.getStringList('PostponeBooks');
      if (postponeBooksJson?.isNotEmpty != true) {
        return result;
      }

      postponeBooksJson.forEach((element) {
        result.add(BookCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> setPostponeBooks(List<BookCard> bookCards) async {
    if (bookCards == null) return true;

    var prefs = await _prefs;
    try {
      List<String> postponesBooksJsonStrings = [];
      bookCards.forEach((element) {
        postponesBooksJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'PostponeBooks',
        postponesBooksJsonStrings,
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> isPostponeBook(int bookId) async {
    var prefs = await _prefs;
    try {
      var postponeBookIds = prefs.getStringList('PostponeBooks');
      if (postponeBookIds?.isNotEmpty != true) {
        return false;
      }

      return postponeBookIds.any((element) {
        return BookCard.fromJson(json.decode(element)).id == bookId;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> addPostponeBook(BookCard bookCard) async {
    var postponeBooks = await getPostponeBooks();
    if (postponeBooks.any((element) => element.id == bookCard.id)) return true;

    postponeBooks.add(bookCard);
    return await setPostponeBooks(postponeBooks);
  }

  Future<bool> deletePostponeBook(int bookId) async {
    var postponeBooks = await getPostponeBooks();
    if (!postponeBooks.any((element) => element.id == bookId)) return true;

    postponeBooks.removeWhere((element) => element.id == bookId);
    return await setPostponeBooks(postponeBooks);
  }

  Future<List<AuthorCard>> getFavoriteAuthors() async {
    var prefs = await _prefs;
    try {
      List<AuthorCard> result = [];

      var favoriteAuthorsJson = prefs.getStringList('FavoriteAuthors');
      if (favoriteAuthorsJson?.isNotEmpty != true) {
        return result;
      }

      favoriteAuthorsJson.forEach((element) {
        result.add(AuthorCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> setFavoriteAuthors(List<AuthorCard> authorCards) async {
    if (authorCards == null) return true;

    var prefs = await _prefs;
    try {
      List<String> favoritesAuthorsJsonStrings = [];
      authorCards.forEach((element) {
        favoritesAuthorsJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'FavoriteAuthors',
        favoritesAuthorsJsonStrings,
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> isFavoriteAuthor(int authorId) async {
    var prefs = await _prefs;
    try {
      var favoriteAuthorIds = prefs.getStringList('FavoriteAuthors');
      if (favoriteAuthorIds?.isNotEmpty != true) {
        return false;
      }

      return favoriteAuthorIds.any((element) {
        return AuthorCard.fromJson(json.decode(element)).id == authorId;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> addFavoriteAuthor(AuthorCard authorCard) async {
    var favoriteAuthors = await getFavoriteAuthors();
    if (favoriteAuthors.any((element) => element.id == authorCard.id))
      return true;

    favoriteAuthors.add(authorCard);
    return await setFavoriteAuthors(favoriteAuthors);
  }

  Future<bool> deleteFavoriteAuthor(int authorId) async {
    var favoriteAuthors = await getFavoriteAuthors();
    if (!favoriteAuthors.any((element) => element.id == authorId)) return true;

    favoriteAuthors.removeWhere((element) => element.id == authorId);
    return await setFavoriteAuthors(favoriteAuthors);
  }

  Future<List<SequenceCard>> getFavoriteSequences() async {
    var prefs = await _prefs;
    try {
      List<SequenceCard> result = [];

      var favoriteSequencesJson = prefs.getStringList('FavoriteSequences');
      if (favoriteSequencesJson?.isNotEmpty != true) {
        return result;
      }

      favoriteSequencesJson.forEach((element) {
        result.add(SequenceCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> setFavoriteSequences(List<SequenceCard> sequenceCards) async {
    if (sequenceCards == null) return true;

    var prefs = await _prefs;
    try {
      List<String> favoritesSequencesJsonStrings = [];
      sequenceCards.forEach((element) {
        favoritesSequencesJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'FavoriteSequences',
        favoritesSequencesJsonStrings,
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> isFavoriteSequence(int sequenceId) async {
    var prefs = await _prefs;
    try {
      var favoriteSequenceIds = prefs.getStringList('FavoriteSequences');
      if (favoriteSequenceIds?.isNotEmpty != true) {
        return false;
      }

      return favoriteSequenceIds.any((element) {
        return SequenceCard.fromJson(json.decode(element)).id == sequenceId;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> addFavoriteSequence(SequenceCard sequenceCard) async {
    var favoriteSequences = await getFavoriteSequences();
    if (favoriteSequences.any((element) => element.id == sequenceCard.id))
      return true;

    favoriteSequences.add(sequenceCard);
    return await setFavoriteSequences(favoriteSequences);
  }

  Future<bool> deleteFavoriteSequence(int sequenceId) async {
    var favoriteSequences = await getFavoriteSequences();
    if (!favoriteSequences.any((element) => element.id == sequenceId))
      return true;

    favoriteSequences.removeWhere((element) => element.id == sequenceId);
    return await setFavoriteSequences(favoriteSequences);
  }

  Future<List<BookCard>> getDownloadedBooks() async {
    var prefs = await _prefs;
    try {
      var downloadedBooksJsonStrings = prefs.getStringList('DownloadedBooks');
      if (downloadedBooksJsonStrings.isEmpty != false) {
        await prefs.setStringList('DownloadedBooks', []);
        return [];
      }
      var downloadedBooks = downloadedBooksJsonStrings.map((jsonBookString) {
        return BookCard.fromJson(json.decode(jsonBookString));
      }).toList();
      return downloadedBooks;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<bool> addDownloadedBook(BookCard book) async {
    var prefs = await _prefs;
    var downloadedBooks = await getDownloadedBooks();
    downloadedBooks = [book, ...downloadedBooks];

    return await prefs.setStringList(
      'DownloadedBooks',
      downloadedBooks.map((book) => json.encode(book.toJson())).toList(),
    );
  }

  Future<bool> deleteDownloadedBook(BookCard downloadedBook) async {
    var prefs = await _prefs;
    var downloadedBooks = await getDownloadedBooks();
    downloadedBooks.removeWhere((book) => downloadedBook.id == book.id);

    return await prefs.setStringList(
      'DownloadedBooks',
      downloadedBooks.map((book) => json.encode(book.toJson())).toList(),
    );
  }

  Future<bool> clearDownloadedBook() async {
    var prefs = await _prefs;

    return await prefs.setStringList(
      'DownloadedBooks',
      [],
    );
  }

  Future<bool> getUseOnionSiteWithTor() async {
    var prefs = await _prefs;
    try {
      var useOnionSiteWithTor = prefs.getBool('UseOnionSiteWithTor');
      if (useOnionSiteWithTor == null) {
        await prefs.setBool('UseOnionSiteWithTor', true);
        useOnionSiteWithTor = true;
      }
      return useOnionSiteWithTor;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> setUseOnionSiteWithTor(bool value) async {
    var prefs = await _prefs;
    return await prefs.setBool('UseOnionSiteWithTor', value);
  }

  Future<bool> getStartUpTor() async {
    var prefs = await _prefs;
    try {
      var startUpTor = prefs.getBool('StartUpTor');
      if (startUpTor == null) {
        await prefs.setBool('StartUpTor', false);
        startUpTor = false;
      }
      return startUpTor;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> setStartUpTor(bool value) async {
    var prefs = await _prefs;
    return await prefs.setBool('StartUpTor', value);
  }

  Future<void> checkVersion() async {
    var prefs = await _prefs;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (prefs.getString('VersionCode') != packageInfo.buildNumber) {
      await prefs.setString('VersionCode', packageInfo.buildNumber);
    }
  }
}
