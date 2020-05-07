import 'dart:ui';

import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/intro.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _filesToWarmup = [
  'assets/animations/empty_state.flr',
  'assets/animations/floating_document.flr',
  'assets/animations/questions.flr',
  'assets/animations/like.flr',
  'assets/animations/roskomnadzor.flr',
  'assets/animations/books_placeholder.flr',
  'assets/animations/long_tap.flr',
];

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Color _backgroundColor = Colors.white;

  void appInit() async {
    List<Future> futures = [];

    FlareCache.doesPrune = false;
    futures.add(warmupFlare());
    await Future.wait(futures);
    futures.clear();

    // futures.add(
    //   ApiHttpClient.isUserAlreadyAuthorized().then(
    //     (isUserAlreadyAuthorized) async {
    if (!mounted) return;

    // if (isUserAlreadyAuthorized == true) {

    if (!await LocalStorage().getIntroCompleted()) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: kFromSplashsceenTransitionDuration,
          pageBuilder: (context, __, ___) => IntroPage(),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 0),
        pageBuilder: (context, __, ___) => HomePage(),
      ),
    );
  }

  Future<void> warmupFlare() async {
    for (final filename in _filesToWarmup) {
      await cachedActor(
        AssetFlare(
          bundle: rootBundle,
          name: filename,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    appInit();
  }

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).brightness) {
      case Brightness.dark:
        if (_backgroundColor != Theme.of(context).scaffoldBackgroundColor) {
          Future.microtask(() {
            setState(() =>
                _backgroundColor = Theme.of(context).scaffoldBackgroundColor);
          });
        }
        break;
      case Brightness.light:
        if (_backgroundColor != Theme.of(context).cardColor) {
          Future.microtask(() {
            setState(() => _backgroundColor = Theme.of(context).cardColor);
          });
        }
        break;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      color: _backgroundColor,
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: FlibustaLogo(
            sideHeight: 200,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
