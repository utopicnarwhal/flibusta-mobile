import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/enums/sortBooksByEnum.dart';
import 'package:flibusta/model/searchResults.dart';
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
      await prefs.setBool('LongTapTutorialCompleted', false);
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
      return null;
    }
  }

  Future<bool> setPreferredBookExt(String preferredBookExt) async {
    var prefs = await _prefs;
    try {
      await prefs.setString('PreferredBookExt', preferredBookExt);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<SortBooksBy> getPreferredAuthorBookSort() async {
    var prefs = await _prefs;
    try {
      var preferredAuthorBookSort =
          prefs.getInt('PreferredAuthorBookSort') ?? 0;
      if (SortBooksBy.values.length > preferredAuthorBookSort) {
        return SortBooksBy.values[preferredAuthorBookSort];
      }
      return SortBooksBy.values[0];
    } catch (e) {
      return null;
    }
  }

  Future<bool> setPreferredAuthorBookSort(
      SortBooksBy preferredAuthorBookSort) async {
    var prefs = await _prefs;
    try {
      await prefs.setInt(
        'PreferredAuthorBookSort',
        preferredAuthorBookSort.index,
      );
      return true;
    } catch (e) {
      print(e);
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

  Future<List<String>> getFavoriteGenreCodes() async {
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
      var result = List<BookCard>();

      var favoriteBooksJson = prefs.getStringList('FavoriteBooks');
      if (favoriteBooksJson?.isNotEmpty != true) {
        return result;
      }

      favoriteBooksJson.forEach((element) {
        result.add(BookCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      await prefs.setStringList('FavoriteBooks', List<String>());
      return List<BookCard>();
    }
  }

  Future<bool> setFavoriteBooks(List<BookCard> bookCards) async {
    if (bookCards == null) return true;

    var prefs = await _prefs;
    try {
      var favoritesBooksJsonStrings = List<String>();
      bookCards.forEach((element) {
        favoritesBooksJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'FavoriteBooks',
        favoritesBooksJsonStrings,
      );
    } catch (e) {
      return await prefs.setStringList('FavoriteBooks', List<String>());
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
      await prefs.setStringList('FavoriteBooks', List<String>());
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
      var result = List<BookCard>();

      var postponeBooksJson = prefs.getStringList('PostponeBooks');
      if (postponeBooksJson?.isNotEmpty != true) {
        return result;
      }

      postponeBooksJson.forEach((element) {
        result.add(BookCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      await prefs.setStringList('PostponeBooks', List<String>());
      return List<BookCard>();
    }
  }

  Future<bool> setPostponeBooks(List<BookCard> bookCards) async {
    if (bookCards == null) return true;

    var prefs = await _prefs;
    try {
      var postponesBooksJsonStrings = List<String>();
      bookCards.forEach((element) {
        postponesBooksJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'PostponeBooks',
        postponesBooksJsonStrings,
      );
    } catch (e) {
      return await prefs.setStringList('PostponeBooks', List<String>());
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
      await prefs.setStringList('PostponeBooks', List<String>());
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
      var result = List<AuthorCard>();

      var favoriteAuthorsJson = prefs.getStringList('FavoriteAuthors');
      if (favoriteAuthorsJson?.isNotEmpty != true) {
        return result;
      }

      favoriteAuthorsJson.forEach((element) {
        result.add(AuthorCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      await prefs.setStringList('FavoriteAuthors', List<String>());
      return List<AuthorCard>();
    }
  }

  Future<bool> setFavoriteAuthors(List<AuthorCard> authorCards) async {
    if (authorCards == null) return true;

    var prefs = await _prefs;
    try {
      var favoritesAuthorsJsonStrings = List<String>();
      authorCards.forEach((element) {
        favoritesAuthorsJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'FavoriteAuthors',
        favoritesAuthorsJsonStrings,
      );
    } catch (e) {
      return await prefs.setStringList('FavoriteAuthors', List<String>());
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
      await prefs.setStringList('FavoriteAuthors', List<String>());
      return false;
    }
  }

  Future<bool> addFavoriteAuthor(AuthorCard authorCard) async {
    var favoriteAuthors = await getFavoriteAuthors();
    if (favoriteAuthors.any((element) => element.id == authorCard.id)) return true;

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
      var result = List<SequenceCard>();

      var favoriteSequencesJson = prefs.getStringList('FavoriteSequences');
      if (favoriteSequencesJson?.isNotEmpty != true) {
        return result;
      }

      favoriteSequencesJson.forEach((element) {
        result.add(SequenceCard.fromJson(json.decode(element)));
      });
      return result;
    } catch (e) {
      await prefs.setStringList('FavoriteSequences', List<String>());
      return List<SequenceCard>();
    }
  }

  Future<bool> setFavoriteSequences(List<SequenceCard> sequenceCards) async {
    if (sequenceCards == null) return true;

    var prefs = await _prefs;
    try {
      var favoritesSequencesJsonStrings = List<String>();
      sequenceCards.forEach((element) {
        favoritesSequencesJsonStrings.add(json.encode(element.toJson()));
      });
      return await prefs.setStringList(
        'FavoriteSequences',
        favoritesSequencesJsonStrings,
      );
    } catch (e) {
      return await prefs.setStringList('FavoriteSequences', List<String>());
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
      await prefs.setStringList('FavoriteSequences', List<String>());
      return false;
    }
  }

  Future<bool> addFavoriteSequence(SequenceCard sequenceCard) async {
    var favoriteSequences = await getFavoriteSequences();
    if (favoriteSequences.any((element) => element.id == sequenceCard.id)) return true;

    favoriteSequences.add(sequenceCard);
    return await setFavoriteSequences(favoriteSequences);
  }

  Future<bool> deleteFavoriteSequence(int sequenceId) async {
    var favoriteSequences = await getFavoriteSequences();
    if (!favoriteSequences.any((element) => element.id == sequenceId)) return true;

    favoriteSequences.removeWhere((element) => element.id == sequenceId);
    return await setFavoriteSequences(favoriteSequences);
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

  Future<bool> clearDownloadedBook() async {
    var prefs = await _prefs;

    return await prefs.setStringList(
      'DownloadedBooks',
      [],
    );
  }

  Future<void> checkVersion() async {
    var prefs = await _prefs;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (prefs.getString('VersionCode') != packageInfo.buildNumber) {
      await prefs.setString('VersionCode', packageInfo.buildNumber);
    }
  }
}
