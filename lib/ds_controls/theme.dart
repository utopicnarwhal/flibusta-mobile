import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ui/input_border.dart';

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

/// 10
const double kCardBorderRadius = 10;

/// 10
const double kPopupMenuBorderRadius = 10;

/// 18
const double kBottomSheetBorderRadius = 18;

const kErrorColor = Color(0xFFD70C17);

const _kSecondaryColorLightTheme = Color(0xFF334E7B);
const _kSecondaryColorDarkTheme = Color(0xFF4A7FD7);
Color kSecondaryColor(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return _kSecondaryColorLightTheme;
  }
  return _kSecondaryColorDarkTheme;
}

const _kLightThemeDisabledFieldTextColor = Color(0xFF777777);
const _kDarkThemeDisabledFieldTextColor = Color(0xFFDDDDDD);
Color kDisabledFieldTextColor(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return _kLightThemeDisabledFieldTextColor;
  }
  return _kDarkThemeDisabledFieldTextColor;
}

const _kLightThemeDividerColor = Color(0xFFDDDDDD);
const _kDarkThemeDividerColor = Color(0xFF888888);

const kDefaultFieldBorderWidth = 1.0;
const kActiveFieldBorderWidth = 4.0;
const kFieldBorderRadius = 4.0;

final _inputDecorationLightTheme = InputDecorationTheme(
  border: DsInputBorder(
    borderSide: BorderSide(
      width: kDefaultFieldBorderWidth,
      color: _kLightThemeDividerColor,
    ),
    outlineColor: _kLightThemeDividerColor,
  ),
  focusedBorder: DsInputBorder(
    borderSide: BorderSide(
      width: kActiveFieldBorderWidth,
      color: _kSecondaryColorLightTheme,
    ),
    outlineColor: _kLightThemeDividerColor,
  ),
  focusedErrorBorder: DsInputBorder(
    borderSide: BorderSide(
      width: kActiveFieldBorderWidth,
      color: _kSecondaryColorLightTheme,
    ),
    outlineColor: _kLightThemeDividerColor,
  ),
  errorBorder: DsInputBorder(
    borderSide: BorderSide(
      width: kActiveFieldBorderWidth,
      color: kErrorColor,
    ),
    outlineColor: _kLightThemeDividerColor,
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  fillColor: Color(0xFFEEEEEE),
);

final _inputDecorationDarkTheme = InputDecorationTheme(
  border: DsInputBorder(
    borderSide: BorderSide(
      width: kDefaultFieldBorderWidth,
      color: _kDarkThemeDividerColor,
    ),
    outlineColor: _kDarkThemeDividerColor,
  ),
  focusedBorder: DsInputBorder(
    borderSide: BorderSide(
      width: kActiveFieldBorderWidth,
      color: _kSecondaryColorDarkTheme,
    ),
    outlineColor: _kDarkThemeDividerColor,
  ),
  focusedErrorBorder: DsInputBorder(
    borderSide: BorderSide(
      width: kActiveFieldBorderWidth,
      color: _kSecondaryColorDarkTheme,
    ),
    outlineColor: _kDarkThemeDividerColor,
  ),
  errorBorder: DsInputBorder(
    borderSide: BorderSide(
      width: kActiveFieldBorderWidth,
      color: kErrorColor,
    ),
    outlineColor: _kDarkThemeDividerColor,
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  fillColor: Color(0xFF666666),
);

final _buttonTheme = ButtonThemeData(
  textTheme: ButtonTextTheme.primary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5.0),
  ),
);

final _cardTheme = CardTheme(
  margin: EdgeInsets.zero,
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kCardBorderRadius),
  ),
);

final _dialogTheme = DialogTheme(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kPopupMenuBorderRadius),
  ),
);

final _dividerTheme = DividerThemeData(space: 1, thickness: 0.5);

final _snackBarTheme = SnackBarThemeData(behavior: SnackBarBehavior.fixed);

final _popupMenuTheme = PopupMenuThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(kPopupMenuBorderRadius),
  ),
);

final _bottomSheetTheme = BottomSheetThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(kBottomSheetBorderRadius),
    ),
  ),
);

final _buttonBarTheme = ButtonBarThemeData();

final ThemeData kFlibustaLightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: kFlibustaBlueColor,
  fontFamily: 'Inter',
  inputDecorationTheme: _inputDecorationLightTheme,
  buttonTheme: _buttonTheme,
  cardTheme: _cardTheme,
  dialogTheme: _dialogTheme,
  scaffoldBackgroundColor: Color(0xFFF8F8F8),
  dividerColor: _kLightThemeDividerColor,
  dividerTheme: _dividerTheme,
  snackBarTheme: _snackBarTheme,
  popupMenuTheme: _popupMenuTheme,
  bottomSheetTheme: _bottomSheetTheme,
  buttonBarTheme: _buttonBarTheme,
  cupertinoOverrideTheme: CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
    brightness: Brightness.light,
  ),
);

final ThemeData kFlibustaDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: kFlibustaLightBlueColor,
  fontFamily: 'Inter',
  primaryColorDark: kFlibustaLightBlueColor,
  iconTheme: IconThemeData(color: Color(0xFFDDDDDD)),
  accentColor: kFlibustaLightBlueColor,
  toggleableActiveColor: kFlibustaLightBlueColor,
  inputDecorationTheme: _inputDecorationDarkTheme,
  buttonTheme: _buttonTheme,
  cardTheme: _cardTheme,
  dialogTheme: _dialogTheme,
  dividerColor: _kDarkThemeDividerColor,
  dividerTheme: _dividerTheme,
  snackBarTheme: _snackBarTheme,
  popupMenuTheme: _popupMenuTheme,
  bottomSheetTheme: _bottomSheetTheme,
  buttonBarTheme: _buttonBarTheme,
  cupertinoOverrideTheme: CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
    brightness: Brightness.dark,
  ),
);
