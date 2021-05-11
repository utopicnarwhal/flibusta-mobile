import 'package:flibusta/ds_controls/theme.dart';
import 'package:flutter/material.dart';

class DsElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final FocusNode focusNode;
  final bool autofocus;
  final Widget child;
  final double elevation;
  final double borderRadius;
  final bool isPrimaryColor;

  DsElevatedButton({
    @required this.onPressed,
    this.padding,
    this.focusNode,
    this.autofocus = false,
    this.child,
    this.elevation = 8,
    this.borderRadius = 10,
    this.isPrimaryColor = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? EdgeInsets.all(8),
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        primary: isPrimaryColor ? null : kSecondaryColor(context),
      ),
      focusNode: focusNode,
      autofocus: autofocus,
      child: DefaultTextStyle(
        style: Theme.of(context).primaryTextTheme.button.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
        child: child,
      ),
    );
  }
}
