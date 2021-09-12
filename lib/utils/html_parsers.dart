import 'dart:math';

import 'package:flibusta/model/authorInfo.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:flibusta/model/sequenceInfo.dart';
import 'package:flibusta/model/userContactData.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flibusta/services/server_status_checker.dart';
import 'package:flutter/foundation.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

Future<List<BookCard>> parseHtmlFromMakeBookList(
  String htmlString, [
  List<Map<int, String>> lastGenres,
]) async {
  htmldom.Document document = parse(htmlString);

  List<BookCard> result = [];
  var form = document.getElementsByTagName('form');
  if (form.isEmpty) {
    return result;
  }

  var bookCardDivs = form.first.getElementsByTagName('div');
  for (var i = 0; i < bookCardDivs.length; ++i) {
    int score;
    var allImgTags = bookCardDivs[i].getElementsByTagName('img');
    if (allImgTags.isNotEmpty) {
      switch (allImgTags.first.attributes['src']) {
        case '/img/znak.gif':
          score = 0;
          break;
        case '/img/znak1.gif':
          score = 1;
          break;
        case '/img/znak2.gif':
          score = 2;
          break;
        case '/img/znak3.gif':
          score = 3;
          break;
        case '/img/znak4.gif':
          score = 4;
          break;
        case '/img/znak5.gif':
          score = 5;
          break;
        default:
      }
    }

    var allATags = bookCardDivs[i].getElementsByTagName('a');
    if (allATags.isEmpty) {
      continue;
    }

    List<Map<int, String>> genres = [];
    if (bookCardDivs[i].getElementsByTagName('p').isNotEmpty) {
      bookCardDivs[i].getElementsByTagName('p')?.first?.getElementsByTagName('a')?.forEach((f) {
        genres.add({int.tryParse(f.attributes['href'].replaceAll('/g/', '')?.split('?')[0]): f.text});
      });
    } else {
      if (result?.isNotEmpty == true) {
        genres = result[i - 1].genres.list;
      } else {
        genres = lastGenres;
      }
    }

    var title =
        bookCardDivs[i].getElementsByTagName('a').where((element) => element.attributes['href'].contains('/b/'))?.first;

    List<Map<int, String>> translators = [];
    htmldom.Element sequence;

    var temp = title.nextElementSibling;
    while (temp.localName != 'span') {
      if (temp.attributes['href'] != null && temp.attributes['href'].contains('/a/')) {
        translators.add({int.tryParse(temp?.attributes['href']?.replaceAll('/a/', '')?.split('?')[0]): temp.text});
      } else if (temp.attributes['href'] != null && temp.attributes['href'].contains('/s/')) {
        sequence = temp;
      }
      temp = temp.nextElementSibling;
    }
    var size = temp;

    List<Map<String, String>> downloadFormats = [];
    for (temp = size.nextElementSibling;
        temp != null && temp.attributes['href'] != null && temp.attributes['href'].contains('/b/');
        temp = temp.nextElementSibling) {
      if (!await ProxyHttpClient().isAuthorized()) {
        var downloadFormatName = temp.text.replaceAll(RegExp(r'(\(|\))'), '');
        if (downloadFormatName == 'читать' || downloadFormatName == 'mail') {
          continue;
        }
        downloadFormatName = downloadFormatName.replaceAll('скачать ', '').trim();
        var downloadFormatType = temp.attributes['href'].split('/').last.split('?')[0];
        downloadFormats.add({downloadFormatName: downloadFormatType});
      }
    }

    List<Map<int, String>> authors = [];
    for (;
        temp != null && temp.attributes['href'] != null && temp.attributes['href'].contains('/a/');
        temp = temp.nextElementSibling) {
      authors.add({int.tryParse(temp?.attributes['href']?.replaceAll('/a/', '')?.split('?')[0]): temp.text});
    }

    result.add(BookCard(
      id: int.tryParse(title?.attributes['href']?.replaceAll('/b/', '')),
      genres: Genres(genres),
      title: title?.text,
      authors: Authors(authors),
      sequenceId:
          sequence != null ? int.tryParse(sequence?.attributes['href'].replaceAll('/s/', '').split('?')[0]) : null,
      sequenceTitle: sequence?.text,
      translators: Translators(translators),
      size: size.text,
      fileScore: score,
      downloadFormats: DownloadFormats(downloadFormats),
    ));
  }

  return result;
}

