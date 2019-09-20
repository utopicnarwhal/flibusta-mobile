import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:flibusta/utils/snack_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';
import 'package:rxdart/rxdart.dart';

class BookBloc {
  BookBloc(this._bookId);

  int _bookId;

  var _bookInfoController = BehaviorSubject<BookInfo>.seeded(null);
  Stream<BookInfo> get outBookInfo => _bookInfoController.stream;
  Sink<BookInfo> get _inBookInfo => _bookInfoController.sink;

  Dio _dio = ProxyHttpClient().getDio();

  Future<Null> getBookInfo() async {
    var bookInfo = BookInfo(id: _bookId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(),
          "/b/" + _bookId.toString());
      var response = await _dio.getUri(url);

      bookInfo = parseHtmlFromBookInfo(response.data, _bookId);
    } catch (e) {
      print(e);
    }

    _inBookInfo.add(bookInfo);
  }

  Future<Null> downloadBook(
    Map<String, String> downloadFormat,
    GlobalKey<ScaffoldState> _scaffoldKey,
    void Function(double) downloadProgressCallback,
  ) async {
    if ((await Permission.getPermissionsStatus([PermissionName.Storage])).every(
        (permission) =>
            permission.permissionStatus != PermissionStatus.allow)) {
      var permissionNames =
          await Permission.requestPermissions([PermissionName.Storage]);

      if (permissionNames.every((permission) =>
          permission.permissionStatus != PermissionStatus.allow)) {
        SnackBarUtils.showSnackBar(
          _scaffoldKey,
          'Не удалось сохранить файл, так как доступ к памяти не предоставлен',
          type: SnackBarType.error,
        );
        return;
      }
    }

    Directory saveDocDir = await getExternalStorageDirectory();
    saveDocDir = Directory(saveDocDir.path + "/Flibusta");
    if (!saveDocDir.existsSync()) {
      saveDocDir.createSync(recursive: true);
      await NativeMethods.rescanFolder(saveDocDir.path + "/Flibusta");
    }

    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(),
        "/b/$_bookId/${downloadFormat.values.first}");
    String fileUri = "";
    CancelToken cancelToken = CancelToken();
    cancelToken.whenCancel.whenComplete(() {
      alertsCallback(
          _scaffoldKey, cancelToken.cancelError.message, Duration(seconds: 5));
    });

    downloadProgressCallback(0.0);
    alertsCallback(
      _scaffoldKey,
      "Подготовка к загрузке",
      Duration(minutes: 1),
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
        (Headers responseHeaders) {
          alertsCallback(_scaffoldKey, "", Duration(seconds: 0));

          var contentDisposition = responseHeaders["content-disposition"];
          if (contentDisposition == null) {
            downloadProgressCallback(null);
            cancelToken
                .cancel("Доступ к книге ограничен по требованию правоторговца");
            return fileUri;
          }

          try {
            fileUri = saveDocDir.path +
                "/" +
                contentDisposition[0]
                    .split("filename=")[1]
                    .replaceAll("\"", "");
          } catch (e) {
            downloadProgressCallback(null);
            cancelToken.cancel("Не удалось получить имя файла");
            return fileUri;
          }

          var myFile = File(fileUri);
          if (myFile.existsSync()) {
            downloadProgressCallback(null);
            cancelToken.cancel("Файл с таким именем уже есть в папке Flibusta");
            return fileUri;
          }

          return fileUri;
        },
        cancelToken: cancelToken,
        options: Options(
          sendTimeout: 10000,
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
        alertsCallback(
            _scaffoldKey, "Не удалось загрузить", Duration(seconds: 5));
        return;
      }

      await NativeMethods.rescanFolder(fileUri);
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
          print(e.request.path);
          alertsCallback(
            _scaffoldKey,
            "Время ожидания соединения истекло",
            Duration(seconds: 5),
          );
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          print(e);
          alertsCallback(
            _scaffoldKey,
            "Время ожидания загрузки истекло",
            Duration(seconds: 5),
          );
          break;
        default:
          alertsCallback(
            _scaffoldKey,
            e.toString(),
            Duration(seconds: 5),
          );
          print(e);
      }
      cancelToken.cancel("");
    } catch (e) {
      print(e);
      alertsCallback(
        _scaffoldKey,
        e.toString(),
        Duration(seconds: 5),
      );
      cancelToken.cancel("");
    }

    downloadProgressCallback(null);
    if (!cancelToken.isCancelled) {
      alertsCallback(
        _scaffoldKey,
        "Файл скачан",
        Duration(seconds: 5),
        action: SnackBarAction(
          label: "Открыть",
          onPressed: () => OpenFile.open(fileUri),
        ),
      );
    }
  }

  alertsCallback(GlobalKey<ScaffoldState> _scaffoldKey, String alertText,
      Duration alertDuration,
      {SnackBarAction action}) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    if (alertText.isEmpty) {
      return;
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(alertText),
      duration: alertDuration,
      action: action,
    ));
  }

  void dispose() {
    _bookInfoController.close();
  }
}
