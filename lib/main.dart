import 'dart:io';

import 'package:flibusta/ds_controls/dynamic_theme_mode.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/permissions_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utopic_toast/utopic_toast.dart';

import 'utils/file_utils.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.black,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  var preparationFutures = List<Future>();
  preparationFutures.add(LocalStorage().checkVersion());
  preparationFutures.add(LocalStorage()
      .getActualProxy()
      .then((actualProxy) => ProxyHttpClient().setProxy(actualProxy)));
  preparationFutures.add(LocalStorage()
      .getHostAddress()
      .then((url) => ProxyHttpClient().setHostAddress(url)));
  preparationFutures.add(LocalStorage().getBooksDirectory().then((dir) async {
    var externalStorageDownloadDirectories = await FileUtils.getStorageDir();
    await LocalStorage().setBooksDirectory(externalStorageDownloadDirectories);
  }));
  preparationFutures.add(PermissionsUtils.requestAccess(
    null,
    PermissionGroup.storage,
  ));

  await Future.wait(preparationFutures);

  runApp(FlibustaApp());
}

class FlibustaApp extends StatelessWidget {
  static ThemeData currentTheme = ThemeData.light();
  static double statusBarHeight = 0;

  @override
  Widget build(BuildContext context) {
    return DynamicThemeMode(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Флибуста - книжное братство',
          supportedLocales: [
            Locale('ru', 'RU'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            statusBarHeight = MediaQuery.of(context).padding.top;
            currentTheme = Theme.of(context);

            if (Theme.of(context).brightness == Brightness.dark) {
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarDividerColor: Colors.white,
                  systemNavigationBarColor:
                      Theme.of(context).scaffoldBackgroundColor,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
              );
            } else {
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarDividerColor: Colors.black,
                  systemNavigationBarColor: Theme.of(context).cardColor,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
              );
            }
            return ToastOverlay(child: child);
          },
          themeMode: themeMode,
          theme: kFlibustaLightTheme,
          darkTheme: kFlibustaDarkTheme,
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
