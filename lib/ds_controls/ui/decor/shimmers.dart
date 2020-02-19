import 'package:flibusta/constants.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
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

class ShimmerLeadList extends StatelessWidget {
  final int listCount;
  final bool hasFirst;

  ShimmerLeadList({
    this.listCount = 3,
    this.hasFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (int i = 0; i < listCount; ++i) {
      children.add(
        _buildGridListTile(i == 0 && hasFirst, i == listCount - 1),
      );
    }

    return Column(
      children: children,
    );
  }

  Widget _buildGridListTile(bool isFirst, bool isLast) {
    Widget shimmerListTile = Shimmer.fromColors(
      baseColor: kShimmerBaseColor,
      highlightColor: kShimmerHighlightColor,
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipOval(
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Icon(
                  EvaIcons.flash,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
        title: Text(
          'Иванов Иван Иванович',
          maxLines: 1,
          overflow: TextOverflow.fade,
          textWidthBasis: TextWidthBasis.longestLine,
          style: TextStyle(backgroundColor: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Text(
                '+7 987 888 55 44 / Москва / 8 млн. / 7 лет',
                maxLines: 1,
              ),
            ),
            SizedBox(height: 5),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              child: Text(
                'Не передано в банк',
                style: TextStyle(fontSize: 11),
                maxLines: 1,
              ),
            ),
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
    if (!isLast) {
      shimmerListTile = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          shimmerListTile,
          Divider(indent: 80),
        ],
      );
    }
    // shimmerListTile = FirstGridLeadTile(
    //   isFirst: isFirst,
    //   child: shimmerListTile,
    // );
    return shimmerListTile;
  }
}

class ShimmerBookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: kBouncingAlwaysScrollableScrollPhysics,
      shrinkWrap: false,
      addSemanticIndexes: false,
      children: <Widget>[
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Shimmer.fromColors(
                baseColor: kShimmerTextBaseColor,
                highlightColor: kShimmerTextHighlightColor,
                child: Text(
                  'Заемщик',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
            ),
          ],
        ),
        Divider(),
        Material(
          type: MaterialType.card,
          borderRadius: BorderRadius.zero,
          child: Shimmer.fromColors(
            baseColor: kShimmerTextBaseColor,
            highlightColor: kShimmerTextHighlightColor,
            child: ListTile(
              leading: Icon(EvaIcons.person),
              title: Text(
                'Анкета',
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  kIconArrowForward,
                ],
              ),
            ),
          ),
        ),
        Divider(),
        SizedBox(height: 40),
        Divider(),
        Material(
          type: MaterialType.card,
          borderRadius: BorderRadius.zero,
          child: Shimmer.fromColors(
            baseColor: kShimmerTextBaseColor,
            highlightColor: kShimmerTextHighlightColor,
            child: ListTile(
              title: Text(
                'Документы',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
              leading: Icon(EvaIcons.attach),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  kIconArrowForward,
                ],
              ),
            ),
          ),
        ),
        Divider(),
      ],
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