Future<List<BookCard>> parseHtmlFromLatestArrivals(
  String htmlString, [
  List<Map<int, String>> lastGenres,
]) async {
  if (htmlString.contains('<form name="bk" action="/mass/download" target="_blank">')) {
    htmlString = htmlString.replaceFirst(
      '<form name="bk" action="/mass/download" target="_blank">',
      '<form id="data">',
    );
  } else {
    htmlString = htmlString.replaceFirst('</form>', '</form><form id="data">');
  }
  htmldom.Document document = parse(htmlString);

  List<BookCard> result = [];
  var form = document.getElementById('data');
  if (form == null) {
    return result;
  }

  var formChildren = form.children;
  String addedToLibraryDate;

  for (var i = 0; i < formChildren.length; ++i) {
    if (formChildren[i].localName != 'div') {
      if (formChildren[i].localName == 'h4') {
        addedToLibraryDate = formChildren[i].text;
      }
      continue;
    }
    int score;
    var allImgTags = formChildren[i].getElementsByTagName('img');
    if (allImgTags.isNotEmpty) {
      switch (allImgTags.first.attributes['src']) {
        case '/img/znak.gif':
          score = 0;
          break;
        case '/img/znak1.gif':
          score = 1;
          break;
        case '/img/znak2.gif':
          score = 2;
          break;
        case '/img/znak3.gif':
          score = 3;
          break;
        case '/img/znak4.gif':
          score = 4;
          break;
        case '/img/znak5.gif':
          score = 5;
          break;
        default:
      }
    }

    var allATags = formChildren[i].getElementsByTagName('a');
    if (allATags.isEmpty) {
      continue;
    }

    List<Map<int, String>> genres = [];
    if (formChildren[i].getElementsByTagName('p').isNotEmpty) {
      formChildren[i].getElementsByTagName('p')?.first?.getElementsByTagName('a')?.forEach((f) {
        genres.add({int.tryParse(f.attributes['href'].replaceAll('/g/', '')?.split('?')[0]): f.text});
      });
    } else {
      if (result?.isNotEmpty == true) {
        genres = result.last.genres.list;
      } else {
        genres = lastGenres;
      }
    }

    var title =
        formChildren[i].getElementsByTagName('a').where((element) => element.attributes['href'].contains('/b/'))?.first;

    List<Map<int, String>> translators = [];
    htmldom.Element sequence;

    var temp = title.nextElementSibling;
    while (temp.localName != 'span') {
      if (temp.attributes['href'] != null && temp.attributes['href'].contains('/a/')) {
        translators.add({int.tryParse(temp?.attributes['href']?.replaceAll('/a/', '')?.split('?')[0]): temp.text});
      } else if (temp.attributes['href'] != null && temp.attributes['href'].contains('/s/')) {
        sequence = temp;
      }
      temp = temp.nextElementSibling;
    }
    var size = temp;

    List<Map<String, String>> downloadFormats = [];
    for (temp = size.nextElementSibling;
        temp != null && temp.attributes['href'] != null && temp.attributes['href'].contains('/b/');
        temp = temp.nextElementSibling) {
      if (!await ProxyHttpClient().isAuthorized()) {
        var downloadFormatName = temp.text.replaceAll(RegExp(r'(\(|\))'), '');
        if (downloadFormatName == 'читать' || downloadFormatName == 'mail') {
          continue;
        }
        downloadFormatName = downloadFormatName.replaceAll('скачать ', '').trim();
        var downloadFormatType = temp.attributes['href'].split('/').last.split('?')[0];
        downloadFormats.add({downloadFormatName: downloadFormatType});
      }
    }

    List<Map<int, String>> authors = [];
    for (;
        temp != null && temp.attributes['href'] != null && temp.attributes['href'].contains('/a/');
        temp = temp.nextElementSibling) {
      authors.add({int.tryParse(temp?.attributes['href']?.replaceAll('/a/', '')?.split('?')[0]): temp.text});
    }

    result.add(BookCard(
      id: int.tryParse(title?.attributes['href']?.replaceAll('/b/', '')),
      genres: Genres(genres),
      title: title?.text,
      authors: Authors(authors),
      sequenceId:
          sequence != null ? int.tryParse(sequence?.attributes['href'].replaceAll('/s/', '').split('?')[0]) : null,
      sequenceTitle: sequence?.text,
      translators: Translators(translators),
      size: size.text,
      fileScore: score,
      downloadFormats: DownloadFormats(downloadFormats),
      addedToLibraryDate: addedToLibraryDate,
    ));
  }

  return result;
}

