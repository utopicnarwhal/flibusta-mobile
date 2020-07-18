import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class CurlHttpClientAdapter extends HttpClientAdapter {
  bool _closed = false;

  String httpProxyCredHostPort;
  String socks4aHostPort;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>> requestStream,
    Future cancelFuture,
  ) async {
    if (_closed) {
      throw Exception(
          "Can't establish connection after [HttpClientAdapter] closed!");
    }

    var headersFilePath =
        await _getHeadersFilePath(options.hashCode.toString());

    final args = _getCurlArgs(
      options,
      requestStream,
      headersFilePath,
      acceptInsecure: true,
    );

    final responseStream = await _startCurlAndWaitConnection(
      args,
      options,
      cancelFuture,
    );

    var headersFile = File(headersFilePath);
    var protocolsHeaders = headersFile
        .readAsStringSync()
        .split('\r\n\r\n')
        .where((element) => element.isNotEmpty)
        .toList();
    headersFile.delete();

    int responseStatusCode;
    String responseStatusMessage;
    Map<String, List<String>> responseHeaders = {};
    List<RedirectRecord> redirectRecords = [];

    for (var protocolHeaders in protocolsHeaders) {
      var lines = protocolHeaders.split('\n');
      if (lines.length == 1) continue;

      var httpStatusMatch =
          RegExp(r'HTTP\/\S+\s(\d\d\d)\s(.*)').firstMatch(lines.first);
      var statusCode = int.tryParse(httpStatusMatch?.group(1));

      Map<String, List<String>> headers = {};
      lines.sublist(1).forEach((headerString) {
        var splittedHeader = headerString.split(': ');
        var headerName = splittedHeader[0].trim().toLowerCase();
        var headerValue = splittedHeader[1].trim();

        headers.update(
          headerName,
          (value) {
            if (headerName == HttpHeaders.setCookieHeader) {
              return [...value, headerValue];
            }
            return [headerValue];
          },
          ifAbsent: () => [headerValue],
        );
      });
      if (headers[HttpHeaders.setCookieHeader]?.isNotEmpty == true) {
        responseHeaders.update(
          HttpHeaders.setCookieHeader,
          (value) => [...value, ...headers[HttpHeaders.setCookieHeader]],
          ifAbsent: () => headers[HttpHeaders.setCookieHeader],
        );
        headers.remove(HttpHeaders.setCookieHeader);
      }
      if (headers[HttpHeaders.locationHeader]?.isNotEmpty != true) {
        responseStatusCode = statusCode;
        responseStatusMessage = httpStatusMatch?.group(2);
        responseHeaders.addAll(headers);
        break;
      }
      redirectRecords.add(RedirectRecord(
        statusCode ?? 200,
        options.method,
        Uri.parse(headers[HttpHeaders.locationHeader]?.first ?? ''),
      ));
    }

    return ResponseBody(
      responseStream,
      responseStatusCode ?? 200,
      headers: responseHeaders,
      isRedirect: redirectRecords?.isNotEmpty,
      redirects: redirectRecords,
      statusMessage: responseStatusMessage,
    );
  }

  Future<Stream<Uint8List>> _startCurlAndWaitConnection(
    List<String> args,
    RequestOptions options,
    Future cancelFuture,
  ) async {
    var process = await Process.start(
      'curl',
      args,
    ).timeout(Duration(milliseconds: options.connectTimeout), onTimeout: () {
      throw DioError(
        request: options,
        error: 'Connecting timed out [${options.connectTimeout}ms]',
        type: DioErrorType.CONNECT_TIMEOUT,
      );
    });

    // if (kReleaseMode == false) {
    //   process.stderr.listen((event) {
    //     print(String.fromCharCodes(event));
    //   });
    // } else {
    process.stderr.drain();
    // }

    cancelFuture?.whenComplete(() {
      process.kill();
    });

    final streamSplitter = StreamSplitter(process.stdout);
    final responseStream = streamSplitter.split().transform<Uint8List>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(Uint8List.fromList(data));
        },
      ),
    );
    await Future.any([
      streamSplitter.split().first,
      process.exitCode,
    ]);
    streamSplitter.close();

    return responseStream;
  }

  Future<String> _getHeadersFilePath(String uniqueString) async {
    return (await getApplicationSupportDirectory()).path +
        '/tempHeader$uniqueString.txt';
  }

  List<String> _getCurlArgs(
    RequestOptions options,
    Stream<List<int>> requestStream,
    String headersFilePath, {
    bool acceptInsecure,
  }) {
    final args = <String>[];

    if (options.followRedirects == null || options.followRedirects) {
      args.add('-L');
    }

    if (httpProxyCredHostPort?.isNotEmpty == true) {
      // Look for proxy authentication.
      int at = httpProxyCredHostPort.indexOf("@");
      if (at != -1) {
        String userInfo = httpProxyCredHostPort.substring(0, at).trim();
        args.addAll(['-U', userInfo]);
      }
      // Look for proxy host and port.
      String hostPort = httpProxyCredHostPort.substring(at != -1 ? at + 1 : 0);
      args.addAll(['-x', hostPort]);
    }

    if (options.connectTimeout != null) {
      args.addAll([
        '--connect-timeout',
        (options.connectTimeout / 1000).toString(),
      ]);
    }
    if (options.maxRedirects != null) {
      args.addAll(['--max-redirs', options.maxRedirects.toString()]);
    }
    options.headers.remove(HttpHeaders.contentLengthHeader);
    if (options.headers[HttpHeaders.userAgentHeader] != null) {
      args.addAll(['-A', options.headers[HttpHeaders.userAgentHeader]]);
      options.headers.remove(HttpHeaders.userAgentHeader);
    }
    if (options.headers[HttpHeaders.cookieHeader] != null) {
      args.addAll(['-b', options.headers[HttpHeaders.cookieHeader]]);
      options.headers.remove(HttpHeaders.cookieHeader);
    }
    options.headers?.forEach((key, value) {
      args.addAll(['-H', '\"$key: $value\"']);
    });

    if (socks4aHostPort != null) {
      args.addAll([
        '--socks4a',
        socks4aHostPort,
      ]);
    }

    if (options.data != null || requestStream != null) {
      if (options.headers[Headers.contentTypeHeader] ==
              Headers.formUrlEncodedContentType &&
          options.data is Map) {
        (options.data as Map).entries.forEach((element) {
          args.addAll(['--data-urlencode', '${element.key}=${element.value}']);
        });
      } else {
        args.addAll(['-d', options.data]);
      }
    }

    if (acceptInsecure) {
      args.add('-k');
    }

    final method = options.method ?? 'GET';
    if (method?.toUpperCase() != 'GET') {
      args.addAll(['-X', method.toUpperCase()]);
    }

    if (headersFilePath != null) {
      args.addAll(['-D', headersFilePath]);
    }

    args.addAll(['--url', options.uri.toString()]);

    args.addAll(['--output', '-']);

    return args;
  }

  @override
  void close({bool force = false}) {
    _closed = true;
  }
}
