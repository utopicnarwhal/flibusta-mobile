import 'package:flibusta/blocs/grid/grid_data/components/first_grid_tile.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/utils/icon_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GridDataTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> genres;
  final int score;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  final bool isFirst;
  final bool isLast;
  final int index;
  final Widget trailingIcon;
  final bool showTopDivider;
  final bool showBottomDivier;
  final bool isSlidable;
  final SlidableController slidableController;
  final Function onDismissed;

  GridDataTile({
    @required this.title,
    this.subtitle,
    this.genres,
    this.onTap,
    this.onLongPress,
    this.isFirst = false,
    this.isLast = false,
    this.index = 0,
    this.score,
    this.trailingIcon,
    this.showTopDivider = false,
    this.showBottomDivier = false,
    this.isSlidable = false,
    this.slidableController,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return FirstGridTile(
      isFirst: isFirst,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showTopDivider) Divider(),
          Slidable(
            key: ValueKey(title),
            controller: slidableController,
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            enabled: isSlidable,
            dismissal: SlidableDismissal(
              child: SlidableDrawerDismissal(),
              onDismissed: (actionType) async {
                if (actionType == SlideActionType.primary) {
                  return;
                }
                onDismissed();
              },
            ),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Убрать',
                color: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).accentColor,
                icon: Icons.delete,
                onTap: onDismissed,
              ),
            ],
            child: ListTile(
              onLongPress: onLongPress,
              onTap: onTap,
              title: Text(
                title ?? '',
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle ?? '',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  if (genres?.isNotEmpty == true || score != null) ...[
                    _genresAndScoreBuilder(context, genres, score)
                  ],
                ],
              ),
              isThreeLine: genres?.isNotEmpty == true && subtitle != null,
              trailing: trailingIcon != null || onTap != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (trailingIcon != null) trailingIcon,
                            if (onTap != null) kIconArrowForward,
                          ],
                        ),
                      ],
                    )
                  : SizedBox(),
            ),
          ),
          if (!isLast || isFirst) Divider(indent: 16),
          if (showBottomDivier) Divider(),
        ],
      ),
    );
  }

  Widget _genresAndScoreBuilder(
    BuildContext context,
    List<String> genres,
    int score,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
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
          itemCount: (genres?.length ?? 0) + 1,
          separatorBuilder: (context, index) {
            if (index == 0) {
              if (score == null) {
                return Container();
              }
            }
            return SizedBox(width: 10);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              if (score == null) {
                return Container();
              }
              return AspectRatio(
                aspectRatio: 1,
                child: scoreToIcon(score, 18),
              );
            }
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
                genres.elementAt(index - 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
