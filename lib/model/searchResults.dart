import 'package:flibusta/model/bookCard.dart';

class SearchResults {
  List<BookCard> books;
  List<AuthorCard> authors;
  List<SequenceCard> sequences;

  SearchResults({this.books, this.authors, this.sequences});
}

class AuthorCard {
  int id;
  String name;
  String booksCount;

  AuthorCard({this.id, this.name, this.booksCount}): assert(id != null);
}

class SequenceCard {
  int id;
  String title;
  String booksCount;

  SequenceCard({this.id, this.title, this.booksCount}): assert(id != null);
}