import 'package:flibusta/model/bookCard.dart';

class SequenceInfo {
  int id;
  String title;
  List<BookCard> books;

  SequenceInfo({
    this.id,
    this.title,
    this.books,
  }): assert(id != null);
}