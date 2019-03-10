import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

class BookService {
  static Dio _dio = ProxyHttpClient().getDio();

  static downloadBook(int id, Map<String, String> downloadFormat, void Function(double) downloadProgressCallback, 
                      void Function(String, Duration, {SnackBarAction action}) alertsCallback) async {
    if (!await SimplePermissions.checkPermission(Permission.WriteExternalStorage)) {
      await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    }
    
    Directory saveDocDir = await getExternalStorageDirectory();
    saveDocDir = Directory(saveDocDir.path + "/Flibusta");
    if (!saveDocDir.existsSync()) {
      saveDocDir.createSync(recursive: true);
      await NativeMethods.rescanFolder(saveDocDir.path + "/Flibusta");
    }

    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/b/$id/${downloadFormat.values.first}");
    String fileUri = "";
    CancelToken cancelToken = CancelToken();
    cancelToken.whenCancel.whenComplete(() {
      alertsCallback(cancelToken.cancelError.message, Duration(seconds: 5));
    });

    downloadProgressCallback(0.0);
    alertsCallback("Подготовка к загрузке", Duration(minutes: 1), 
      action: SnackBarAction(
        label: "Отменить", 
        onPressed: () {
          cancelToken.cancel("Загрузка отменена");
        },
      ),
    );

    try {
      var response = await _dio.downloadUri(
        url,
        (HttpHeaders responseHeaders) {
          alertsCallback("", Duration(seconds: 0));

          var contentDisposition = responseHeaders["content-disposition"];
          if (contentDisposition == null) {
            downloadProgressCallback(null);
            cancelToken.cancel("Доступ к книге ограничен по требованию правоторговца");
            return fileUri;
          }

          try {
            fileUri = saveDocDir.path + "/" + contentDisposition[0].split("filename=")[1].replaceAll("\"", "");
          } catch (e) {
            downloadProgressCallback(null);
            cancelToken.cancel("Не удалось получить имя файла");
            return fileUri;
          }

          var myFile = File(fileUri);
          if (myFile.existsSync()) {
            downloadProgressCallback(null);
            cancelToken.cancel("Файл с таким именем уже есть");
            return fileUri;
          }

          return fileUri;
        },
        cancelToken: cancelToken,
        options: Options(
          connectTimeout: 10000,
          receiveTimeout: 60000,
          receiveDataWhenStatusError: false,
        ),
        onReceiveProgress: (int count, int total) {
          if (cancelToken.isCancelled) {
            downloadProgressCallback(null);
          } else {
            downloadProgressCallback(count / total);
          }
        },
      );

      if (response == null || response.statusCode != 200) {
        downloadProgressCallback(null);
        alertsCallback("Не удалось загрузить", Duration(seconds: 5));
        return;
      }
      
      await NativeMethods.rescanFolder(fileUri);
    } on DioError catch(e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
          print(e.request.path);
          alertsCallback("Время ожидания соединения истекло", Duration(seconds: 5));
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          print(e);
          alertsCallback("Время ожидания загрузки истекло", Duration(seconds: 5));
          break;
        default:
          print(e);
      }
    } catch (e) {
      print(e);
      cancelToken.cancel("");
    }

    downloadProgressCallback(null);
    if (!cancelToken.isCancelled) {
      alertsCallback("Файл скачан", Duration(seconds: 5));
    }
  }

  static Future<BookInfo> getBookInfo(int bookId) async {
    var bookInfo = BookInfo(id: bookId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/b/" + bookId.toString());
      var response = await _dio.getUri(url);
      htmldom.Document document = parse(response.data);

      bookInfo = parseHtmlFromBookInfo(document, bookId);
    } catch(e) {
      print(e);
    }

    return bookInfo;
  }
}