import 'dart:async';
import 'dart:ui';

import 'package:flibusta/blocs/tor_proxy/tor_proxy_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/pages/intro.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopic_toast/utopic_toast.dart';

const _filesToWarmup = [
  'assets/animations/empty_state.flr',
  'assets/animations/books_placeholder.flr',
  'assets/animations/long_tap.flr',
];

enum LoadingState {
  warmUpAnimations,
  startingTor,
}

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _backgroundColor = Colors.white;
  var _loadingStateController = StreamController<LoadingState>();
  StreamSubscription<TorProxyState> _torProxyBlocSubscription;
  Completer<void> _torStartupCompleter;

  void appInit() async {
    List<Future> futures = [];

    _loadingStateController.add(LoadingState.warmUpAnimations);
    FlareCache.doesPrune = false;
    futures.add(warmupFlare());
    await Future.wait(futures);
    futures.clear();

    if (!mounted) return;

    if (!await LocalStorage().getIntroCompleted()) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: kFromSplashsceenTransitionDuration,
          pageBuilder: (context, __, ___) => IntroPage(),
        ),
      );
      return;
    }

    if (await LocalStorage().getStartUpTor()) {
      _loadingStateController.add(LoadingState.startingTor);
      _torStartupCompleter = Completer<void>();

      _torProxyBlocSubscription = TorProxyBloc().stream.listen((torProxyState) {
        if (torProxyState is InTorProxyState) {
          _torStartupCompleter.complete();
        }
        if (torProxyState is ErrorTorProxyState) {
          ToastManager().showToast(
            'Не удалось запустить Tor Onion Proxy. Попробуйте запустить его вручную.',
          );
          _torStartupCompleter.complete();
        }
      });
      TorProxyBloc().startTorProxy();
      await _torStartupCompleter.future;
      _torProxyBlocSubscription?.cancel();
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
          child: SizedOverflowBox(
            size: Size.square(200),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                FlibustaLogo(
                  sideHeight: 200,
                ),
                StreamBuilder<LoadingState>(
                  stream: _loadingStateController.stream,
                  builder: (context, loadingStateSnapshot) {
                    if (!loadingStateSnapshot.hasData) {
                      return SizedBox();
                    }
                    switch (loadingStateSnapshot.data) {
                      case LoadingState.warmUpAnimations:
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Подготовка...'),
                            SizedBox(height: 16),
                            DsCircularProgressIndicator(),
                          ],
                        );
                      case LoadingState.startingTor:
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Запуск Tor Onion Proxy'),
                            SizedBox(height: 16),
                            DsCircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kTorColor),
                            ),
                          ],
                        );
                      default:
                        return SizedBox();
                    }
                  },
                ),
              ],
            ),
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
    _torProxyBlocSubscription?.cancel();
    _loadingStateController?.close();
    super.dispose();
  }
}
