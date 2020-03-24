import 'package:flutter/material.dart';

import '../../theme.dart';

class DsOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final FocusNode focusNode;
  final bool autofocus;
  final Widget child;
  final EdgeInsetsGeometry margin;

  DsOutlineButton({
    @required this.onPressed,
    this.padding,
    this.focusNode,
    this.autofocus = false,
    this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlineButton(
      onPressed: onPressed,
      padding: padding ?? EdgeInsets.all(8),
      focusNode: focusNode,
      autofocus: autofocus,
      splashColor: kSecondaryColor(context).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.button.copyWith(
              color: kSecondaryColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
        child: child,
      ),
      highlightedBorderColor: kSecondaryColor(context),
    );

    if (margin != null) {
      return Padding(
        padding: margin,
        child: button,
      );
    }
    return button;
  }
}