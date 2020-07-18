import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  SvgIcon({
    @required this.assetPath,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = Theme.of(context).iconTheme;

    final double iconOpacity =
        iconTheme.opacity ?? IconTheme.of(context).color.opacity;
    Color iconColor = iconTheme.color;
    if (iconOpacity != null && iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconOpacity);

    return SvgPicture.asset(
      this.assetPath,
      color: iconColor,
      height: this.size,
      width: this.size,
    );
  }
}
