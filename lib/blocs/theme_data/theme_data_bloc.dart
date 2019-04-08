import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class ThemeDataBloc implements BlocBase {
  static final ThemeDataBloc themeDataBloc = ThemeDataBloc._internal();

  factory ThemeDataBloc() {
    return themeDataBloc;
  }
  ThemeDataBloc._internal();

  var _themeDataController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get themeDataStream => _themeDataController.stream;
  Sink<bool> get _themeDataSink => _themeDataController.sink;

  void switchToDarkTheme() {
    _themeDataSink.add(true);
  }

  void switchToLightTheme() {
    _themeDataSink.add(false);
  }

  @override
  void dispose() {
    _themeDataController.close();
  }
}