SearchResults parseHtmlFromBookSearch(String htmlString) {
  SearchResults searchResults = SearchResults(
    books: [],
    authors: [],
    sequences: [],
  );
  htmldom.Document document = parse(htmlString);

  var mainIdTag = document.getElementById('main');
  if (mainIdTag == null) {
    return searchResults;
  }

  var divisions = mainIdTag.getElementsByTagName('h3');
  if (divisions == null || divisions.length == 0) {
    return searchResults;
  }

  divisions.forEach((division) {
    var divisionName = division.text.trim().split(' ')[1];
    switch (divisionName) {
      case 'книги':
        var bookLis = division.nextElementSibling.getElementsByTagName("li");
        bookLis.forEach((bookLi) {
          var bookAndAuthorTags = bookLi.getElementsByTagName("a");
          var bookId = int.tryParse(bookAndAuthorTags[0].attributes['href'].replaceAll('/b/', '').split('?')[0]);
          var bookTitle = bookAndAuthorTags[0].text;
          var authorId = int.tryParse(bookAndAuthorTags[1].attributes['href'].replaceAll('/a/', '').split('?')[0]);
          var authorName = bookAndAuthorTags[1].text;
          searchResults.books.add(BookCard(
              id: bookId,
              title: bookTitle,
              authors: Authors([
                {authorId: authorName}
              ])));
        });
        break;
      case 'писатели':
        var authorLis = division.nextElementSibling.getElementsByTagName('li');
        authorLis.forEach((authorLi) {
          var authorTag = authorLi.getElementsByTagName('a');
          var authorId = int.tryParse(authorTag[0].attributes['href'].replaceAll('/a/', '').split('?')[0]);
          var authorName = authorTag[0].text;
          var booksCount = authorLi.nodes[1].text.trim();
          searchResults.authors.add(AuthorCard(id: authorId, name: authorName, booksCount: booksCount));
        });
        break;
      case 'серии':
        var sequenceLis = division.nextElementSibling.getElementsByTagName('li');
        sequenceLis.forEach((sequenceLi) {
          var sequenceTag = sequenceLi.getElementsByTagName('a');
          var sequenceId = int.tryParse(sequenceTag[0].attributes['href'].replaceAll('/sequence/', '').split('?')[0]);
          var sequenceTitle = sequenceTag[0].text;
          var booksCount = sequenceLi.nodes[1].text.trim();
          searchResults.sequences.add(SequenceCard(id: sequenceId, title: sequenceTitle, booksCount: booksCount));
        });
        break;
    }
  });

  return searchResults;
}

