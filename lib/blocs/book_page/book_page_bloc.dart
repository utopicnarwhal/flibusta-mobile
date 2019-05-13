import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class BookPageBloc extends Bloc<BookPageEvent, BookPageState> {
  @override
  BookPageState get initialState => InitialBookPageState();

  @override
  Stream<BookPageState> mapEventToState(
    BookPageEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
