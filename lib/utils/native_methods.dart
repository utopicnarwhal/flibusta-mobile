import 'package:flutter/services.dart';

class NativeMethods {
  static const _platform = const MethodChannel('ru.utopicnarwhal.flibusta/native_methods_channel');

  static Future<void> rescanFolder(String dir) async {
    try {
      await _platform.invokeMethod('rescan_folder', dir);
      print("Сканирование успешно завершено");
    } on PlatformException catch (e) {
      print("Сканирование не удалось. Ошибка: " + e.toString());
    }
  }
}
