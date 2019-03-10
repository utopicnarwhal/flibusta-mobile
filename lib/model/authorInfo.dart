import 'package:flibusta/model/bookCard.dart';

class AuthorInfo {
  int id;
  String name;
  List<BookCard> books;

  AuthorInfo({
    this.id,
    this.name,
    this.books,
  }): assert(id != null);
}