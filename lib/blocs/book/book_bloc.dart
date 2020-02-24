import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/file_utils.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:flibusta/utils/permissions_utils.dart';
import 'package:flibusta/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BookBloc {
  BookBloc(this._bookId);

  int _bookId;

  var _bookInfoController = BehaviorSubject<BookInfo>.seeded(null);
  Stream<BookInfo> get outBookInfo => _bookInfoController.stream;
  Sink<BookInfo> get _inBookInfo => _bookInfoController.sink;

  Future<Null> getBookInfo() async {
    var bookInfo = BookInfo(id: _bookId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(),
          "/b/" + _bookId.toString());
      var response = await ProxyHttpClient().getDio().getUri(url);

      bookInfo = parseHtmlFromBookInfo(response.data, _bookId);
    } catch (e) {
      print(e);
    }

    _inBookInfo.add(bookInfo);
  }

  Future<Null> downloadBook(
    BuildContext context,
    BookCard bookCard,
    Map<String, String> downloadFormat,
    void Function(double) downloadProgressCallback,
  ) async {
    PermissionsUtils.storageAccess(context: context);

    Directory saveDocDir = await LocalStorage().getBooksDirectory();
    saveDocDir = Directory(saveDocDir.path);
    if (!saveDocDir.existsSync()) {
      saveDocDir.createSync(recursive: true);
      await NativeMethods.rescanFolder(saveDocDir.path);
    }

    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(),
        "/b/$_bookId/${downloadFormat.values.first}");
    String fileUri = "";
    CancelToken cancelToken = CancelToken();
    cancelToken.whenCancel.whenComplete(() {
      alertsCallback(cancelToken.cancelError.message, Duration(seconds: 5));
    });

    downloadProgressCallback(0.0);
    alertsCallback(
      'Подготовка к загрузке',
      Duration(minutes: 1),
      action: SnackBarAction(
        label: 'Отменить',
        onPressed: () {
          cancelToken.cancel('Загрузка отменена');
        },
      ),
    );

    try {
      var response = await ProxyHttpClient().getDio().downloadUri(
            url,
            (Headers responseHeaders) {
              alertsCallback('', Duration(seconds: 0));

              var contentDisposition = responseHeaders["content-disposition"];
              if (contentDisposition == null) {
                downloadProgressCallback(null);
                cancelToken.cancel(
                    "Доступ к книге ограничен по требованию правоторговца");
                return fileUri;
              }

              try {
                fileUri = saveDocDir.path +
                    "/" +
                    contentDisposition[0]
                        .split('filename=')[1]
                        .replaceAll('\"', '');
              } catch (e) {
                downloadProgressCallback(null);
                cancelToken.cancel('Не удалось получить имя файла');
                return fileUri;
              }

              var myFile = File(fileUri);
              if (myFile.existsSync()) {
                downloadProgressCallback(null);
                cancelToken.cancel('Файл с таким именем уже есть');
                return fileUri;
              }

              bookCard.localPath = fileUri;
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
        alertsCallback('Не удалось загрузить', Duration(seconds: 5));
        return;
      }

      await NativeMethods.rescanFolder(fileUri);
      await LocalStorage().addDownloadedBook(bookCard);

      alertsCallback(
        'Файл скачан',
        Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () => FileUtils.openFile(fileUri),
        ),
      );
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.CONNECT_TIMEOUT:
          print(e.request.path);
          alertsCallback(
            'Время ожидания соединения истекло',
            Duration(seconds: 5),
          );
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          print(e);
          alertsCallback(
            "Время ожидания загрузки истекло",
            Duration(seconds: 5),
          );
          break;
        default:
          alertsCallback(
            e.toString(),
            Duration(seconds: 5),
          );
          print(e);
      }
      cancelToken.cancel("");
    } catch (e) {
      print(e);
      alertsCallback(
        e.toString(),
        Duration(seconds: 5),
      );
      cancelToken.cancel("");
    }

    downloadProgressCallback(null);
  }

  alertsCallback(String alertText,
      Duration alertDuration,
      {SnackBarAction action}) {
    if (alertText.isEmpty) {
      return;
    }

    ToastUtils.showToast(
      alertText,
      duration: alertDuration,
      action: action,
    );
  }

  void dispose() {
    _bookInfoController.close();
  }
}
