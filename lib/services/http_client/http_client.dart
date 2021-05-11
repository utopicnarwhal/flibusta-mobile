import 'dart:io';
import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flibusta/blocs/user_contact_data/user_contact_data_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/model/connectionCheckResult.dart';
import 'package:flibusta/services/http_client/custom_interceptor.dart';
import 'package:flibusta/services/http_client/dio_http_client_adapters/socks_http_client_adapter.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utopic_toast/utopic_toast.dart';

class ProxyHttpClient {
  static final ProxyHttpClient _httpClientSingleton = ProxyHttpClient._internal();

  factory ProxyHttpClient() {
    _httpClientSingleton?._init();
    return _httpClientSingleton;
  }
  ProxyHttpClient._internal();

  static BaseOptions defaultDioOptions = BaseOptions(
    connectTimeout: 10000,
    receiveTimeout: 10000,
    sendTimeout: 10000,
    followRedirects: true,
  );
  Dio _dio = Dio(defaultDioOptions);

  PersistCookieJar _persistCookieJar;
  CookieManager _cookieManager;

  String _proxyHostPort = '';
  Uri _proxyApiUri = Uri.http('pubproxy.com', '/api/proxy', {
    'https': 'true',
    'not_country': 'RU',
    'LEVEL': 'elite',
    'format': 'txt',
  });

  String _hostAddress = '';

  Dio getDio() {
    return _dio;
  }

  Future<Response<T>> getUri<T>(
    Uri uri, {
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) {
    return _dio.getUri(
      uri,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> postUri<T>(
    Uri uri, {
    data,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    return _dio.postUri(
      uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
    );
  }

  Future<Response> downloadUri(
    Uri uri,
    savePath, {
    ProgressCallback onReceiveProgress,
    CancelToken cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options options,
  }) {
    return _dio.downloadUri(
      uri,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }

  Future<void> initCookieJar() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _persistCookieJar = PersistCookieJar(storage: FileStorage(appDocPath + '/.cookies/'));

    _cookieManager = CookieManager(_persistCookieJar);
    _dio.interceptors.add(_cookieManager);
  }

  void _init() {
    if (_dio.interceptors.isNotEmpty) {
      return;
    }

    _dio.interceptors.addAll([
      CustomInterceptor(),
      if (_cookieManager != null) _cookieManager,
    ]);
  }

  Future<void> setProxy(String hostPort, {bool isSocks4aProxy = false}) async {
    if (_proxyHostPort == hostPort) {
      return;
    }
    _proxyHostPort = hostPort;

    var newDio = Dio(defaultDioOptions);
    if (isSocks4aProxy) {
      newDio.httpClientAdapter = SocksHttpClientAdapter();
    }

    newDio.interceptors.addAll([
      CustomInterceptor(),
      if (_cookieManager != null) _cookieManager,
    ]);

    if (newDio.httpClientAdapter is DefaultHttpClientAdapter) {
      (newDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => host == 'flibusta.is';

        if (hostPort == '') {
          client.findProxy = null;
          return client;
        }
        client.findProxy = (url) {
          return '${isSocks4aProxy ? 'SOCKS4A' : 'PROXY'} $hostPort';
        };
        return client;
      };
    }
    _dio.clear();
    _dio.close();
    _dio = newDio;
    _init();
  }

  String getActualProxy() {
    return _proxyHostPort;
  }

  Future<void> setHostAddress(String hostAddress, [bool checkAuth = true]) async {
    _hostAddress = hostAddress;
    if (checkAuth) {
      if (await isAuthorized()) {
        UserContactDataBloc().refreshUserContactData();
      } else {
        UserContactDataBloc().signOutUserContactData();
      }
    }
  }

  String getHostAddress() {
    return _hostAddress;
  }

  Future<ConnectionCheckResult> connectionCheck(
    String hostPort, {
    CancelToken cancelToken,
  }) async {
    var dioForConnectionCheck = Dio(
      BaseOptions(
        connectTimeout: 10000,
        receiveTimeout: 6000,
        responseType: ResponseType.plain,
      ),
    );
    if (hostPort != '') {
      (dioForConnectionCheck.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => host == 'flibusta.is';
        client.findProxy = (url) {
          return 'PROXY $hostPort';
        };
      };
      dioForConnectionCheck.interceptors.add(
        InterceptorsWrapper(
          onError: (dioError, handler) async {
            if (dioError?.message?.contains('Proxy failed to establish tunnel (302 Found)') == true) {
              return handler.resolve(
                await dioForConnectionCheck.requestUri(
                  dioError.requestOptions.uri,
                  data: dioError.requestOptions.data,
                  options: Options(
                    method: dioError.requestOptions.method,
                    responseType: dioError.requestOptions.responseType,
                    contentType: dioError.requestOptions.contentType,
                  ),
                  onReceiveProgress: dioError.requestOptions.onReceiveProgress,
                  onSendProgress: dioError.requestOptions.onSendProgress,
                  cancelToken: dioError.requestOptions.cancelToken,
                ),
              );
            }
            return handler.next(DsError.fromDioError(dioError: dioError));
          },
        ),
      );
    }

    var result = ConnectionCheckResult(latency: -1);
    var stopWatch = new Stopwatch()..start();

    try {
      var response = await dioForConnectionCheck.getUri(
        Uri.https(getHostAddress(), '/'),
        cancelToken: cancelToken,
      );
      stopWatch.stop();

      switch (response.statusCode) {
        case 302:
        case 200:
          result.latency = stopWatch.elapsedMilliseconds;
          break;
        default:
          result.latency = -1;
      }
    } on DioError catch (dioError) {
      stopWatch.stop();
      result.latency = -1;
      result.error = DsError.fromDioError(dioError: dioError);
    }
    dioForConnectionCheck.clear();
    dioForConnectionCheck.close();
    return result;
  }

  Future<List<String>> getNewProxies() async {
    var dioForGetProxyAPI = Dio(
      BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 3000,
      ),
    );
    List<String> result = [];

    try {
      var request = dioForGetProxyAPI.getUri(
        _proxyApiUri,
      );
      var response = await request;

      if (response.statusCode != 200 || response.data == null) {
        return [];
      }

      if (response.data is String) {
        result = (response.data as String).split('\n');
      }
    } catch (error) {
      debugPrint(error);
      if (error is DioError && error.response.statusCode == 503) {
        ToastManager().showToast('Вы достигли лимит в 50 запросов на сегодня');
      } else {
        ToastManager().showToast(error.toString());
      }
    }
    dioForGetProxyAPI.close();
    return result;
  }

  void signOut() {
    _persistCookieJar.deleteAll();
  }

  String getCookies() {
    var uri = Uri.https(_hostAddress, '');
    if (_hostAddress == kFlibustaOnionUrl) {
      uri = Uri.http(kFlibustaOnionUrl, '');
    }
    return _persistCookieJar.loadForRequest(uri).toString();
  }

  Future<bool> isAuthorized() async {
    var uri = Uri.https(_hostAddress, '');
    if (_hostAddress == kFlibustaOnionUrl) {
      uri = Uri.http(kFlibustaOnionUrl, '');
    }
    return (await _persistCookieJar.loadForRequest(uri)).isNotEmpty;
  }
}
