import 'package:flutter/material.dart';

class DefaultDsTabController extends StatelessWidget {
  const DefaultDsTabController({
    Key key,
    @required this.length,
    this.initialIndex = 0,
    @required this.child,
    this.onChangeHandler,
  })  : assert(initialIndex != null),
        assert(length >= 0),
        assert(initialIndex >= 0 && initialIndex < length),
        super(key: key);

  final int length;
  final int initialIndex;
  final Widget child;
  final void Function(int newValue) onChangeHandler;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: length,
      initialIndex: initialIndex,
      child: Builder(
        builder: (context) {
          DefaultTabController?.of(context)?.addListener(() {
            onChangeHandler(DefaultTabController?.of(context)?.index);
          });
          return child;
        },
      ),
    );
  }
}
