import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ThemeDataBloc implements BlocBase {
  static final ThemeDataBloc themeDataBloc = ThemeDataBloc._internal();

  factory ThemeDataBloc() {
    return themeDataBloc;
  }
  ThemeDataBloc._internal();

  var _themeDataController = BehaviorSubject<ThemeData>.seeded(null);
  Stream<ThemeData> get themeDataStream => _themeDataController.stream;
  Sink<ThemeData> get _themeDataSink => _themeDataController.sink;

  var _customDarkTheme = ThemeData.dark().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      isDense: true,
    ),
  );

  var _customLightTheme = ThemeData.light().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      isDense: true,
    ),
  );

  void switchToDarkTheme() {
    _themeDataSink.add(_customDarkTheme);
  }

  void switchToLightTheme() {
    _themeDataSink.add(_customLightTheme);
  }

  @override
  void dispose() {
    _themeDataController.close();
  }
}
