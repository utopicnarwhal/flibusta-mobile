import 'dart:convert' show base64, utf8;
import 'dart:io';

// import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:flibusta/utils/permissions_utils.dart';
import 'package:flibusta/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

enum DirectoryType {
  temp,
  storage,
}

class FileUtils {
  static Future<bool> saveFileToStorage(
    List<int> fileData,
    String fileName,
    GlobalKey<ScaffoldState> scaffoldKey, {
    DirectoryType directoryType = DirectoryType.storage,
    bool showSavingInfo = true,
  }) async {
    try {
      if (fileData == null || fileName == null && showSavingInfo) {
        ToastUtils.showToast(
          'Не удалось сохранить файл, так как не хватает данных о файле',
          type: ToastType.error,
        );
        return false;
      }

      var storageAccess = await PermissionsUtils.storageAccess(
        context: scaffoldKey.currentContext,
      );

      if (storageAccess != true) {
        return false;
      }

      Directory dirToSave;
      switch (directoryType) {
        case DirectoryType.storage:
          dirToSave = await getStorageDir();
          break;
        case DirectoryType.temp:
          dirToSave = await getTempDir();
          break;
        default:
          throw new Exception('Не указано место для сохранения файла');
      }

      if ((fileName == null || fileName.trim().isEmpty) && showSavingInfo) {
        ToastUtils.showToast(
          'Нет данных о названии файла',
          type: ToastType.error,
        );
        return false;
      }
      var fileUri = '${dirToSave.path}/$fileName';

      var myFile = File(fileUri);
      if (myFile.existsSync()) {
        if (Platform.isAndroid && showSavingInfo) {
          ToastUtils.showToast(
            'Файл с именем "$fileName" уже существует в папке "${dirToSave.path}"',
            action: SnackBarAction(
              label: 'Открыть',
              textColor: Theme.of(scaffoldKey.currentContext).cardColor,
              onPressed: () => openFile(myFile.path),
            ),
          );
        } else if (Platform.isIOS) {
          openFile(myFile.path);
        }
        return false;
      }

      myFile.writeAsBytesSync(fileData);
      if (Platform.isAndroid && showSavingInfo) {
        await NativeMethods.rescanFolder(fileUri);
        ToastUtils.showToast(
          'Файл "$fileName" успешно сохранен в папку "${dirToSave.path}" во внутренней памяти устройства',
          type: ToastType.success,
          action: SnackBarAction(
            label: 'Открыть',
            textColor: Colors.black87,
            onPressed: () => openFile(myFile.path),
          ),
        );
      } else if (Platform.isIOS) {
        openFile(myFile.path);
      }
      return true;
    } catch (e) {
      if (showSavingInfo) {
        ToastUtils.showToast(
          'При сохранении файла произошла ошибка: ${e.toString()}',
          type: ToastType.error,
        );
      }
      return false;
    }
  }

  static String filenameFromContentDisposition(
    String contentDisposition, {
    bool isFilenameEncoded = false,
  }) {
    try {
      var filename =
          contentDisposition.split('filename=')[1].replaceAll('\"', '');

      if (isFilenameEncoded) {
        filename = filename.replaceAll('=?utf-8?B?', '').replaceAll('?=', '');
        filename = utf8.decode(base64.decode(filename));
      }
      return filename;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<bool> isFileInTempExists(String fileName) async {
    var tempDirPath = (await getTempDir())?.path;
    var myFile = File('$tempDirPath/$fileName');
    if (myFile.existsSync()) {
      return true;
    }

    return false;
  }

  static Future<Directory> getTempDir() async {
    Directory tempDir;
    if (Platform.isAndroid) {
      tempDir = await getExternalStorageDirectory();
    } else {
      tempDir = await getTemporaryDirectory();
    }
    return tempDir;
  }

  static Future<Directory> getStorageDir() async {
    Directory storageDir;

    if (Platform.isAndroid) {
      storageDir = await LocalStorage().getBooksDirectory();
      storageDir = Directory(storageDir.path);
      if (!storageDir.existsSync()) {
        storageDir.createSync(recursive: true);
        await NativeMethods.rescanFolder(storageDir.path);
      }
    } else if (Platform.isIOS) {
      storageDir = await getTemporaryDirectory();
    }
    return storageDir;
  }

  static void openFile(String path) async {
    var openResult = await OpenFile.open(path);
    if (openResult == null) {
      return;
    }
    switch (openResult.type) {
      case ResultType.error:
        ToastUtils.showToast(openResult.message);
        break;
      case ResultType.fileNotFound:
        ToastUtils.showToast('Файл не найден.');
        break;
      case ResultType.noAppToOpen:
        ToastUtils.showToast(
            'Не найдено приложение для открытия этого типа файлов.');
        break;
      case ResultType.permissionDenied:
        ToastUtils.showToast('Нет доступа к файлу.');
        break;
      default:
    }
  }
}
