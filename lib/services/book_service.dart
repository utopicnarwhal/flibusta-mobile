import 'dart:convert';
import 'dart:io';

import 'package:flibusta/model/bookInfo.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/utils/html_parsers.dart';
import 'package:flibusta/utils/native_methods.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as htmldom;

class BookService {
  static HttpClient _httpClient = ProxyHttpClient().getHttpClient();

  static downloadBook(int id, Map<String, String> downloadFormat, void Function(double) downloadProgressCallback, void Function(String, Duration) alertsCallback) async {
    if (!await SimplePermissions.checkPermission(Permission.WriteExternalStorage)) {
      await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    }
    
    Directory saveDocDir = await getExternalStorageDirectory();
    saveDocDir = Directory(saveDocDir.path + "/Flibusta");
    if (!saveDocDir.existsSync()) {
      saveDocDir.createSync(recursive: true);
      await NativeMethods.rescanFolder(saveDocDir.path + "/Flibusta");
    }

    downloadProgressCallback(0.0);
    alertsCallback("Подготовка к загрузке", Duration(minutes: 1));

    Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/b/$id/${downloadFormat.values.first}");
    var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 10), onTimeout: () {return null;}).then((r) => r.close());

    if (response == null || response.statusCode != 200) {
      downloadProgressCallback(null);
      alertsCallback("Не удалось загрузить", Duration(seconds: 5));
      return;
    }

    alertsCallback("", Duration(seconds: 0));

    var contentDisposition = response.headers["content-disposition"];

    if (contentDisposition == null) {
      downloadProgressCallback(null);
      alertsCallback("Доступ к книге ограничен по требованию правоторговца", Duration(seconds: 5));
      return;
    }

    var fileUri = "";
    try {
      fileUri = saveDocDir.path + "/" + contentDisposition[0]?.split("filename=")[1].replaceAll("\"", "");
    } catch (e) {
      downloadProgressCallback(null);
      return;
    }
    var myFile = File(fileUri);
    if (myFile.existsSync()) {
      downloadProgressCallback(null);

      alertsCallback("Файл с таким именем уже есть", Duration(seconds: 5));
      return;
    }
    
    int downloadedContents = 0;
    var myFileSink = myFile.openWrite();
    var fileSize = response.contentLength;
    try {
      await response.listen((contents) {
        myFileSink.add(contents);
        downloadedContents += contents.length;
        
        downloadProgressCallback(downloadedContents / fileSize);
      }).asFuture();
    } catch (exc) {
      print(exc);
    }
    await myFileSink.flush();
    await myFileSink.close();

    await NativeMethods.rescanFolder(myFile.path);

    downloadProgressCallback(null);
    alertsCallback("Файл скачан", Duration(seconds: 5));
  }

  static Future<BookInfo> getBookInfo(int bookId) async {
    var bookInfo = BookInfo(id: bookId);
    try {
      Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/b/" + bookId.toString());
      var superRealResponse = "";
      var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 5)).then((r) => r.close());
      await response.transform(utf8.decoder).listen((contents) {
        superRealResponse += contents;
      }).asFuture();
      htmldom.Document document = parse(superRealResponse);

      bookInfo = parseHtmlFromBookInfo(document, bookId);
    } catch(e) {
      print(e);
    }

    return bookInfo;
  }
}