import 'package:flutter/material.dart';

enum SnackBarType {
  error,
  success,
  warning,
  notification,
}

class SnackBarUtils {
  static void showSnackBar(
    GlobalKey<ScaffoldState> scaffoldKey,
    String message, {
    SnackBarType type = SnackBarType.notification,
  }) {
    if (scaffoldKey == null || message == null) {
      print('Нет scaffoldKey или сообщения');
    }
    var backgroundColor;
    switch (type) {
      case SnackBarType.error:
        backgroundColor = Colors.red;
        break;
      case SnackBarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.deepOrange;
        break;
      default:
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
        duration: Duration(seconds: 5),
      ),
    );
  }
}