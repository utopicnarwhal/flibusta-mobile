import 'package:flutter/material.dart';

class FlibustaLogo extends StatelessWidget {
  final bool isIconLike;
  final double sideHeight;

  const FlibustaLogo({
    Key key,
    this.isIconLike = false,
    this.sideHeight = 100.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var img = Image.asset(
      'assets/img/Logo.png',
    );
    return Hero(
      tag: 'FlibustaLogo',
      child: SizedBox(
        width: sideHeight,
        height: sideHeight,
        child: isIconLike
            ? Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: img,
                ),
              )
            : img,
      ),
    );
  }
}
