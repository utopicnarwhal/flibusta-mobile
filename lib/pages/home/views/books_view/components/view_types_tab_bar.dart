import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/tab_bar.dart';
import 'package:flibusta/model/enums/gridViewType.dart';
import 'package:flutter/material.dart';

class ViewTypesTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DsTabBar(
      indicatorWeight: 1.5,
      physics: kBouncingAlwaysScrollableScrollPhysics,
      labelColor: Theme.of(context).textTheme.headline6.color,
      unselectedLabelColor:
          Theme.of(context).textTheme.headline6.color.withOpacity(0.47),
      indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      tabs: [
        for (var gridViewType in booksViewGridTypes)
          Tab(text: gridViewTypeToString(gridViewType)),
      ],
    );
  }
}
