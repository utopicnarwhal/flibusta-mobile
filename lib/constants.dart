import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

const kBouncingAlwaysScrollableScrollPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

const kSplashsceenToLoginTransitionDuration = Duration(milliseconds: 500);

const Widget kIconArrowForward = const Icon(
  EvaIcons.arrowIosForward,
  size: 20,
);

const double kCardBorderRadius = 7;

class HomeGridConsts {
  static const int kPageSize = 10;
  static const double kMaxCardWidth = 320.0;
  static const double kCardRowHeight = 35.0;
}