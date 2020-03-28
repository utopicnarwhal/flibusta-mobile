import 'package:flibusta/blocs/grid/grid_data/components/first_grid_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const kShimmerBaseColor = Color(0x1FBBBBBB);
const kShimmerHighlightColor = Color(0x3FBBBBBB);
const kShimmerTextBaseColor = Color(0xFFCCCCCC);
const kShimmerTextHighlightColor = Color(0x3FBBBBBB);

class ShimmerContainer extends StatelessWidget {
  final double blockWidth;
  final double blockHeight;
  final double borderRadius;

  ShimmerContainer({
    this.blockWidth,
    this.blockHeight,
    this.borderRadius = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kShimmerBaseColor,
      highlightColor: kShimmerHighlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
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

class ShimmerGridTileBuilder extends StatelessWidget {
  final int itemCount;
  final GridViewType gridViewType;

  const ShimmerGridTileBuilder({
    Key key,
    this.itemCount,
    this.gridViewType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (gridViewType == GridViewType.suquence) {
      return ListView.builder(
        physics: kBouncingAlwaysScrollableScrollPhysics,
        addSemanticIndexes: false,
        itemCount: itemCount,
        padding: EdgeInsets.only(top: 20),
        itemBuilder: (context, index) {
          return Material(
            type: MaterialType.card,
            borderRadius: BorderRadius.zero,
            child: Column(
              children: <Widget>[
                if (index == 0) Divider(),
                ShimmerListTile(
                  index: index,
                  gridViewType: gridViewType,
                ),
                if (index != (itemCount - 1) || index == 0) Divider(indent: 16),
                if (index == (itemCount - 1)) Divider(),
              ],
            ),
          );
        },
      );
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      addSemanticIndexes: false,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            FirstGridTile(
              isFirst: index == 0,
              child: ShimmerListTile(
                index: index,
                gridViewType: gridViewType,
              ),
            ),
            if (index != (itemCount - 1) || index == 0) Divider(indent: 16),
          ],
        );
      },
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final Widget title;
  final GridViewType gridViewType;
  final int index;

  const ShimmerListTile({
    Key key,
    this.title,
    this.gridViewType,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isThreeLines = gridViewType == GridViewType.newBooks ||
        gridViewType == GridViewType.downloaded;

    return Shimmer.fromColors(
      baseColor: kShimmerBaseColor,
      highlightColor: kShimmerHighlightColor,
      child: ListTile(
        title: Text(
          'Название произведения',
          maxLines: 1,
          overflow: TextOverflow.fade,
          textWidthBasis: TextWidthBasis.longestLine,
          style: TextStyle(backgroundColor: Colors.white),
        ),
        isThreeLine: isThreeLines,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Авторы произведения',
              maxLines: 1,
              overflow: TextOverflow.fade,
              textWidthBasis: TextWidthBasis.longestLine,
              style: TextStyle(backgroundColor: Colors.white),
            ),
            if (isThreeLines) ...[
              SizedBox(height: 6),
              SizedBox(
                height: 22,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Жанры произведения',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    textWidthBasis: TextWidthBasis.longestLine,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            kIconArrowForward,
          ],
        ),
      ),
    );
  }
}
