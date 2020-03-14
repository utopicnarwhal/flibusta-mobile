import 'package:flibusta/model/bookCard.dart';

import 'grid_data/grid_data.dart';

class SearchResults {
  List<BookCard> books;
  List<AuthorCard> authors;
  List<SequenceCard> sequences;

  SearchResults({this.books, this.authors, this.sequences});
}

class AuthorCard extends GridData {
  int id;
  String name;
  String booksCount;

  AuthorCard({this.id, this.name, this.booksCount}) : assert(id != null);

  @override
  String get tileSubtitle => '$booksCount';

  @override
  String get tileTitle => name;
}

class SequenceCard extends GridData {
  int id;
  String title;
  String booksCount;

  SequenceCard({this.id, this.title, this.booksCount}) : assert(id != null);

  @override
  String get tileSubtitle => '$booksCount книг';

  @override
  String get tileTitle => title;
}
