import 'package:flibusta/blocs/grid/grid_data/components/first_grid_tile.dart';
import 'package:flutter/material.dart';

class GridDataTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> genres;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool isFirst;
  final bool isLast;
  final int index;

  GridDataTile({
    @required this.title,
    @required this.subtitle,
    this.genres,
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
              title: Text(title ?? ''),
              subtitle: Column(
                children: <Widget>[
                  Text(
                    subtitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  if (genres?.isNotEmpty == true) _genresBuilder(genres),
                ],
              ),
              isThreeLine: genres?.isNotEmpty == true,
            ),
          ),
          if (!isLast || isFirst) Divider(indent: 16),
        ],
      ),
    );
  }

  Widget _genresBuilder(List<String> genres) {
    return Row(
      children: genres?.map((genre) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 6,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.green,
          ),
          child: Text(
            genre,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      })?.toList(),
    );
  }
}
