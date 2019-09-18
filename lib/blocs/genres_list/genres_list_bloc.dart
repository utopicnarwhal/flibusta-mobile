import 'package:dio/dio.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:rxdart/rxdart.dart';

class GenresListBloc {
  var _selectedGenresListController = BehaviorSubject<List<Genre>>.seeded([]);
  //output
  Stream<List<Genre>> get selectedGenresListStream => _selectedGenresListController.stream;
  //input
  Sink<List<Genre>> get _selectedGenresListSink => _selectedGenresListController.sink;

  var _allGenresListController = BehaviorSubject<List<Genre>>();
  //output
  Stream<List<Genre>> get allGenresListStream => _allGenresListController.stream;
  //input
  Sink<List<Genre>> get _allGenresListSink => _allGenresListController.sink;

  GenresListBloc() {
    _getAllGenres().then((genresList) => _allGenresListSink.add(genresList));
  }

  addToGenresList(Genre genre) {
    if (!_selectedGenresListController.value.contains(genre)) {
      _selectedGenresListSink.add(_selectedGenresListController.value..add(genre));
    }
  }

  removeFromGenresList(Genre genre) {
    _selectedGenresListSink.add(_selectedGenresListController.value..remove(genre));
  }

  void dispose() {
    _selectedGenresListController.close();
    _allGenresListController.close();
  }
}

Future<List<Genre>> _getAllGenres() async {
  Dio _dio = ProxyHttpClient().getDio();

  var result = List<Genre>();
  Map<String, String> queryParams = {
    "op": "getList",
  };
  Uri url = Uri.https(
      ProxyHttpClient().getFlibustaHostAddress(), "/ajaxro/genre", queryParams);
  try {
    var response = await _dio.getUri(url);
    response.data.forEach((headIndex, headGenre) {
      headGenre.forEach((genre) {
        result.add(Genre(
          id: int.tryParse(genre["id"]),
          name: genre["name"],
          code: genre["code"],
        ));
      });
    });
    return result;
  } catch (error) {
    print(error);
    return _getAllGenres();
  }
}
