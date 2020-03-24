import 'package:flibusta/blocs/grid/grid_data/grid_data_repository.dart';
import 'package:flibusta/model/genre.dart';
import 'package:rxdart/rxdart.dart';

class GenresListBloc {
  var _selectedGenresListController = BehaviorSubject<List<Genre>>.seeded([]);
  //output
  Stream<List<Genre>> get selectedGenresListStream =>
      _selectedGenresListController.stream;
  //input
  Sink<List<Genre>> get _selectedGenresListSink =>
      _selectedGenresListController.sink;

  var _allGenresListController = BehaviorSubject<List<Genre>>();
  //output
  Stream<List<Genre>> get allGenresListStream =>
      _allGenresListController.stream;
  //input
  Sink<List<Genre>> get _allGenresListSink => _allGenresListController.sink;

  GenresListBloc() {
    GridDataRepository().getGenres(null).then((genresList) {
      if (_allGenresListController.isClosed) return;
      _allGenresListSink.add(genresList);
    });
  }

  refreshGenresList() {
    GridDataRepository().getGenres(null).then((genresList) {
      if (_allGenresListController.isClosed) return;
      _allGenresListSink.add(genresList);
    });
  }

  addToGenresList(Genre genre) {
    if (!_selectedGenresListController.value.contains(genre)) {
      _selectedGenresListSink
          .add(_selectedGenresListController.value..add(genre));
    }
  }

  removeFromGenresList(Genre genre) {
    _selectedGenresListSink
        .add(_selectedGenresListController.value..remove(genre));
  }

  void dispose() {
    _selectedGenresListController.close();
    _allGenresListController.close();
  }
}
