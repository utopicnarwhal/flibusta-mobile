import 'package:flibusta/model/grid_data/grid_data.dart';

class Genre extends GridData {
  int id;
  String name;
  String code;
  int bookCount;
  bool isHidden;

  Genre({
    this.id,
    this.name,
    this.code,
    this.bookCount,
    this.isHidden,
  });

  @override
  String get tileSubtitle => this.code;

  @override
  String get tileTitle => this.name;
}
