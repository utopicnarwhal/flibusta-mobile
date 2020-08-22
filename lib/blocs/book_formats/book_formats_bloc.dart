import 'package:rxdart/rxdart.dart';

class BookFormatsBloc {
  var _selectedFormatsController;
  //output
  Stream<List<String>> get selectedFormatsStream =>
      _selectedFormatsController.stream;
  //input
  Sink<List<String>> get _selectedFormatsSink =>
      _selectedFormatsController.sink;

  final List<String> allBookFormats = [
    'fb2',
    'epub',
    'mobi',
    'pdf',
    'djvu',
    'doc',
    'html',
    'chm',
    'rtf',
    'txt',
    'exe',
    'docx',
    'pdb',
    'rgo',
    'lrf',
    'mht',
    'jpg',
    'mhtm',
    'dic',
    'xml',
    'htm',
    'azw',
    'png',
    'odt',
    'tex',
    'azw3',
    'dat',
    'mp3',
    'cbr',
    '7zip',
    'djv',
    'word',
    'prc',
    'pdg',
    'wri',
    'wps',
    'xps',
    'sxw',
    'gdoc',
    'phf',
    'epab',
    'zip',
    'docs',
  ];

  BookFormatsBloc({List<String> selectedBookFormats}) {
    _selectedFormatsController =
        BehaviorSubject<List<String>>.seeded(selectedBookFormats ?? []);
  }

  List<String> getSelectedFormats() {
    return _selectedFormatsController.value;
  }

  void addToSelectedFormats(String format) {
    if (!_selectedFormatsController.value.contains(format)) {
      _selectedFormatsSink.add(_selectedFormatsController.value..add(format));
    }
  }

  void removeFromSelectedFormats(String format) {
    _selectedFormatsSink.add(_selectedFormatsController.value..remove(format));
  }

  void dispose() {
    _selectedFormatsController.close();
  }
}
