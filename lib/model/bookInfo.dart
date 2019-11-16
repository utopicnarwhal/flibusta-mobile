import 'package:flibusta/model/bookCard.dart';

class BookInfo extends BookCard {
  String coverImgSrc;
  String addedToLibraryDate;
  String lemma;
  String publishYear;

  BookInfo({
    id,
    title,
    this.coverImgSrc,
    this.addedToLibraryDate,
    this.lemma,
    this.publishYear,
    genres,
    sequenceId,
    sequenceTitle,
    size,
    downloadFormats,
    authors,
    translators,
  })  : assert(id != null),
        super(
          id: id,
          title: title,
          genres: genres,
          sequenceId: sequenceId,
          sequenceTitle: sequenceTitle,
          size: size,
          downloadFormats: downloadFormats,
          authors: authors,
          translators: translators,
        );
}
