import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashedRect extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;
  final Widget child;

  DashedRect({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 0.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(strokeWidth / 2),
      child: CustomPaint(
        painter: DashRectPainter(
          color: color,
          strokeWidth: strokeWidth,
          gap: gap,
          radius: radius,
        ),
        child: child,
      ),
    );
  }
}

class DashRectPainter extends CustomPainter {
  double strokeWidth;
  Color color;
  double gap;
  double radius;

  DashRectPainter({
    this.strokeWidth = 5.0,
    this.color = Colors.red,
    this.gap = 5.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path _topPath = getDashedPath(
      a: math.Point(radius, 0),
      b: math.Point(x - radius, 0),
      gap: gap,
      radius: radius,
    );

    Path _rightPath = getDashedPath(
      a: math.Point(x, radius),
      b: math.Point(x, y - radius),
      gap: gap,
      radius: radius,
    );

    Path _bottomPath = getDashedPath(
      a: math.Point(x - radius, y),
      b: math.Point(radius, y),
      gap: gap,
      radius: radius,
    );

    Path _leftPath = getDashedPath(
      a: math.Point(0, y - radius),
      b: math.Point(0, radius),
      gap: gap,
      radius: radius,
    );

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);
  }

  Path getDashedPath({
    @required math.Point<double> a,
    @required math.Point<double> b,
    @required gap,
    @required radius,
  }) {
    Size size = Size((b.x - a.x).abs(), (b.y - a.y).abs());
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    math.Point currentPoint = math.Point(a.x, a.y);

    num radians = math.atan(size.height / size.width);

    num dx = math.cos(radians) * gap < 0
        ? math.cos(radians) * gap * -1
        : math.cos(radians) * gap;

    num dy = math.sin(radians) * gap < 0
        ? math.sin(radians) * gap * -1
        : math.sin(radians) * gap;

    while ((a.x < b.x && currentPoint.x < b.x) ||
        (a.x > b.x && currentPoint.x > b.x) ||
        (a.y < b.y && currentPoint.y < b.y) ||
        (a.y > b.y && currentPoint.y > b.y)) {
      shouldDraw
          ? path.lineTo(currentPoint.x, currentPoint.y)
          : path.moveTo(currentPoint.x, currentPoint.y);
      shouldDraw = !shouldDraw;
      currentPoint = math.Point(
        a.x < b.x ? currentPoint.x + dx : currentPoint.x - dx,
        a.y < b.y ? currentPoint.y + dy : currentPoint.y - dy,
      );
    }

    var center = Offset(0, 0);
    double startAngle = 0;
    double addedAngle = (gap * math.pi) / 19;
    double currentAngle = 0;

    if (a.x < b.x) {
      center = Offset(b.x, b.y + radius);
      startAngle = -math.pi / 2;
    }
    if (a.x > b.x) {
      center = Offset(b.x, b.y - radius);
      startAngle = math.pi / 2;
    }
    if (a.y < b.y) {
      center = Offset(b.x - radius, b.y);
      startAngle = 0;
    }
    if (a.y > b.y) {
      center = Offset(b.x + radius, b.y);
      startAngle = math.pi;
    }
    while (currentAngle < math.pi / 2) {
      shouldDraw
          ? path.arcTo(Rect.fromCircle(center: center, radius: radius),
              startAngle + currentAngle, addedAngle, true)
          : path.arcTo(Rect.fromCircle(center: center, radius: radius),
              startAngle + currentAngle, 0, true);
      shouldDraw = !shouldDraw;
      currentAngle += addedAngle;
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
