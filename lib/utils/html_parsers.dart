import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/model/searchResults.dart';
import 'package:html/dom.dart' as htmldom;

List<BookCard> parseHtmlFromMakeBookList(htmldom.Document document) {
  var result = List<BookCard>();
  var form = document.getElementsByTagName("form");
  if (form.isEmpty) {
    return result;
  }

  var bookCardDivs = form.first.getElementsByTagName("div");
  for (var i = 0; i < bookCardDivs.length; ++i) {
    var allATags = bookCardDivs[i].getElementsByTagName("a");
    if (allATags.isEmpty) {
      continue;
    }

    var genres = List<Map<int, String>>();
    if (bookCardDivs[i].getElementsByTagName("p").isNotEmpty) {
      bookCardDivs[i].getElementsByTagName("p")?.first?.getElementsByTagName("a")?.forEach((f) {
        genres.add({ int.tryParse(f.attributes["href"].replaceAll("/g/", "")): f.text });
      });
    } else {
      genres = result[i-1].genres.list;
    }
    
    var title = bookCardDivs[i].getElementsByTagName("input")?.first?.nextElementSibling;

    var translators = List<Map<int, String>>();
    htmldom.Element sequence;

    var temp = title.nextElementSibling;
    while (temp.localName != "span") {
      if (temp.attributes["href"] != null && temp.attributes["href"].contains("/a/")) {
        translators.add({ int.tryParse(temp?.attributes["href"]?.replaceAll("/a/", "")): temp.text });
      } else if (temp.attributes["href"] != null && temp.attributes["href"].contains("/s/")) {
        sequence = temp;
      }
      temp = temp.nextElementSibling;
    }
    var size = temp;

    var downloadFormats = List<Map<String, String>>();
    for (temp = size.nextElementSibling; temp.attributes["href"] != null && temp.attributes["href"].contains("/b/"); temp = temp.nextElementSibling) {
      var downloadFormatName = temp.text.replaceAll(RegExp(r'(\(|\))'), "");
      if (downloadFormatName == 'читать') {
        continue;
      }
      downloadFormatName = downloadFormatName.replaceAll("скачать ", "");
      var downloadFormatType = temp.attributes["href"].split("/").last;
      downloadFormats.add({ downloadFormatName: downloadFormatType });
    }

    var authors = List<Map<int, String>>();
    for (; temp.attributes["href"] != null && temp.attributes["href"].contains("/a/"); temp = temp.nextElementSibling) {
      authors.add({ int.tryParse(temp?.attributes["href"]?.replaceAll("/a/", "")): temp.text });
    }

    result.add(BookCard(
      id: int.tryParse(bookCardDivs[i].getElementsByTagName("input")?.first?.attributes["name"]?.replaceAll("bchk", "")),
      genres: Genres(genres),
      title: title?.text,
      authors: Authors(authors),
      sequenceId: sequence != null ? int.tryParse(sequence?.attributes["href"]?.replaceAll("/s/", "")) : null,
      sequenceTitle: sequence?.text,
      translators: Translators(translators),
      size: size.text,
      downloadFormats: DownloadFormats(downloadFormats),
    ));
  }

  return result;
}

SearchResults parseHtmlFromBookSearch(htmldom.Document document) {
  SearchResults searchResults = SearchResults(books: List<BookCard>(), authors: List<AuthorCard>(), sequences: List<SequenceCard>());

  var mainIdTag = document.getElementById("main");
  if (mainIdTag == null) {
    return searchResults;
  }

  var divisions = mainIdTag.getElementsByTagName("h3");
  if (divisions == null || divisions.length == 0) {
    return searchResults;
  }

  divisions.forEach((division) {
    var divisionName = division.text.trim().split(" ")[1];
    switch (divisionName) {
      case "книги":
        var bookLis = division.nextElementSibling.getElementsByTagName("li");
        bookLis.forEach((bookLi) {
          var bookAndAuthorTags = bookLi.getElementsByTagName("a");
          var bookId = int.tryParse(bookAndAuthorTags[0].attributes["href"].replaceAll("/b/", ""));
          var bookTitle = bookAndAuthorTags[0].text;
          var authorId = int.tryParse(bookAndAuthorTags[1].attributes["href"].replaceAll("/a/", ""));
          var authorName = bookAndAuthorTags[1].text;
          searchResults.books.add(BookCard(id: bookId, title: bookTitle, authors: Authors([{authorId: authorName}])));
        });
        break;
      case "писатели":
        var authorLis = division.nextElementSibling.getElementsByTagName("li");
        authorLis.forEach((authorLi) {
          var authorTag = authorLi.getElementsByTagName("a");
          var authorId = int.tryParse(authorTag[0].attributes["href"].replaceAll("/a/", ""));
          var authorName = authorTag[0].text;
          var booksCount = authorLi.nodes[1].text.trim();
          searchResults.authors.add(AuthorCard(id: authorId, name: authorName, booksCount: booksCount));
        });
        break;
      case "серии":
        var sequenceLis = division.nextElementSibling.getElementsByTagName("li");
        sequenceLis.forEach((sequenceLi) {
          var sequenceTag = sequenceLi.getElementsByTagName("a");
          var sequenceId = int.tryParse(sequenceTag[0].attributes["href"].replaceAll("/sequence/", ""));
          var sequenceTitle = sequenceTag[0].text;
          var booksCount = sequenceLi.nodes[1].text.trim();
          searchResults.sequences.add(SequenceCard(id: sequenceId, title: sequenceTitle, booksCount: booksCount));
        });
        break;
    }
  });

  return searchResults;
}

