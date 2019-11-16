import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final int id;
  final String name;
  final String code;

  Genre({
    this.id,
    this.name,
    this.code,
  }) : assert(id != null);

  @override
  List<Object> get props => [id];
}