import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

const kFlibustaOnionUrl = "http://flibustahezeous3.onion";

const kBouncingAlwaysScrollableScrollPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

const kFromSplashsceenTransitionDuration = Duration(milliseconds: 1000);

const Widget kIconArrowForward = const Icon(
  EvaIcons.arrowIosForward,
  size: 20,
);

class HomeGridConsts {
  static const int kPageSize = 50; // default
  static const double kMaxCardWidth = 320.0;
  static const double kCardRowHeight = 35.0;
}