BookInfo parseHtmlFromBookInfo(String htmlString, int bookId) {
  var bookInfo = BookInfo(id: bookId);
  htmldom.Document document = parse(htmlString);

  document.getElementById('content-top').remove();
  var mainElement = document.getElementById('main');
  var allA = mainElement.getElementsByTagName('a');

  var titleElement = mainElement.getElementsByClassName('title')?.first;
  bookInfo.title = titleElement?.text ?? '';

  var mainNode = titleElement.parentNode;
  var titleNodeIndex = mainNode.nodes.indexOf(titleElement);

  List<Map<int, String>> authorsList = [];
  List<Map<int, String>> translatorsList = [];
  var hasTranslators = false;

  for (int i = titleNodeIndex + 1;
      i < mainNode.nodes.length &&
          (mainNode.nodes[i].attributes['href'] == null ||
              !mainNode.nodes[i].attributes['href'].contains(RegExp(r'^(/g/)[0-9]*$')));
      ++i) {
    var currentNode = mainNode.nodes[i];

    if (currentNode.attributes['href'] != null && currentNode.attributes['href'].contains(RegExp(r'^(/a/)[0-9]*'))) {
      var id = int.tryParse(currentNode.attributes['href'].replaceAll('/a/', '').split('?')[0]);
      var name = currentNode.text;

      if (!hasTranslators) {
        authorsList.add({id: name});
      } else {
        translatorsList.add({id: name});
      }
    } else {
      if (currentNode.text.contains('(перевод:')) {
        hasTranslators = true;
      }
    }
  }
  bookInfo.authors = Authors(authorsList);
  bookInfo.translators = Translators(translatorsList);

  var genresA = allA.where((a) {
    return a.attributes['href'] != null && a.attributes['href'].contains(RegExp(r'^(/g/)[0-9]*'));
  });

  List<Map<int, String>> genresList = [];
  genresA.forEach((genreA) {
    var genreId = int.tryParse(genreA.attributes['href'].replaceAll('/g/', '').split('?')[0]);
    var genreName = genreA.text;
    genresList.add({genreId: genreName});
  });
  bookInfo.genres = Genres(genresList);

  List<Map<String, String>> downloadFormatsList = [];

  var useroptSelector = document.getElementById('useropt');
  if (useroptSelector != null) {
    var downloadFormatOptions = useroptSelector.children.where((element) => element.localName == 'option').toList();

    downloadFormatOptions.forEach((option) {
      var downloadFormatName = option.text.trim();
      var downloadFormatType = option.attributes['value'];
      downloadFormatsList.add({downloadFormatName: downloadFormatType});
    });
  } else {
    var downloadFormatsA = allA.where((a) {
      return a.attributes['href'] != null && a.attributes['href'].contains(RegExp('^(/b/$bookId/)(?!read).*'));
    });

    downloadFormatsA.forEach((downloadFormatA) {
      var downloadFormatName =
          downloadFormatA.text.replaceAll(RegExp(r'(\(|\))'), '').replaceAll('скачать ', '').trim();
      if (downloadFormatName == 'mail' ||
          downloadFormatName == 'исправить' ||
          downloadFormatName.contains('пожаловаться')) {
        return;
      }
      var downloadFormatType = downloadFormatA.attributes['href'].split('/').last.split('?')[0];
      downloadFormatsList.add({downloadFormatName: downloadFormatType});
    });
  }
  bookInfo.downloadFormats = DownloadFormats(downloadFormatsList);

  var sequenceA = allA.where((a) {
    return a.attributes['href'] != null && a.attributes['href'].contains(RegExp(r'^(/s/)[0-9]*'));
  });

  if (sequenceA.isNotEmpty) {
    bookInfo.sequenceId = int.tryParse(sequenceA.first.attributes['href'].replaceAll('/s/', '').split('?')[0]);
    bookInfo.sequenceTitle = sequenceA.first.text;
  }

  bookInfo.size = mainElement
      .getElementsByTagName('span')
      .where((span) {
        return span.attributes['style'] != null && span.attributes['style'] == 'size';
      })
      ?.first
      ?.text;

  var addedToLibraryDateStringStarts = mainNode.text.indexOf('Добавлена:');
  bookInfo.addedToLibraryDate =
      mainNode.text.substring(addedToLibraryDateStringStarts, addedToLibraryDateStringStarts + 21);

  var lemmaStringStarts = mainNode.text.indexOf('Аннотация') + 10;
  var lemmaStringEndsOnComplain = mainNode.text.indexOf('(пожаловаться');
  var lemmaStringEndsOnRecommendations = mainNode.text.indexOf('Рекомендации:');

  var lemmaStringEnds = mainNode.text.length;
  if (lemmaStringEndsOnComplain == -1 && lemmaStringEndsOnRecommendations != -1) {
    lemmaStringEnds = lemmaStringEndsOnRecommendations;
  } else if (lemmaStringEndsOnComplain != -1 && lemmaStringEndsOnRecommendations == -1) {
    lemmaStringEnds = lemmaStringEndsOnComplain;
  } else if (lemmaStringEndsOnComplain != -1 && lemmaStringEndsOnRecommendations != -1) {
    lemmaStringEnds = min(lemmaStringEndsOnComplain, lemmaStringEndsOnRecommendations);
  }

  bookInfo.lemma = mainNode.text.substring(lemmaStringStarts, lemmaStringEnds).trim();

  var fb2infoContent = mainElement.getElementsByClassName('fb2info-content');
  if (fb2infoContent.isEmpty) {
    return bookInfo;
  }

  bookInfo.coverImgSrc = fb2infoContent?.first?.nextElementSibling?.nextElementSibling?.attributes['src'];
  return bookInfo;
}

