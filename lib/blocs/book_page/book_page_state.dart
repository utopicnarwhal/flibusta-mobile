import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BookPageState extends Equatable {
  BookPageState([List props = const []]) : super(props);
}

class InitialBookPageState extends BookPageState {}
