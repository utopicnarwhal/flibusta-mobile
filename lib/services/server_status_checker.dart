import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:rxdart/rxdart.dart';

class ServerStatusResult {
  DioError error;
  Map<String, dynamic> status;

  ServerStatusResult({
    this.error,
    this.status,
  });
}

class ServerStatusChecker {
  Dio _dioForCheck;
  var serverStatusController = BehaviorSubject<ServerStatusResult>();

  ServerStatusChecker() {
    _dioForCheck = Dio();
    _dioForCheck.interceptors.add(CookieManager(CookieJar()));
    check();
  }

  Future<void> check() async {
    serverStatusController.add(null);

    var serverStatusResult = ServerStatusResult();
    try {
      var urlToCheck = ProxyHttpClient().getHostAddress();
      if (urlToCheck == kFlibustaOnionUrl) {
        urlToCheck = await LocalStorage().getHostAddress();
      }

      var response = await _dioForCheck.get(
        'https://api.downfor.cloud/httpcheck/$urlToCheck',
        options: Options(
          headers: {
            'user-agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36',
            'accept-language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          },
        ),
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        serverStatusResult.status = response.data;
      }
    } on DioError catch (dioError) {
      serverStatusResult.error = dioError;
    }
    serverStatusController.add(serverStatusResult);
  }

  void dispose() {
    serverStatusController?.close();
    _dioForCheck?.close();
  }
}
