import 'dart:io';

import 'package:flutter/services.dart';

class NativeMethods {
  static const _platform = const MethodChannel('ru.utopicnarwhal.flibustabrowser/native_methods_channel');

  static Future<void> rescanFolder(String dir) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      await _platform.invokeMethod('rescan_folder', dir);
    } on PlatformException catch (e) {
      print('Сканирование не удалось. Ошибка: ' + e.toString());
    }
  }
}
