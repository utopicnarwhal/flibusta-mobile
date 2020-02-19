import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DynamicThemeMode extends StatefulWidget {
  const DynamicThemeMode({
    Key key,
    this.builder,
    this.defaultThemeMode = ThemeMode.system,
  }) : super(key: key);

  final Widget Function(BuildContext context, ThemeMode data) builder;

  final ThemeMode defaultThemeMode;

  @override
  _DynamicThemeModeState createState() => _DynamicThemeModeState();

  static _DynamicThemeModeState of(BuildContext context) {
    return context.findAncestorStateOfType<_DynamicThemeModeState>();
  }
}

class _DynamicThemeModeState extends State<DynamicThemeMode> {
  ThemeMode _themeMode;

  static const String _sharedPreferencesKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.defaultThemeMode;

    loadThemeMode().then((ThemeMode themeMode) {
      if (mounted) {
        setState(() {
          _themeMode = themeMode;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    setState(() {
      _themeMode = newThemeMode ?? widget.defaultThemeMode;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sharedPreferencesKey, _themeMode.index);
  }

  Future<ThemeMode> loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var themeModeIndex = prefs.getInt(_sharedPreferencesKey);
    if (themeModeIndex == null || themeModeIndex >= ThemeMode.values.length) {
      themeModeIndex = widget.defaultThemeMode.index;
    }
    return ThemeMode.values.elementAt(themeModeIndex);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _themeMode);
  }
}
