import 'package:flibusta/ds_controls/theme.dart';
import 'package:flutter/material.dart';

class DsOutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final FocusNode focusNode;
  final bool autofocus;
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry margin;

  DsOutlineButton({
    @required this.onPressed,
    this.padding,
    this.focusNode,
    this.autofocus = false,
    this.child,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: padding ?? EdgeInsets.all(8),
        primary: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.button.copyWith(
              color: kSecondaryColor(context),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
        child: child,
      ),
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
