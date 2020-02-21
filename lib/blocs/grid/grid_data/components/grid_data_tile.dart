import 'package:flibusta/blocs/grid/grid_data/components/first_grid_tile.dart';
import 'package:flutter/material.dart';

class GridDataTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool isFirst;
  final bool isLast;
  final int index;

  GridDataTile({
    @required this.title,
    @required this.subtitle,
    this.onTap,
    this.onLongPress,
    this.isFirst = false,
    this.isLast = false,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FirstGridTile(
      isFirst: isFirst,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onLongPress: onLongPress,
            onTap: onTap,
            splashColor: Theme.of(context).accentColor.withOpacity(0.4),
            child: ListTile(
              isThreeLine: true,
              title: Text(title ?? ''),
              subtitle: Text(subtitle ?? ''),
            ),
          ),
          if (!isLast || isFirst) Divider(indent: 80),
        ],
      ),
    );
  }
}
