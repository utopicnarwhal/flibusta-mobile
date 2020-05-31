import 'package:flibusta/model/bookCard.dart';
import 'package:json_annotation/json_annotation.dart';

import 'grid_data/grid_data.dart';

part 'searchResults.g.dart';

class SearchResults {
  List<BookCard> books;
  List<AuthorCard> authors;
  List<SequenceCard> sequences;

  SearchResults({this.books, this.authors, this.sequences});
}

@JsonSerializable()
class AuthorCard extends GridData {
  int id;
  String name;
  String booksCount;

  AuthorCard({this.id, this.name, this.booksCount}) : assert(id != null);

  @override
  String get tileSubtitle => '$booksCount';

  @override
  String get tileTitle => name;

  factory AuthorCard.fromJson(Map<String, dynamic> json) =>
      _$AuthorCardFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorCardToJson(this);
}

@JsonSerializable()
class SequenceCard extends GridData {
  int id;
  String title;
  String booksCount;

  SequenceCard({this.id, this.title, this.booksCount}) : assert(id != null);

  @override
  String get tileSubtitle => '$booksCount книг';

  @override
  String get tileTitle => title;

  factory SequenceCard.fromJson(Map<String, dynamic> json) =>
      _$SequenceCardFromJson(json);
  Map<String, dynamic> toJson() => _$SequenceCardToJson(this);
}
