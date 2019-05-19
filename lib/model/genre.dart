import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  int id;
  String name;
  String code;

  Genre({
    this.id,
    this.name,
    this.code,
  }) : assert(id != null), super([id]);
}