Future<AuthorInfo> parseHtmlFromAuthorInfo(String htmlString, int authorId) async {
  htmldom.Document document = parse(htmlString);

  var authorInfo = AuthorInfo(id: authorId, books: []);
  var mainElement = document.getElementById('main');
  authorInfo.name = mainElement.getElementsByTagName('h1').first.innerHtml;

  var forms = mainElement.getElementsByTagName('form');
  htmldom.Element form;
  forms.forEach((f) {
    if (f.attributes['method'] != null) {
      form = f;
    }
  });

  if (forms.isEmpty || form == null) {
    return authorInfo;
  }

  var formChildren = form.children;
  int actualSequenceId;
  String actualSequenceTitle;
  Genres actualGenres = Genres([]);
  Translators actualTranslators;
  BookCard actualBookCard;
  List<Map<String, String>> actualDownloadFormats;
  bool nextGenres = false;

  if (formChildren.any((htmldom.Element child) => child.localName == 'div')) {
    authorInfo.books = await parseHtmlFromMakeBookList(form.outerHtml);
    return authorInfo;
  }

  formChildren.forEach((htmldom.Element child) {
    if (child.localName == 'br' && actualDownloadFormats != null) {
      actualBookCard.translators = actualTranslators;
      actualBookCard.downloadFormats = DownloadFormats(actualDownloadFormats);
      authorInfo.books.add(actualBookCard);
      actualDownloadFormats = null;
      actualTranslators = null;
      actualBookCard = null;
      nextGenres = true;
      return;
    }

    if (child.localName == 'br' || child.localName == 'img' || child.localName == 'svg' || child.localName == 'input') {
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains('/a/')) {
      if (actualTranslators == null) {
        actualTranslators = Translators([]);
      }
      var translatorId = int.tryParse(child.attributes['href'].replaceAll('/a/', ''));
      var translatorName = child.text;
      actualTranslators.list.add({translatorId: translatorName});
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains('/s/')) {
      actualSequenceId = int.tryParse(child.attributes['href'].replaceAll("/s/", ''));
      actualSequenceTitle = child.text;
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains('/g/')) {
      if (nextGenres) {
        actualSequenceId = null;
        actualSequenceTitle = null;
        actualGenres = Genres([]);
        nextGenres = false;
      }

      var genreId = int.tryParse(child.attributes['href'].replaceAll('/g/', ''));
      var genreName = child.text;
      actualGenres.list.add({genreId: genreName});
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains(RegExp(r'^\/b\/\d*[^/]$'))) {
      actualBookCard = BookCard(
        id: int.tryParse(child.attributes['href'].replaceAll('/b/', '')),
        title: child.text,
        genres: actualGenres,
        sequenceId: actualSequenceId,
        sequenceTitle: actualSequenceTitle,
      );
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains(RegExp(r'^\/b\/\d*/.*$'))) {
      var downloadFormatName = child.text.replaceAll(RegExp(r'(\(|\))'), '');
      if (downloadFormatName == 'читать') {
        return;
      }
      downloadFormatName = downloadFormatName.replaceAll('скачать ', '');
      var downloadFormatType = child.attributes['href'].split('/').last.split('?')[0];
      if (actualDownloadFormats == null) {
        actualDownloadFormats = [];
      }
      actualDownloadFormats.add({downloadFormatName: downloadFormatType});
      return;
    }

    if (child.localName == 'span' && child.attributes['style'] == 'size' && actualBookCard != null) {
      actualBookCard.size = child.text;
      return;
    }
  });

  return authorInfo;
}

