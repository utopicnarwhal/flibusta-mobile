import 'package:flutter/material.dart';

import '../theme.dart';

class DsInputBorder extends InputBorder {
  const DsInputBorder({
    BorderSide borderSide = const BorderSide(),
    this.borderRadius =
        const BorderRadius.all(Radius.circular(kFieldBorderRadius)),
    this.outlineColor = Colors.black38,
  })  : assert(borderRadius != null),
        super(borderSide: borderSide);

  final BorderRadius borderRadius;
  final Color outlineColor;

  @override
  bool get isOutline => true;

  @override
  DsInputBorder copyWith(
      {BorderSide borderSide, BorderRadius borderRadius, Color outlineColor}) {
    return DsInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      outlineColor: outlineColor ?? this.outlineColor,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only(bottom: borderSide.width);
  }

  @override
  DsInputBorder scale(double t) {
    return DsInputBorder(borderSide: borderSide.scale(t));
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(borderSide.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  ShapeBorder lerpFrom(ShapeBorder a, double t) {
    if (a is DsInputBorder) {
      final DsInputBorder outline = a;
      return DsInputBorder(
        borderSide: BorderSide.lerp(outline.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(outline.borderRadius, borderRadius, t),
        outlineColor: Color.lerp(outline.outlineColor, outlineColor, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder lerpTo(ShapeBorder b, double t) {
    if (b is DsInputBorder) {
      final DsInputBorder outline = b;
      return DsInputBorder(
        borderSide: BorderSide.lerp(borderSide, outline.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, outline.borderRadius, t),
        outlineColor: Color.lerp(outlineColor, outline.outlineColor, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection textDirection,
  }) {
    canvas.clipRRect(borderRadius.toRRect(rect));

    final Paint paint = BorderSide(color: outlineColor).toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    final RRect center = outer;

    canvas.drawRRect(center, paint);

    canvas.drawLine(
      rect.bottomLeft.translate(0, 3 - borderSide.width),
      rect.bottomRight.translate(0, 3 - borderSide.width),
      borderSide.toPaint(),
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final InputBorder typedOther = other;
    return typedOther.borderSide == borderSide;
  }

  @override
  int get hashCode => borderSide.hashCode;
}
