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
              title: Text(
                title ?? '',
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    subtitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  if (genres?.isNotEmpty == true) ...[
                    _genresBuilder(context, genres)
                  ],
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

  Widget _genresBuilder(BuildContext context, List<String> genres) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            tileMode: TileMode.clamp,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withOpacity(0),
            ],
          ).createShader(
            Rect.fromLTWH(bounds.width - 20, 0, 20, bounds.height),
          );
        },
        blendMode: BlendMode.dstATop,
        child: ListView.separated(
          padding: EdgeInsets.only(top: 6),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: genres?.length ?? 0,
          separatorBuilder: (context, index) {
            return SizedBox(width: 10);
          },
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Text(
                genres.elementAt(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
