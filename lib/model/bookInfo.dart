import 'package:flibusta/model/bookCard.dart';

class BookInfo {
  int id;
  String title;
  String coverImgSrc;
  String addedToLibraryDate;
  String lemma;
  String publishYear;
  Genres genres;
  int sequenceId;
  String sequenceTitle;
  String size;
  DownloadFormats downloadFormats;
  Authors authors;
  Translators translators;
  double downloadProgress;

  BookInfo({
    this.id,
    this.title,
    this.coverImgSrc,
    this.addedToLibraryDate,
    this.lemma,
    this.publishYear,
    this.genres,
    this.sequenceId,
    this.sequenceTitle,
    this.size,
    this.downloadFormats,
    this.authors,
    this.translators,
  }): assert(id != null);
}