import 'dart:ui';

import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _filesToWarmup = [
  'assets/animations/empty_state.flr',
];

class SplashScreen extends StatefulWidget {
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
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 0),
        pageBuilder: (context, __, ___) => HomePage(),
      ),
    );
    // } else {
    // Navigator.of(context).pushReplacement(
    //   PageRouteBuilder(
    //     transitionDuration: kSplashsceenToLoginTransitionDuration,
    //     pageBuilder: (context, __, ___) => LoginPage(leadId: _leadId),
    //   ),
    // );
    //       }
    //     },
    //   ),
    // );
    // await Future.wait(futures);
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
  void didChangeDependencies() {
    ScreenUtil.init(
      context,
      height: window?.physicalSize?.height ?? 1920,
      width: window?.physicalSize?.width ?? 1080,
    );
    super.didChangeDependencies();
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
            sideHeight: ScreenUtil().setWidth(400),
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
