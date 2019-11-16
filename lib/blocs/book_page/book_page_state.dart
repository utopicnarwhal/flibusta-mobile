import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BookPageState extends Equatable {
  BookPageState([List props = const []]);

  @override
  List<Object> get props => props;
}

class InitialBookPageState extends BookPageState {
  @override
  List<Object> get props => null;
}