BookInfo parseHtmlFromBookInfo(htmldom.Document document, int bookId) {
  var bookInfo = BookInfo(id: bookId);

  document.getElementById("content-top").remove();
  var mainElement = document.getElementById("main");
  var allA = mainElement.getElementsByTagName("a");

  var titleElement = mainElement.getElementsByClassName("title")?.first;
  bookInfo.title = titleElement?.text ?? "";
  
  var mainNode = titleElement.parentNode;
  var titleNodeIndex = mainNode.nodes.indexOf(titleElement);

  var authorsList = List<Map<int, String>>();
  var translatorsList = List<Map<int, String>>();
  var hasTranslators = false;

  for (int i = titleNodeIndex + 1; i < mainNode.nodes.length && (mainNode.nodes[i].attributes["href"] == null || !mainNode.nodes[i].attributes["href"].contains(RegExp(r"^(/g/)[0-9]*$"))); ++i) {
    var currentNode = mainNode.nodes[i];

    if (currentNode.attributes["href"] != null && currentNode.attributes["href"].contains(RegExp(r"^(/a/)[0-9]*$"))) {
      var id = int.tryParse(currentNode.attributes["href"]?.replaceAll("/a/", ""));
      var name = currentNode.text;

      if (!hasTranslators) {
        authorsList.add({id: name});
      } else {
        translatorsList.add({id: name});
      }
    } else {
      if (currentNode.text.contains("(перевод:")) {
        hasTranslators = true;
      }
    }
  }
  bookInfo.authors = Authors(authorsList);
  bookInfo.translators = Translators(translatorsList);

  var genresA = allA.where((a) {
    return a.attributes["href"] != null && a.attributes["href"].contains(RegExp(r"^(/g/)[0-9]*$"));
  });
  var downloadFormatsA = allA.where((a) {
    return a.attributes["href"] != null && a.attributes["href"].contains(RegExp("^(/b/$bookId/)(?!read).*\$"));
  });

  var genresList = List<Map<int, String>>();
  genresA.forEach((genreA) {
    var genreId = int.tryParse(genreA.attributes["href"]?.replaceAll("/g/", ""));
    var genreName = genreA.text;
    genresList.add({genreId: genreName});
  });
  bookInfo.genres = Genres(genresList);

  var downloadFormatsList = List<Map<String, String>>();
  downloadFormatsA.forEach((downloadFormatA) {
    var downloadFormatName = downloadFormatA.text.replaceAll(RegExp(r'(\(|\))'), "").replaceAll("скачать ", "");
    var downloadFormatType = downloadFormatA.attributes["href"].split("/").last;
    downloadFormatsList.add({ downloadFormatName: downloadFormatType });
  });
  bookInfo.downloadFormats = DownloadFormats(downloadFormatsList);

  var sequenceA = allA.where((a) {
    return a.attributes["href"] != null && a.attributes["href"].contains(RegExp(r"^(/s/)[0-9]*$"));
  });

  if (sequenceA.isNotEmpty) {
    bookInfo.sequenceId = int.tryParse(sequenceA.first.attributes["href"]?.replaceAll("/s/", ""));
    bookInfo.sequenceTitle = sequenceA.first.text;
  }
  
  bookInfo.size = mainElement.getElementsByTagName("span").where((span) {
    return span.attributes["style"] != null && span.attributes["style"] == "size";
  })?.first?.text;
  var addedToLibraryDateStringStarts = mainNode.text.indexOf("Добавлена:");
  bookInfo.addedToLibraryDate = mainNode.text.substring(addedToLibraryDateStringStarts, addedToLibraryDateStringStarts + 21);
  var lemmaStringStarts = mainNode.text.indexOf("Аннотация") + 10;
  var lemmaStringEnds = mainNode.text.indexOf("Рекомендации:");
  bookInfo.lemma = mainNode.text.substring(lemmaStringStarts, lemmaStringEnds).trimRight();

  var fb2infoContent = mainElement.getElementsByClassName("fb2info-content");
  if (fb2infoContent.isEmpty) {
    return bookInfo;
  }

  bookInfo.coverImgSrc = fb2infoContent?.first?.nextElementSibling?.nextElementSibling?.attributes["src"];
  return bookInfo;
}