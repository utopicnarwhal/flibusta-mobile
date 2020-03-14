import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/pages/home/components/show_download_format_mbs.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/file_utils.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:flibusta/utils/permissions_utils.dart';
import 'package:flibusta/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';

class BookService {
  static Future<BookInfo> getBookInfo(int bookId) async {
    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      "/b/" + bookId.toString(),
    );
    var response = await ProxyHttpClient().getDio().getUri<String>(url);

    return parseHtmlFromBookInfo(response.data, bookId);
  }

  static Future<List<int>> getBookCoverImage(String coverImgSrc) async {
    var url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      coverImgSrc,
    );

    var response = await ProxyHttpClient().getDio().getUri<List<int>>(
          url,
          options: Options(
            sendTimeout: 15000,
            receiveTimeout: 8000,
            responseType: ResponseType.bytes,
          ),
        );

    return response.data;
  }

  static Future<Null> downloadBook(
    BuildContext context,
    BookCard bookCard,
    void Function(double) downloadProgressCallback,
  ) async {
    PermissionsUtils.storageAccess(context: context);

    Map<String, String> downloadFormat;
    var preferredBookExt = await LocalStorage().getPreferredBookExt();
    if (preferredBookExt != null) {
      downloadFormat = bookCard.downloadFormats.list.firstWhere(
        (bookFormat) => preferredBookExt == bookFormat.keys.first,
        orElse: () => null,
      );
    }
    if (downloadFormat == null) {
      downloadFormat = await showDownloadFormatMBS(context, bookCard);
      if (downloadFormat == null) {
        return;
      }
    }

    Directory saveDocDir = await LocalStorage().getBooksDirectory();
    saveDocDir = Directory(saveDocDir.path);
    if (!saveDocDir.existsSync()) {
      saveDocDir.createSync(recursive: true);
      await NativeMethods.rescanFolder(saveDocDir.path);
    }

    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/b/${bookCard.id}/${downloadFormat.values.first}',
    );
    String fileUri = '';
    CancelToken cancelToken = CancelToken();
    cancelToken.whenCancel.whenComplete(() {
      _alertsCallback(cancelToken.cancelError.message, Duration(seconds: 5));
    });

    downloadProgressCallback(0.0);
    _alertsCallback(
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
              _alertsCallback('', Duration(seconds: 0));

              var contentDisposition = responseHeaders['content-disposition'];
              if (contentDisposition == null) {
                downloadProgressCallback(null);
                cancelToken.cancel(
                  'Доступ к книге ограничен по требованию правоторговца',
                );
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
        _alertsCallback('Не удалось загрузить', Duration(seconds: 5));
        return;
      }

      await NativeMethods.rescanFolder(fileUri);
      await LocalStorage().addDownloadedBook(bookCard);

      _alertsCallback(
        'Файл скачан',
        Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () => FileUtils.openFile(fileUri),
        ),
      );
    } on DsError catch (dsError) {
      _alertsCallback(
        dsError.toString(),
        Duration(seconds: 5),
      );
      cancelToken.cancel('');
    } catch (e) {
      print(e);
      _alertsCallback(
        e.toString(),
        Duration(seconds: 5),
      );
      cancelToken.cancel('');
    }

    downloadProgressCallback(null);
  }

  static _alertsCallback(String alertText, Duration alertDuration,
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
}
