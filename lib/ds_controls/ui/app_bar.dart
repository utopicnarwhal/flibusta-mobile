import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> actions;
  final bool showBottomDivider;
  final bool isTransparent;

  @override
  final Size preferredSize;

  DsAppBar({
    Key key,
    this.title,
    this.showBottomDivider = true,
    this.actions,
    this.isTransparent = false,
  })  : preferredSize = Size.fromHeight(kToolbarHeight + (showBottomDivider ? 0.5 : 0.0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (isTransparent) {
      backgroundColor = Colors.transparent;
    } else if (Theme.of(context).brightness == Brightness.light) {
      backgroundColor = Theme.of(context).cardColor;
    }

    return AppBar(
      title: title,
      centerTitle: false,
      actions: actions,
      bottom: showBottomDivider ? DsAppBarBottomDivider() : null,
      elevation: 0,
      iconTheme: Theme.of(context).iconTheme,
      actionsIconTheme: Theme.of(context).iconTheme,
      systemOverlayStyle:
          Theme.of(context).brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      backgroundColor: backgroundColor,
    );
  }
}

class DsAppBarBottomDivider extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.5,
      child: Divider(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(0.5);
}
