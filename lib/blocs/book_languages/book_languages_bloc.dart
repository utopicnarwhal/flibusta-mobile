import 'package:rxdart/rxdart.dart';

class BookLanguagesBloc {
  var _selectedLanguagesController;
  //output
  Stream<List<String>> get selectedLanguagesStream =>
      _selectedLanguagesController.stream;
  //input
  Sink<List<String>> get _selectedLanguagesSink =>
      _selectedLanguagesController.sink;

  final List<String> allBookLanguages = [
    'ru',
    'RU',
    'be',
    'kk',
    'uk',
    'ru~ru-petr1708',
  ];

  BookLanguagesBloc({List<String> selectedBookLanguages}) {
    _selectedLanguagesController =
        BehaviorSubject<List<String>>.seeded(selectedBookLanguages ?? []);
  }

  List<String> getSelectedLanguages() {
    return _selectedLanguagesController.value;
  }

  void addToSelectedLanguages(String format) {
    if (!_selectedLanguagesController.value.contains(format)) {
      _selectedLanguagesSink
          .add(_selectedLanguagesController.value..add(format));
    }
  }

  void removeFromSelectedLanguages(String format) {
    _selectedLanguagesSink
        .add(_selectedLanguagesController.value..remove(format));
  }

  void dispose() {
    _selectedLanguagesController.close();
  }
}
