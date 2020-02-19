import 'package:flibusta/main.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

enum ToastType {
  error,
  success,
  warning,
  notification,
}

class ToastUtils {
  static void showToast(
    String message, {
    ToastType type = ToastType.notification,
    SnackBarAction action,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (message == null) {
      print('Нет сообщения');
      return;
    }

    showToastWidget(
      _ToastCard(
        message: message,
        action: action,
        type: type,
      ),
      duration: duration,
    );
  }
}

class _ToastCard extends StatelessWidget {
  final String message;
  final SnackBarAction action;
  final ToastType type;

  const _ToastCard({
    Key key,
    this.message,
    this.action,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        textColor = Color(0xFFFFFFFF).withOpacity(0.87);
        break;
      case ToastType.warning:
        backgroundColor = Colors.deepOrange;
        textColor = Color(0xFFFFFFFF).withOpacity(0.87);
        break;
      default:
    }

    return Theme(
      data: _generateInverseTheme(),
      child: GestureDetector(
        onTap: () {
          dismissAllToast(showAnim: true);
        },
        child: Card(
          elevation: 8,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          margin: EdgeInsets.fromLTRB(8, FlibustaApp.statusBarHeight + 8, 8, 8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: textColor),
                  ),
                ),
                action != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FlatButton(
                          onPressed: action.onPressed,
                          child: Text(action.label),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _generateInverseTheme() {
    final ThemeData theme = FlibustaApp.currentTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isThemeDark = theme.brightness == Brightness.dark;

    final Brightness brightness =
        isThemeDark ? Brightness.light : Brightness.dark;
    final Color themeBackgroundColor = isThemeDark
        ? colorScheme.onSurface
        : Color.alphaBlend(
            colorScheme.onSurface.withOpacity(0.80), colorScheme.surface);

    return ThemeData(
      brightness: brightness,
      backgroundColor: themeBackgroundColor,
      colorScheme: ColorScheme(
        primary: colorScheme.onPrimary,
        primaryVariant: colorScheme.onPrimary,
        secondary:
            isThemeDark ? colorScheme.primaryVariant : colorScheme.secondary,
        secondaryVariant: colorScheme.onSecondary,
        surface: colorScheme.onSurface,
        background: themeBackgroundColor,
        error: colorScheme.onError,
        onPrimary: colorScheme.primary,
        onSecondary: colorScheme.secondary,
        onSurface: colorScheme.surface,
        onBackground: colorScheme.background,
        onError: colorScheme.error,
        brightness: brightness,
      ),
    );
  }
}
