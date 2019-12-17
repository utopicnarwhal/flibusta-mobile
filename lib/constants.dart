import 'package:flutter/material.dart';

const MaterialColor kFlibustaBlueColor = MaterialColor(0xff56789b, const {
  50: const Color(0xffebeff3),
  100: const Color(0xffccd7e1),
  200: const Color(0xffabbccd),
  300: const Color(0xff89a1b9),
  400: const Color(0xff6f8caa),
  500: const Color(0xff56789b),
  600: const Color(0xff4f7093),
  700: const Color(0xff456589),
  800: const Color(0xff3c5b7f),
  900: const Color(0xff2b486d),
});

const MaterialColor kFlibustaLightBlueColor = MaterialColor(0xffa2c0dc, const {
  50: const Color(0xffe6eff6),
  100: const Color(0xffc3d8eb),
  200: const Color(0xffa2c0dc),
  300: const Color(0xff85a7cc),
  400: const Color(0xff7396c2),
  500: const Color(0xff6086be),
  600: const Color(0xff587ab1),
  700: const Color(0xff4d69a0),
  800: const Color(0xff43598f),
  900: const Color(0xff323d73),
});

final ThemeData kFlibustaLightTheme = ThemeData(
  primarySwatch: kFlibustaBlueColor,
  scaffoldBackgroundColor: Color(0xFFF8F8F8),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    isDense: true,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: kFlibustaBlueColor,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kCardBorderRadius),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
  ),
  dividerColor: Colors.grey.shade300,
  dividerTheme: DividerThemeData(
    thickness: 0.5,
    space: 0.5,
  ),
);

final ThemeData kFlibustaDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: kFlibustaLightBlueColor,
  primaryColorDark: kFlibustaLightBlueColor,
  accentColor: kFlibustaLightBlueColor,
  toggleableActiveColor: kFlibustaLightBlueColor,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    isDense: true,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: kFlibustaLightBlueColor,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kCardBorderRadius),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
  ),
  dividerColor: Colors.grey.shade600,
  dividerTheme: DividerThemeData(
    thickness: 0.5,
    space: 0.5,
  ),
);

const double kCardBorderRadius = 7;