Future<SequenceInfo> parseHtmlFromSequenceInfo(String htmlString, int authorId) async {
  var sequenceInfo = SequenceInfo(id: authorId, books: []);
  htmldom.Document document = parse(htmlString);

  var mainElement = document.getElementById('main');
  sequenceInfo.title = mainElement.getElementsByTagName('h1').first.innerHtml;

  var mainElementChildren = mainElement.children;
  if (await ProxyHttpClient().isAuthorized()) {
    var formsInMainElement = mainElement.getElementsByTagName('form');
    for (var form in formsInMainElement) {
      if (form.attributes['name'] == 'bk') {
        mainElementChildren = form.children;
      }
    }
  }
  int actualSequenceId;
  String actualSequenceTitle;
  Genres actualGenres = Genres([]);
  Translators actualTranslators;
  Authors actualAuthors;
  BookCard actualBookCard;
  List<Map<String, String>> actualDownloadFormats;
  bool nextGenres = false;

  mainElementChildren.forEach((child) {
    if (child.localName == 'br' && actualDownloadFormats != null) {
      actualBookCard.translators = actualTranslators;
      actualBookCard.authors = actualAuthors;
      actualBookCard.downloadFormats = DownloadFormats(actualDownloadFormats);
      sequenceInfo.books.add(actualBookCard);
      actualDownloadFormats = null;
      actualTranslators = null;
      actualAuthors = null;
      actualBookCard = null;
      nextGenres = true;
      return;
    }

    if (child.localName == 'br' || child.localName == 'img' || child.localName == 'svg' || child.localName == 'input') {
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains('/a/')) {
      if (actualBookCard.size != null) {
        if (actualAuthors == null) {
          actualAuthors = Authors([]);
        }
        var authorId = int.tryParse(child.attributes['href'].replaceAll('/a/', ''));
        var authorName = child.text;
        actualAuthors.list.add({authorId: authorName});
        return;
      } else {
        if (actualTranslators == null) {
          actualTranslators = Translators([]);
        }
        var translatorId = int.tryParse(child.attributes['href'].replaceAll('/a/', ''));
        var translatorName = child.text;
        actualTranslators.list.add({translatorId: translatorName});
        return;
      }
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains('/s/')) {
      actualSequenceId = int.tryParse(child.attributes['href'].replaceAll('/s/', ''));
      actualSequenceTitle = child.text;
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains('/g/')) {
      if (nextGenres) {
        actualSequenceId = null;
        actualSequenceTitle = null;
        actualGenres = Genres([]);
        nextGenres = false;
      }

      var genreId = int.tryParse(child.attributes['href'].replaceAll('/g/', ''));
      var genreName = child.text;
      actualGenres.list.add({genreId: genreName});
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains(RegExp(r'^\/b\/\d*[^/]$'))) {
      actualBookCard = BookCard(
        id: int.tryParse(child.attributes['href'].replaceAll('/b/', '')),
        title: child.text,
        genres: actualGenres,
        sequenceId: actualSequenceId,
        sequenceTitle: actualSequenceTitle,
      );
      return;
    }

    if (child.attributes['href'] != null && child.attributes['href'].contains(RegExp(r'^\/b\/\d*/.*$'))) {
      var downloadFormatName = child.text.replaceAll(RegExp(r'(\(|\))'), '');
      if (downloadFormatName == 'читать') {
        return;
      }
      downloadFormatName = downloadFormatName.replaceAll('скачать ', '');
      var downloadFormatType = child.attributes['href'].split('/').last.split('?')[0];
      if (actualDownloadFormats == null) {
        actualDownloadFormats = [];
      }
      actualDownloadFormats.add({downloadFormatName: downloadFormatType});
      return;
    }

    if (child.localName == 'span' && child.attributes['style'] == 'size' && actualBookCard != null) {
      actualBookCard.size = child.text;
      return;
    }
  });

  return sequenceInfo;
}

