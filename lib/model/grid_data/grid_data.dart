import 'package:json_annotation/json_annotation.dart';

abstract class GridData {
  int id;

  @JsonKey(ignore: true)
  String get tileTitle;

  @JsonKey(ignore: true)
  String get tileSubtitle;
}
