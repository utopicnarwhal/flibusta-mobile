import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  var preparationFutures = List<Future>();
  preparationFutures.add(LocalStorage().checkVersion());
  preparationFutures.add(LocalStorage().getActualProxy());
  preparationFutures.add(LocalStorage().getFlibustaHostAddress());
  preparationFutures.add(LocalStorage().getBooksDirectory());
  preparationFutures.add(PermissionsUtils.requestStorageAccess());

  var preparationResults = await Future.wait(preparationFutures);

  ProxyHttpClient().setProxy(
    preparationResults.length > 1 ? preparationResults.elementAt(1) : '',
  );
  ProxyHttpClient().setFlibustaHostAddress(
    preparationResults.length > 2
        ? preparationResults.elementAt(2)
        : 'flibusta.is',
  );
  if (preparationResults.length > 3 &&
      preparationResults.elementAt(3) == null) {
    var externalStorageDownloadDirectories =
        await DownloadsPathProvider.downloadsDirectory;
    await LocalStorage().setBooksDirectory(externalStorageDownloadDirectories);
  }
  runApp(FlibustaApp());
}

class FlibustaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) {
        if (brightness == Brightness.dark) {
          return kFlibustaDarkTheme;
        }
        return kFlibustaLightTheme;
      },
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'Флибуста - книжное братство',
          theme: theme,
          home: HomePage(),
          supportedLocales: [
            Locale("ru"),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
