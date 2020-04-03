import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';

class FirstGridTile extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isSelected;

  const FirstGridTile({
    Key key,
    this.isFirst = false,
    @required this.child,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var result = Material(
      type: MaterialType.canvas,
      child: ListTileTheme(
        selectedColor:
            Theme.of(context).textTheme.subhead.color.withOpacity(0.5),
        child: child,
      ),
      color: isSelected
          ? Theme.of(context).accentColor.withOpacity(0.09)
          : Colors.transparent,
    );

    if (!isFirst) {
      return result;
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              elevation: Theme.of(context).cardTheme.elevation,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: result,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
