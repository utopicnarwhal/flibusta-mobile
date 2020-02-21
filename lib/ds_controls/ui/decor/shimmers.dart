import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const kShimmerBaseColor = Color(0x1FBBBBBB);
const kShimmerHighlightColor = Color(0x3FBBBBBB);
const kShimmerTextBaseColor = Color(0xFFCCCCCC);
const kShimmerTextHighlightColor = Color(0x3FBBBBBB);

class ShimmerContainer extends StatelessWidget {
  final double blockWidth;
  final double blockHeight;

  ShimmerContainer({
    this.blockWidth,
    this.blockHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kShimmerBaseColor,
      highlightColor: kShimmerHighlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        width: blockWidth,
        height: blockHeight,
      ),
    );
  }
}

class ShimmerViewTypes extends StatelessWidget {
  final blockWidth = 90.0;
  final blockHeight = 30.0;
  final blockCount = 5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < blockCount; ++i)
            Container(
              margin: EdgeInsets.fromLTRB(12, 14, 12, 4),
              child: ShimmerContainer(
                blockHeight: blockHeight,
                blockWidth: blockWidth,
              ),
            ),
        ],
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final Widget title;
  final Widget trailing;

  const ShimmerListTile({
    Key key,
    this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kShimmerBaseColor,
      highlightColor: kShimmerHighlightColor,
      child: ListTile(
        title: title ??
            Text(
              'Текст внутри ListTile',
              maxLines: 1,
              overflow: TextOverflow.fade,
              textWidthBasis: TextWidthBasis.longestLine,
              style: TextStyle(backgroundColor: Colors.white),
            ),
        trailing: trailing != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  trailing,
                ],
              )
            : null,
      ),
    );
  }
}
