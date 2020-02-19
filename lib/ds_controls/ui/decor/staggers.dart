import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ListFadeInSlideStagger extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;

  const ListFadeInSlideStagger({
    Key key,
    @required this.child,
    @required this.index,
    this.duration = const Duration(milliseconds: 375),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(child: child),
      ),
    );
  }
}

class ListSlideInStagger extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;

  const ListSlideInStagger({
    Key key,
    @required this.child,
    @required this.index,
    this.duration = const Duration(milliseconds: 375),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      child: SlideAnimation(
        verticalOffset: MediaQuery.of(context).size.height / 1.5,
        child: child,
      ),
    );
  }
}
