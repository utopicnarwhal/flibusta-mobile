import 'package:flibusta/model/grid_data/grid_data.dart';

class Genre extends GridData {
  final int id;
  final String name;
  final String code;

  Genre({
    this.id,
    this.name,
    this.code,
  }) : assert(id != null);

  @override
  String get tileSubtitle => this.code;

  @override
  String get tileTitle => this.name;
}