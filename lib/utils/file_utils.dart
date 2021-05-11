import 'dart:convert' show base64, utf8;
import 'dart:io';

import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:flibusta/utils/permissions_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:utopic_toast/utopic_toast.dart';
import 'package:flutter/material.dart';
import 'package:utopic_open_file/utopic_open_file.dart';
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
        ToastManager().showToast(
          'Не удалось сохранить файл, так как не хватает данных о файле',
          type: ToastType.error,
        );
        return false;
      }

      var storageAccess = await PermissionsUtils.requestAccess(
        scaffoldKey.currentContext,
        Permission.storage,
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
        ToastManager().showToast(
          'Нет данных о названии файла',
          type: ToastType.error,
        );
        return false;
      }
      var fileUri = '${dirToSave.path}/$fileName';

      var myFile = File(fileUri);
      if (myFile.existsSync()) {
        if (Platform.isAndroid && showSavingInfo) {
          ToastManager().showToast(
            'Файл с именем "$fileName" уже существует в папке "${dirToSave.path}"',
            action: ToastAction(
              label: 'Открыть',
              textColor: Theme.of(scaffoldKey.currentContext).cardColor,
              onPressed: (hideToast) {
                FileUtils.openFile(myFile.path);
                hideToast();
              },
            ),
          );
        } else if (Platform.isIOS) {
          FileUtils.openFile(myFile.path);
        }
        return false;
      }

      myFile.writeAsBytesSync(fileData);
      if (Platform.isAndroid && showSavingInfo) {
        await NativeMethods.rescanFolder(fileUri);
        ToastManager().showToast(
          'Файл "$fileName" успешно сохранен в папку "${dirToSave.path}" во внутренней памяти устройства',
          type: ToastType.success,
          action: ToastAction(
              label: 'Открыть',
              textColor: Colors.black87,
              onPressed: (hideToast) {
                FileUtils.openFile(myFile.path);
                hideToast();
              }),
        );
      } else if (Platform.isIOS) {
        FileUtils.openFile(myFile.path);
      }
      return true;
    } catch (e) {
      if (showSavingInfo) {
        ToastManager().showToast(
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
      debugPrint(e.toString());
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
      if (storageDir == null) {
        storageDir = await getExternalStorageDirectory();
      }
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
        ToastManager().showToast(openResult.message);
        break;
      case ResultType.fileNotFound:
        ToastManager().showToast('Файл не найден.');
        break;
      case ResultType.noAppToOpen:
        var userMessage =
            'Не найдено приложение для открытия этого типа файлов.';
        if (path.split('.').last == 'zip') {
          userMessage += ' Данный файл является архивом. Используйте приложение проводника.';
        }
        ToastManager().showToast(userMessage);
        break;
      case ResultType.permissionDenied:
        ToastManager().showToast('Нет доступа к файлу.');
        break;
      default:
    }
  }
}