List<AuthorCard> parseHtmlFromGetAuthors(String htmlString) {
  List<AuthorCard> result = [];
  htmlString =
      '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ru" xml:lang="ru">
<body id="body">
$htmlString
</body></html>''';

  htmldom.Document document = parse(htmlString);

  final authorsAndBookCountNodes = document.getElementById('body').nodes.where((node) {
    return (node is htmldom.Text && node.text.trim().isNotEmpty) ||
        (node is htmldom.Element && node.localName != 'div' && node.localName != 'br');
  });

  int authorId;
  String authorBookCount;
  String authorName;

  for (var node in authorsAndBookCountNodes) {
    if (node is htmldom.Element) {
      if (authorName != null && authorId != null) {
        result.add(
          AuthorCard(
            booksCount: authorBookCount,
            id: authorId,
            name: authorName,
          ),
        );
        authorName = null;
        authorId = null;
        authorBookCount = null;
      }
      authorName = node.text.trim();
      authorId = int.tryParse(node.attributes['href'].replaceAll('/a/', ''));
    } else if (node is htmldom.Text) {
      authorBookCount = node.text.trim().replaceAll(RegExp(r'(\(|\))'), '');
    }
  }
  if (authorName != null && authorId != null) {
    result.add(
      AuthorCard(
        booksCount: authorBookCount,
        id: authorId,
        name: authorName,
      ),
    );
    authorName = null;
    authorId = null;
    authorBookCount = null;
  }

  return result;
}

List<Genre> parseHtmlFromGetGenres(String htmlString) {
  List<Genre> result = [];

  // htmldom.Document document = parse(htmlString);

  // TODO: add implimentation

  return result;
}

List<SequenceCard> parseHtmlFromGetSequences(String htmlString) {
  List<SequenceCard> result = [];

  htmldom.Document document = parse(htmlString);

  final sequenceUl = document.getElementById('main')?.nodes?.firstWhere(
        (node) => node is htmldom.Element && node.localName == 'ul',
        orElse: () => null,
      );

  int sequenceId;
  String sequenceBookCount;
  String sequenceName;
  for (var li in sequenceUl.children) {
    for (var node in li.nodes) {
      if (node is htmldom.Element) {
        sequenceName = node.text.trim();
        sequenceId = int.tryParse(node.attributes['href'].replaceAll('/sequence/', ''));
      } else if (node is htmldom.Text) {
        sequenceBookCount = node.text.trim().replaceAll(RegExp(r'(\(|\))'), '');
      }
    }
    if (sequenceName != null && sequenceId != null) {
      result.add(
        SequenceCard(
          booksCount: sequenceBookCount,
          id: sequenceId,
          title: sequenceName,
        ),
      );
      sequenceName = null;
      sequenceId = null;
      sequenceBookCount = null;
    }
  }

  return result;
}

List<BookCard> parseHtmlFromGetGenreInfo(String htmlString) {
  List<BookCard> result = [];
  htmldom.Document document = parse(htmlString);

  var olElement = document.getElementsByTagName('ol');
  if (olElement?.isEmpty != false) return result;

  String currentAddedToLibraryDate;
  AuthorCard currentAuthor;

  olElement.first.children.forEach((element) {
    switch (element.localName) {
      case 'h4':
        currentAddedToLibraryDate = element.text;
        return;
      case 'h5':
        if (element.children?.isEmpty != false) return;

        var authorAElement = element.children.first;
        var href = authorAElement.attributes['href'];

        if (href?.contains('/a/') != true) return;

        currentAuthor = AuthorCard(
          id: int.tryParse(href.replaceAll('/a/', '')),
          name: authorAElement.text,
        );
        return;
      case 'a':
        var href = element.attributes['href'];

        if (href?.contains('/b/') != true) return;

        result.add(
          BookCard(
            id: int.tryParse(href.replaceAll('/b/', '')),
            title: element.text,
            authors: Authors([
              {currentAuthor.id: currentAuthor.name},
            ]),
            addedToLibraryDate: currentAddedToLibraryDate,
          ),
        );
        return;
    }
  });

  return result;
}

UserContactData parseHtmlFromUserMeEdit(String htmlString) {
  var result = UserContactData();

  htmldom.Document document = parse(htmlString);

  result.nickname =
      document.getElementsByTagName('h1').firstWhere((element) => element.className == 'title', orElse: null).innerHtml;

  var editMailElement = document.getElementById('edit-mail');
  if (editMailElement != null) {
    result.email = editMailElement.attributes['value'];
  }

  var elementsClassPicture = document?.getElementById('user-profile-form')?.getElementsByClassName('picture');

  if (elementsClassPicture?.isNotEmpty == true) {
    var elementsClassImg = elementsClassPicture.first?.getElementsByTagName('img');

    if (elementsClassImg?.isNotEmpty == true) {
      result.profileImgSrc = elementsClassImg.first?.attributes['src'];
    }
  }

  return result;
}

ServerStatusResult parseHtmlFromIsItDownRightNow(String htmlString) {
  var result = ServerStatusResult();

  htmldom.Document document = parse(htmlString);

  try {
    var bodyElement = document.getElementsByTagName('body').first;
    var divWithStatus = bodyElement.children[4];
    switch (divWithStatus.children.first.text) {
      case 'DOWN':
        result.isDown = true;
        break;
      case 'UP':
        result.isDown = false;
        break;
    }
    var engStatusText = divWithStatus.children.elementAt(1).text;
    if (engStatusText.contains('is UP and reachable by us.')) {
      result.statusText = 'Работает';
    } else if (engStatusText.contains('is DOWN  for everyone.')) {
      result.statusText = 'Не работает';
    } else {
      result.statusText = 'Неизвестно';
    }
  } on StateError catch (error) {
    debugPrint(error.toString());
  }

  return result;
}
