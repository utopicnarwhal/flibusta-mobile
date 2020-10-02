part of 'socks_http_client_adapter.dart';

// ignore_for_file: unnecessary_brace_in_string_interps, prefer_is_not_empty, cancel_subscriptions, avoid_init_to_null, unused_element, close_sinks, unused_field, empty_statements, unnecessary_statements, slash_for_doc_comments, todo

// ! THIS FILE IS A TEMPORARY SOLUTION UNTIL DART DOES NOT SUPPORT SOCKS4A PROXY
int _nextServiceId = 1;

const String _DART_SESSION_ID = "DARTSESSID";

abstract class _ServiceObject {
  int __serviceId = 0;
  int get _serviceId {
    if (__serviceId == 0) __serviceId = _nextServiceId++;
    return __serviceId;
  }

  String get _servicePath => "$_serviceTypePath/$_serviceId";

  String get _serviceTypePath;

  String get _serviceTypeName;

  String _serviceType(bool ref) {
    if (ref) return "@$_serviceTypeName";
    return _serviceTypeName;
  }
}

class _CopyingBytesBuilder implements BytesBuilder {
  // Start with 1024 bytes.
  static const int _INIT_SIZE = 1024;

  static final _emptyList = new Uint8List(0);

  int _length = 0;
  Uint8List _buffer;

  _CopyingBytesBuilder([int initialCapacity = 0])
      : _buffer = (initialCapacity <= 0)
            ? _emptyList
            : new Uint8List(_pow2roundup(initialCapacity));

  void add(List<int> bytes) {
    int bytesLength = bytes.length;
    if (bytesLength == 0) return;
    int required = _length + bytesLength;
    if (_buffer.length < required) {
      _grow(required);
    }
    assert(_buffer.length >= required);
    if (bytes is Uint8List) {
      _buffer.setRange(_length, required, bytes);
    } else {
      for (int i = 0; i < bytesLength; i++) {
        _buffer[_length + i] = bytes[i];
      }
    }
    _length = required;
  }

  void addByte(int byte) {
    if (_buffer.length == _length) {
      // The grow algorithm always at least doubles.
      // If we added one to _length it would quadruple unnecessarily.
      _grow(_length);
    }
    assert(_buffer.length > _length);
    _buffer[_length] = byte;
    _length++;
  }

  void _grow(int required) {
    // We will create a list in the range of 2-4 times larger than
    // required.
    int newSize = required * 2;
    if (newSize < _INIT_SIZE) {
      newSize = _INIT_SIZE;
    } else {
      newSize = _pow2roundup(newSize);
    }
    var newBuffer = new Uint8List(newSize);
    newBuffer.setRange(0, _buffer.length, _buffer);
    _buffer = newBuffer;
  }

  Uint8List takeBytes() {
    if (_length == 0) return _emptyList;
    var buffer =
        new Uint8List.view(_buffer.buffer, _buffer.offsetInBytes, _length);
    clear();
    return buffer;
  }

  Uint8List toBytes() {
    if (_length == 0) return _emptyList;
    return new Uint8List.fromList(
        new Uint8List.view(_buffer.buffer, _buffer.offsetInBytes, _length));
  }

  int get length => _length;

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length != 0;

  void clear() {
    _length = 0;
    _buffer = _emptyList;
  }

  static int _pow2roundup(int x) {
    assert(x > 0);
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x + 1;
  }
}

const int _OUTGOING_BUFFER_SIZE = 8 * 1024;

typedef void _BytesConsumer(List<int> bytes);

class _HttpIncoming extends Stream<Uint8List> {
  final int _transferLength;
  final Completer _dataCompleter = new Completer();
  Stream<Uint8List> _stream;

  bool fullBodyRead = false;

  // Common properties.
  final _HttpHeaders headers;
  bool upgraded = false;

  // ClientResponse properties.
  int statusCode;
  String reasonPhrase;

  // Request properties.
  String method;
  Uri uri;

  bool hasSubscriber = false;

  // The transfer length if the length of the message body as it
  // appears in the message (RFC 2616 section 4.4). This can be -1 if
  // the length of the massage body is not known due to transfer
  // codings.
  int get transferLength => _transferLength;

  _HttpIncoming(this.headers, this._transferLength, this._stream);

  StreamSubscription<Uint8List> listen(void onData(Uint8List event),
      {Function onError, void onDone(), bool cancelOnError}) {
    hasSubscriber = true;
    return _stream.handleError((error) {
      throw new HttpException(error.message, uri: uri);
    }).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  // Is completed once all data have been received.
  Future get dataDone => _dataCompleter.future;

  void close(bool closing) {
    fullBodyRead = true;
    hasSubscriber = true;
    _dataCompleter.complete(closing);
  }
}

abstract class _HttpInboundMessageListInt extends Stream<List<int>> {
  final _HttpIncoming _incoming;
  List<Cookie> _cookies;

  _HttpInboundMessageListInt(this._incoming);

  List<Cookie> get cookies {
    if (_cookies != null) return _cookies;
    return _cookies = headers._parseCookies();
  }

  _HttpHeaders get headers => _incoming.headers;
  String get protocolVersion => headers.protocolVersion;
  int get contentLength => headers.contentLength;
  bool get persistentConnection => headers.persistentConnection;
}

abstract class _HttpInboundMessage extends Stream<Uint8List> {
  final _HttpIncoming _incoming;
  List<Cookie> _cookies;

  _HttpInboundMessage(this._incoming);

  List<Cookie> get cookies {
    if (_cookies != null) return _cookies;
    return _cookies = headers._parseCookies();
  }

  _HttpHeaders get headers => _incoming.headers;
  String get protocolVersion => headers.protocolVersion;
  int get contentLength => headers.contentLength;
  bool get persistentConnection => headers.persistentConnection;
}

class _HttpRequest extends _HttpInboundMessage implements HttpRequest {
  final HttpResponse response;

  final _HttpServer _httpServer;

  final _HttpConnection _httpConnection;

  _HttpSession _session;

  Uri _requestedUri;

  _HttpRequest(this.response, _HttpIncoming _incoming, this._httpServer,
      this._httpConnection)
      : super(_incoming) {
    if (headers.protocolVersion == "1.1") {
      response.headers
        ..chunkedTransferEncoding = true
        ..persistentConnection = headers.persistentConnection;
    }

    if (_httpServer._sessionManagerInstance != null) {
      // Map to session if exists.
      var sessionIds = cookies
          .where((cookie) => cookie.name.toUpperCase() == _DART_SESSION_ID)
          .map((cookie) => cookie.value);
      for (var sessionId in sessionIds) {
        _session = _httpServer._sessionManager.getSession(sessionId);
        if (_session != null) {
          _session._markSeen();
          break;
        }
      }
    }
  }

  StreamSubscription<Uint8List> listen(void onData(Uint8List event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _incoming.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Uri get uri => _incoming.uri;

  Uri get requestedUri {
    if (_requestedUri == null) {
      var proto = headers['x-forwarded-proto'];
      var scheme = proto != null
          ? proto.first
          : _httpConnection._socket is SecureSocket ? "https" : "http";
      var hostList = headers['x-forwarded-host'];
      String host;
      if (hostList != null) {
        host = hostList.first;
      } else {
        hostList = headers[HttpHeaders.hostHeader];
        if (hostList != null) {
          host = hostList.first;
        } else {
          host = "${_httpServer.address.host}:${_httpServer.port}";
        }
      }
      _requestedUri = Uri.parse("$scheme://$host$uri");
    }
    return _requestedUri;
  }

  String get method => _incoming.method;

  HttpSession get session {
    if (_session != null) {
      if (_session._destroyed) {
        // It's destroyed, clear it.
        _session = null;
        // Create new session object by calling recursive.
        return session;
      }
      // It's already mapped, use it.
      return _session;
    }
    // Create session, store it in connection, and return.
    return _session = _httpServer._sessionManager.createSession();
  }

  HttpConnectionInfo get connectionInfo => _httpConnection.connectionInfo;

  X509Certificate get certificate {
    var socket = _httpConnection._socket;
    if (socket is SecureSocket) return socket.peerCertificate;
    return null;
  }
}

class _HttpClientResponse extends _HttpInboundMessageListInt
    implements HttpClientResponse {
  List<RedirectInfo> get redirects => _httpRequest._responseRedirects;

  // The HttpClient this response belongs to.
  final _HttpClient _httpClient;

  // The HttpClientRequest of this response.
  final _HttpClientRequest _httpRequest;

  // The compression state of this response.
  final HttpClientResponseCompressionState compressionState;

  _HttpClientResponse(
      _HttpIncoming _incoming, this._httpRequest, this._httpClient)
      : compressionState = _getCompressionState(_httpClient, _incoming.headers),
        super(_incoming) {
    // Set uri for potential exceptions.
    _incoming.uri = _httpRequest.uri;
  }

  static HttpClientResponseCompressionState _getCompressionState(
      _HttpClient httpClient, _HttpHeaders headers) {
    if (headers.value(HttpHeaders.contentEncodingHeader) == "gzip") {
      return httpClient.autoUncompress
          ? HttpClientResponseCompressionState.decompressed
          : HttpClientResponseCompressionState.compressed;
    } else {
      return HttpClientResponseCompressionState.notCompressed;
    }
  }

  int get statusCode => _incoming.statusCode;
  String get reasonPhrase => _incoming.reasonPhrase;

  X509Certificate get certificate {
    // ignore: close_sinks
    var socket = _httpRequest._httpClientConnection._socket;
    if (socket is SecureSocket) return socket.peerCertificate;
    return null;
  }

  List<Cookie> get cookies {
    if (_cookies != null) return _cookies;
    _cookies = new List<Cookie>();
    List<String> values = headers[HttpHeaders.setCookieHeader];
    if (values != null) {
      values.forEach((value) {
        _cookies.add(new Cookie.fromSetCookieValue(value));
      });
    }
    return _cookies;
  }

  bool get isRedirect {
    if (_httpRequest.method == "GET" || _httpRequest.method == "HEAD") {
      return statusCode == HttpStatus.movedPermanently ||
          statusCode == HttpStatus.found ||
          statusCode == HttpStatus.seeOther ||
          statusCode == HttpStatus.temporaryRedirect;
    } else if (_httpRequest.method == "POST") {
      return statusCode == HttpStatus.seeOther;
    }
    return false;
  }

  Future<HttpClientResponse> redirect(
      [String method, Uri url, bool followLoops]) {
    if (method == null) {
      // Set method as defined by RFC 2616 section 10.3.4.
      if (statusCode == HttpStatus.seeOther && _httpRequest.method == "POST") {
        method = "GET";
      } else {
        method = _httpRequest.method;
      }
    }
    if (url == null) {
      String location = headers.value(HttpHeaders.locationHeader);
      if (location == null) {
        throw new StateError("Response has no Location header for redirect");
      }
      url = Uri.parse(location);
    }
    if (followLoops != true) {
      for (var redirect in redirects) {
        if (redirect.location == url) {
          return new Future.error(
              new RedirectException("Redirect loop detected", redirects));
        }
      }
    }
    return _httpClient
        ._openUrlFromRequest(method, url, _httpRequest)
        .then((request) {
      request._responseRedirects
        ..addAll(this.redirects)
        ..add(new _RedirectInfo(statusCode, method, url));
      return request.close();
    });
  }

  StreamSubscription<Uint8List> listen(void onData(Uint8List event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (_incoming.upgraded) {
      // If upgraded, the connection is already 'removed' form the client.
      // Since listening to upgraded data is 'bogus', simply close and
      // return empty stream subscription.
      _httpRequest._httpClientConnection.destroy();
      return new Stream<Uint8List>.empty().listen(null, onDone: onDone);
    }
    Stream<Uint8List> stream = _incoming;
    if (compressionState == HttpClientResponseCompressionState.decompressed) {
      stream = stream
          .cast<List<int>>()
          .transform(gzip.decoder)
          .transform(const _ToUint8List());
    }
    return stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future<Socket> detachSocket() {
    _httpClient._connectionClosed(_httpRequest._httpClientConnection);
    return _httpRequest._httpClientConnection.detachSocket();
  }

  HttpConnectionInfo get connectionInfo => _httpRequest.connectionInfo;

  bool get _shouldAuthenticateProxy {
    // Only try to authenticate if there is a challenge in the response.
    List<String> challenge = headers[HttpHeaders.proxyAuthenticateHeader];
    return statusCode == HttpStatus.proxyAuthenticationRequired &&
        challenge != null &&
        challenge.length == 1;
  }

  bool get _shouldAuthenticate {
    // Only try to authenticate if there is a challenge in the response.
    List<String> challenge = headers[HttpHeaders.wwwAuthenticateHeader];
    return statusCode == HttpStatus.unauthorized &&
        challenge != null &&
        challenge.length == 1;
  }

  Future<HttpClientResponse> _authenticate(bool proxyAuth) {
    _httpRequest._timeline?.instant('Authentication');
    Future<HttpClientResponse> retry() {
      _httpRequest._timeline?.instant('Retrying');
      // Drain body and retry.
      return drain().then((_) {
        return _httpClient
            ._openUrlFromRequest(
                _httpRequest.method, _httpRequest.uri, _httpRequest)
            .then((request) => request.close());
      });
    }

    List<String> authChallenge() {
      return proxyAuth
          ? headers[HttpHeaders.proxyAuthenticateHeader]
          : headers[HttpHeaders.wwwAuthenticateHeader];
    }

    _Credentials findCredentials(_AuthenticationScheme scheme) {
      return proxyAuth
          ? _httpClient._findProxyCredentials(_httpRequest._proxy, scheme)
          : _httpClient._findCredentials(_httpRequest.uri, scheme);
    }

    void removeCredentials(_Credentials cr) {
      if (proxyAuth) {
        _httpClient._removeProxyCredentials(cr);
      } else {
        _httpClient._removeCredentials(cr);
      }
    }

    Future requestAuthentication(_AuthenticationScheme scheme, String realm) {
      if (proxyAuth) {
        if (_httpClient._authenticateProxy == null) {
          return new Future.value(false);
        }
        var proxy = _httpRequest._proxy;
        return _httpClient._authenticateProxy(
            proxy.host, proxy.port, scheme.toString(), realm);
      } else {
        if (_httpClient._authenticate == null) {
          return new Future.value(false);
        }
        return _httpClient._authenticate(
            _httpRequest.uri, scheme.toString(), realm);
      }
    }

    List<String> challenge = authChallenge();
    assert(challenge != null || challenge.length == 1);
    _HeaderValue header =
        _HeaderValue.parse(challenge[0], parameterSeparator: ",");
    _AuthenticationScheme scheme =
        new _AuthenticationScheme.fromString(header.value);
    String realm = header.parameters["realm"];

    // See if any matching credentials are available.
    _Credentials cr = findCredentials(scheme);
    if (cr != null) {
      // For basic authentication don't retry already used credentials
      // as they must have already been added to the request causing
      // this authenticate response.
      if (cr.scheme == _AuthenticationScheme.BASIC && !cr.used) {
        // Credentials where found, prepare for retrying the request.
        return retry();
      }

      // Digest authentication only supports the MD5 algorithm.
      if (cr.scheme == _AuthenticationScheme.DIGEST &&
          (header.parameters["algorithm"] == null ||
              header.parameters["algorithm"].toLowerCase() == "md5")) {
        if (cr.nonce == null || cr.nonce == header.parameters["nonce"]) {
          // If the nonce is not set then this is the first authenticate
          // response for these credentials. Set up authentication state.
          if (cr.nonce == null) {
            cr
              ..nonce = header.parameters["nonce"]
              ..algorithm = "MD5"
              ..qop = header.parameters["qop"]
              ..nonceCount = 0;
          }
          // Credentials where found, prepare for retrying the request.
          return retry();
        } else if (header.parameters["stale"] != null &&
            header.parameters["stale"].toLowerCase() == "true") {
          // If stale is true retry with new nonce.
          cr.nonce = header.parameters["nonce"];
          // Credentials where found, prepare for retrying the request.
          return retry();
        }
      }
    }

    // Ask for more credentials if none found or the one found has
    // already been used. If it has already been used it must now be
    // invalid and is removed.
    if (cr != null) {
      removeCredentials(cr);
      cr = null;
    }
    return requestAuthentication(scheme, realm).then((credsAvailable) {
      if (credsAvailable) {
        cr = _httpClient._findCredentials(_httpRequest.uri, scheme);
        return retry();
      } else {
        // No credentials available, complete with original response.
        return this;
      }
    });
  }
}

class _ToUint8List extends Converter<List<int>, Uint8List> {
  const _ToUint8List();

  Uint8List convert(List<int> input) => Uint8List.fromList(input);

  Sink<List<int>> startChunkedConversion(Sink<Uint8List> sink) {
    return _Uint8ListConversionSink(sink);
  }
}

class _Uint8ListConversionSink implements Sink<List<int>> {
  const _Uint8ListConversionSink(this._target);

  final Sink<Uint8List> _target;

  void add(List<int> data) {
    _target.add(Uint8List.fromList(data));
  }

  void close() {
    _target.close();
  }
}

class _StreamSinkImpl<T> implements StreamSink<T> {
  final StreamConsumer<T> _target;
  final Completer _doneCompleter = new Completer();
  StreamController<T> _controllerInstance;
  Completer _controllerCompleter;
  bool _isClosed = false;
  bool _isBound = false;
  bool _hasError = false;

  _StreamSinkImpl(this._target);

  void add(T data) {
    if (_isClosed) {
      throw StateError("StreamSink is closed");
    }
    _controller.add(data);
  }

  void addError(error, [StackTrace stackTrace]) {
    if (_isClosed) {
      throw StateError("StreamSink is closed");
    }
    _controller.addError(error, stackTrace);
  }

  Future addStream(Stream<T> stream) {
    if (_isBound) {
      throw new StateError("StreamSink is already bound to a stream");
    }
    _isBound = true;
    if (_hasError) return done;
    // Wait for any sync operations to complete.
    Future targetAddStream() {
      return _target.addStream(stream).whenComplete(() {
        _isBound = false;
      });
    }

    if (_controllerInstance == null) return targetAddStream();
    var future = _controllerCompleter.future;
    _controllerInstance.close();
    return future.then((_) => targetAddStream());
  }

  Future flush() {
    if (_isBound) {
      throw new StateError("StreamSink is bound to a stream");
    }
    if (_controllerInstance == null) return new Future.value(this);
    // Adding an empty stream-controller will return a future that will complete
    // when all data is done.
    _isBound = true;
    var future = _controllerCompleter.future;
    _controllerInstance.close();
    return future.whenComplete(() {
      _isBound = false;
    });
  }

  Future close() {
    if (_isBound) {
      throw new StateError("StreamSink is bound to a stream");
    }
    if (!_isClosed) {
      _isClosed = true;
      if (_controllerInstance != null) {
        _controllerInstance.close();
      } else {
        _closeTarget();
      }
    }
    return done;
  }

  void _closeTarget() {
    _target.close().then(_completeDoneValue, onError: _completeDoneError);
  }

  Future get done => _doneCompleter.future;

  void _completeDoneValue(value) {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete(value);
    }
  }

  void _completeDoneError(error, StackTrace stackTrace) {
    if (!_doneCompleter.isCompleted) {
      _hasError = true;
      _doneCompleter.completeError(error, stackTrace);
    }
  }

  StreamController<T> get _controller {
    if (_isBound) {
      throw new StateError("StreamSink is bound to a stream");
    }
    if (_isClosed) {
      throw new StateError("StreamSink is closed");
    }
    if (_controllerInstance == null) {
      _controllerInstance = new StreamController<T>(sync: true);
      _controllerCompleter = new Completer();
      _target.addStream(_controller.stream).then((_) {
        if (_isBound) {
          // A new stream takes over - forward values to that stream.
          _controllerCompleter.complete(this);
          _controllerCompleter = null;
          _controllerInstance = null;
        } else {
          // No new stream, .close was called. Close _target.
          _closeTarget();
        }
      }, onError: (error, stackTrace) {
        if (_isBound) {
          // A new stream takes over - forward errors to that stream.
          _controllerCompleter.completeError(error, stackTrace);
          _controllerCompleter = null;
          _controllerInstance = null;
        } else {
          // No new stream. No need to close target, as it has already
          // failed.
          _completeDoneError(error, stackTrace);
        }
      });
    }
    return _controllerInstance;
  }
}

class _IOSinkImpl extends _StreamSinkImpl<List<int>> implements IOSink {
  Encoding _encoding;
  bool _encodingMutable = true;

  _IOSinkImpl(StreamConsumer<List<int>> target, this._encoding) : super(target);

  Encoding get encoding => _encoding;

  set encoding(Encoding value) {
    if (!_encodingMutable) {
      throw new StateError("IOSink encoding is not mutable");
    }
    _encoding = value;
  }

  void write(Object obj) {
    String string = '$obj';
    if (string.isEmpty) return;
    add(_encoding.encode(string));
  }

  void writeAll(Iterable objects, [String separator = ""]) {
    Iterator iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  void writeln([Object object = ""]) {
    write(object);
    write("\n");
  }

  void writeCharCode(int charCode) {
    write(new String.fromCharCode(charCode));
  }
}

abstract class _HttpOutboundMessage<T> extends _IOSinkImpl {
  // Used to mark when the body should be written. This is used for HEAD
  // requests and in error handling.
  bool _encodingSet = false;

  bool _bufferOutput = true;

  final Uri _uri;
  final _HttpOutgoing _outgoing;

  final _HttpHeaders headers;

  _HttpOutboundMessage(Uri uri, String protocolVersion, _HttpOutgoing outgoing,
      {_HttpHeaders initialHeaders})
      : _uri = uri,
        headers = new _HttpHeaders(protocolVersion,
            defaultPortForScheme: uri.scheme == 'https'
                ? HttpClient.defaultHttpsPort
                : HttpClient.defaultHttpPort,
            initialHeaders: initialHeaders),
        _outgoing = outgoing,
        super(outgoing, null) {
    _outgoing.outbound = this;
    _encodingMutable = false;
  }

  int get contentLength => headers.contentLength;
  set contentLength(int contentLength) {
    headers.contentLength = contentLength;
  }

  bool get persistentConnection => headers.persistentConnection;
  set persistentConnection(bool p) {
    headers.persistentConnection = p;
  }

  bool get bufferOutput => _bufferOutput;
  set bufferOutput(bool bufferOutput) {
    if (_outgoing.headersWritten) throw new StateError("Header already sent");
    _bufferOutput = bufferOutput;
  }

  Encoding get encoding {
    if (_encodingSet && _outgoing.headersWritten) {
      return _encoding;
    }
    var charset;
    if (headers.contentType != null && headers.contentType.charset != null) {
      charset = headers.contentType.charset;
    } else {
      charset = "iso-8859-1";
    }
    return Encoding.getByName(charset);
  }

  void add(List<int> data) {
    if (data.length == 0) return;
    super.add(data);
  }

  void write(Object obj) {
    if (!_encodingSet) {
      _encoding = encoding;
      _encodingSet = true;
    }
    super.write(obj);
  }

  void _writeHeader();

  bool get _isConnectionClosed => false;
}

class _HttpResponse extends _HttpOutboundMessage<HttpResponse>
    implements HttpResponse {
  int _statusCode = 200;
  String _reasonPhrase;
  List<Cookie> _cookies;
  _HttpRequest _httpRequest;
  Duration _deadline;
  Timer _deadlineTimer;

  _HttpResponse(Uri uri, String protocolVersion, _HttpOutgoing outgoing,
      HttpHeaders defaultHeaders, String serverHeader)
      : super(uri, protocolVersion, outgoing, initialHeaders: defaultHeaders) {
    if (serverHeader != null) {
      headers.set(HttpHeaders.serverHeader, serverHeader);
    }
  }

  bool get _isConnectionClosed => _httpRequest._httpConnection._isClosing;

  List<Cookie> get cookies {
    if (_cookies == null) _cookies = new List<Cookie>();
    return _cookies;
  }

  int get statusCode => _statusCode;
  set statusCode(int statusCode) {
    if (_outgoing.headersWritten) throw new StateError("Header already sent");
    _statusCode = statusCode;
  }

  String get reasonPhrase => _findReasonPhrase(statusCode);
  set reasonPhrase(String reasonPhrase) {
    if (_outgoing.headersWritten) throw new StateError("Header already sent");
    _reasonPhrase = reasonPhrase;
  }

  Future redirect(Uri location, {int status: HttpStatus.movedTemporarily}) {
    if (_outgoing.headersWritten) throw new StateError("Header already sent");
    statusCode = status;
    headers.set(HttpHeaders.locationHeader, location.toString());
    return close();
  }

  Future<Socket> detachSocket({bool writeHeaders: true}) {
    if (_outgoing.headersWritten) throw new StateError("Headers already sent");
    deadline = null; // Be sure to stop any deadline.
    var future = _httpRequest._httpConnection.detachSocket();
    if (writeHeaders) {
      var headersFuture =
          _outgoing.writeHeaders(drainRequest: false, setOutgoing: false);
      assert(headersFuture == null);
    } else {
      // Imitate having written the headers.
      _outgoing.headersWritten = true;
    }
    // Close connection so the socket is 'free'.
    close();
    done.catchError((_) {
      // Catch any error on done, as they automatically will be
      // propagated to the websocket.
    });
    return future;
  }

  HttpConnectionInfo get connectionInfo => _httpRequest.connectionInfo;

  Duration get deadline => _deadline;

  set deadline(Duration d) {
    if (_deadlineTimer != null) _deadlineTimer.cancel();
    _deadline = d;

    if (_deadline == null) return;
    _deadlineTimer = new Timer(_deadline, () {
      _httpRequest._httpConnection.destroy();
    });
  }

  void _writeHeader() {
    BytesBuilder buffer = new _CopyingBytesBuilder(_OUTGOING_BUFFER_SIZE);

    // Write status line.
    if (headers.protocolVersion == "1.1") {
      buffer.add(_Const.HTTP11);
    } else {
      buffer.add(_Const.HTTP10);
    }
    buffer.addByte(_CharCode.SP);
    buffer.add(statusCode.toString().codeUnits);
    buffer.addByte(_CharCode.SP);
    buffer.add(reasonPhrase.codeUnits);
    buffer.addByte(_CharCode.CR);
    buffer.addByte(_CharCode.LF);

    var session = _httpRequest._session;
    if (session != null && !session._destroyed) {
      // Mark as not new.
      session._isNew = false;
      // Make sure we only send the current session id.
      bool found = false;
      for (int i = 0; i < cookies.length; i++) {
        if (cookies[i].name.toUpperCase() == _DART_SESSION_ID) {
          cookies[i]
            ..value = session.id
            ..httpOnly = true
            ..path = "/";
          found = true;
        }
      }
      if (!found) {
        var cookie = new Cookie(_DART_SESSION_ID, session.id);
        cookies.add(cookie
          ..httpOnly = true
          ..path = "/");
      }
    }
    // Add all the cookies set to the headers.
    if (_cookies != null) {
      _cookies.forEach((cookie) {
        headers.add(HttpHeaders.setCookieHeader, cookie);
      });
    }

    headers._finalize();

    // Write headers.
    headers._build(buffer);
    buffer.addByte(_CharCode.CR);
    buffer.addByte(_CharCode.LF);
    Uint8List headerBytes = buffer.takeBytes();
    _outgoing.setHeader(headerBytes, headerBytes.length);
  }

  String _findReasonPhrase(int statusCode) {
    if (_reasonPhrase != null) {
      return _reasonPhrase;
    }

    switch (statusCode) {
      case HttpStatus.continue_:
        return "Continue";
      case HttpStatus.switchingProtocols:
        return "Switching Protocols";
      case HttpStatus.ok:
        return "OK";
      case HttpStatus.created:
        return "Created";
      case HttpStatus.accepted:
        return "Accepted";
      case HttpStatus.nonAuthoritativeInformation:
        return "Non-Authoritative Information";
      case HttpStatus.noContent:
        return "No Content";
      case HttpStatus.resetContent:
        return "Reset Content";
      case HttpStatus.partialContent:
        return "Partial Content";
      case HttpStatus.multipleChoices:
        return "Multiple Choices";
      case HttpStatus.movedPermanently:
        return "Moved Permanently";
      case HttpStatus.found:
        return "Found";
      case HttpStatus.seeOther:
        return "See Other";
      case HttpStatus.notModified:
        return "Not Modified";
      case HttpStatus.useProxy:
        return "Use Proxy";
      case HttpStatus.temporaryRedirect:
        return "Temporary Redirect";
      case HttpStatus.badRequest:
        return "Bad Request";
      case HttpStatus.unauthorized:
        return "Unauthorized";
      case HttpStatus.paymentRequired:
        return "Payment Required";
      case HttpStatus.forbidden:
        return "Forbidden";
      case HttpStatus.notFound:
        return "Not Found";
      case HttpStatus.methodNotAllowed:
        return "Method Not Allowed";
      case HttpStatus.notAcceptable:
        return "Not Acceptable";
      case HttpStatus.proxyAuthenticationRequired:
        return "Proxy Authentication Required";
      case HttpStatus.requestTimeout:
        return "Request Time-out";
      case HttpStatus.conflict:
        return "Conflict";
      case HttpStatus.gone:
        return "Gone";
      case HttpStatus.lengthRequired:
        return "Length Required";
      case HttpStatus.preconditionFailed:
        return "Precondition Failed";
      case HttpStatus.requestEntityTooLarge:
        return "Request Entity Too Large";
      case HttpStatus.requestUriTooLong:
        return "Request-URI Too Long";
      case HttpStatus.unsupportedMediaType:
        return "Unsupported Media Type";
      case HttpStatus.requestedRangeNotSatisfiable:
        return "Requested range not satisfiable";
      case HttpStatus.expectationFailed:
        return "Expectation Failed";
      case HttpStatus.internalServerError:
        return "Internal Server Error";
      case HttpStatus.notImplemented:
        return "Not Implemented";
      case HttpStatus.badGateway:
        return "Bad Gateway";
      case HttpStatus.serviceUnavailable:
        return "Service Unavailable";
      case HttpStatus.gatewayTimeout:
        return "Gateway Time-out";
      case HttpStatus.httpVersionNotSupported:
        return "Http Version not supported";
      default:
        return "Status $statusCode";
    }
  }
}

class _HttpClientRequest extends _HttpOutboundMessage<HttpClientResponse>
    implements HttpClientRequest {
  final String method;
  final Uri uri;
  final List<Cookie> cookies = new List<Cookie>();

  // The HttpClient this request belongs to.
  final _HttpClient _httpClient;
  final _HttpClientConnection _httpClientConnection;
  final TimelineTask _timeline;

  final Completer<HttpClientResponse> _responseCompleter =
      new Completer<HttpClientResponse>();

  final _Proxy _proxy;

  Future<HttpClientResponse> _response;

  bool _followRedirects = true;

  int _maxRedirects = 5;

  List<RedirectInfo> _responseRedirects = [];

  _HttpClientRequest(_HttpOutgoing outgoing, Uri uri, this.method, this._proxy,
      this._httpClient, this._httpClientConnection, this._timeline)
      : uri = uri,
        super(uri, "1.1", outgoing) {
    _timeline?.instant('Request initiated');
    // GET and HEAD have 'content-length: 0' by default.
    if (method == "GET" || method == "HEAD") {
      contentLength = 0;
    } else {
      headers.chunkedTransferEncoding = true;
    }

    _responseCompleter.future.then((response) {
      _timeline?.instant('Response receieved');
      Map formatConnectionInfo() => {
            'localPort': response.connectionInfo?.localPort,
            'remoteAddress': response.connectionInfo?.remoteAddress?.address,
            'remotePort': response.connectionInfo?.remotePort,
          };

      Map formatHeaders() {
        final headers = <String, List<String>>{};
        response.headers.forEach((name, values) {
          headers[name] = values;
        });
        return headers;
      }

      List<Map<String, dynamic>> formatRedirectInfo() {
        final redirects = <Map<String, dynamic>>[];
        for (final redirect in response.redirects) {
          redirects.add({
            'location': redirect.location.toString(),
            'method': redirect.method,
            'statusCode': redirect.statusCode,
          });
        }
        return redirects;
      }

      _timeline?.finish(arguments: {
        // 'certificate': response.certificate,
        'requestHeaders': outgoing.outbound.headers._headers,
        'compressionState': response.compressionState.toString(),
        'connectionInfo': formatConnectionInfo(),
        'contentLength': response.contentLength,
        'cookies': [for (final cookie in response.cookies) cookie.toString()],
        'responseHeaders': formatHeaders(),
        'isRedirect': response.isRedirect,
        'persistentConnection': response.persistentConnection,
        'reasonPhrase': response.reasonPhrase,
        'redirects': formatRedirectInfo(),
        'statusCode': response.statusCode,
      });
    }, onError: (e) {});
  }

  Future<HttpClientResponse> get done {
    if (_response == null) {
      _response =
          Future.wait([_responseCompleter.future, super.done], eagerError: true)
              .then((list) => list[0]);
    }
    return _response;
  }

  Future<HttpClientResponse> close() {
    super.close();
    return done;
  }

  int get maxRedirects => _maxRedirects;
  set maxRedirects(int maxRedirects) {
    if (_outgoing.headersWritten) throw new StateError("Request already sent");
    _maxRedirects = maxRedirects;
  }

  bool get followRedirects => _followRedirects;
  set followRedirects(bool followRedirects) {
    if (_outgoing.headersWritten) throw new StateError("Request already sent");
    _followRedirects = followRedirects;
  }

  HttpConnectionInfo get connectionInfo => _httpClientConnection.connectionInfo;

  void _onIncoming(_HttpIncoming incoming) {
    var response = new _HttpClientResponse(incoming, this, _httpClient);
    Future<HttpClientResponse> future;
    if (followRedirects && response.isRedirect) {
      if (response.redirects.length < maxRedirects) {
        // Redirect and drain response.
        future = response
            .drain()
            .then<HttpClientResponse>((_) => response.redirect());
      } else {
        // End with exception, too many redirects.
        future = response.drain().then<HttpClientResponse>((_) {
          return new Future<HttpClientResponse>.error(new RedirectException(
              "Redirect limit exceeded", response.redirects));
        });
      }
    } else if (response._shouldAuthenticateProxy) {
      future = response._authenticate(true);
    } else if (response._shouldAuthenticate) {
      future = response._authenticate(false);
    } else {
      future = new Future<HttpClientResponse>.value(response);
    }
    future.then((v) => _responseCompleter.complete(v),
        onError: _responseCompleter.completeError);
  }

  void _onError(error, StackTrace stackTrace) {
    _responseCompleter.completeError(error, stackTrace);
  }

  // Generate the request URI based on the method and proxy.
  String _requestUri() {
    // Generate the request URI starting from the path component.
    String uriStartingFromPath() {
      String result = uri.path;
      if (result.isEmpty) result = "/";
      if (uri.hasQuery) {
        result = "${result}?${uri.query}";
      }
      return result;
    }

    if (_proxy.isDirect) {
      return uriStartingFromPath();
    } else {
      if (method == "CONNECT") {
        // For the connect method the request URI is the host:port of
        // the requested destination of the tunnel (see RFC 2817
        // section 5.2)
        return "${uri.host}:${uri.port}";
      } else {
        if (_httpClientConnection._proxyTunnel) {
          return uriStartingFromPath();
        } else {
          return uri.removeFragment().toString();
        }
      }
    }
  }

  void _writeHeader() {
    BytesBuilder buffer = new _CopyingBytesBuilder(_OUTGOING_BUFFER_SIZE);

    // Write the request method.
    buffer.add(method.codeUnits);
    buffer.addByte(_CharCode.SP);
    // Write the request URI.
    buffer.add(_requestUri().codeUnits);
    buffer.addByte(_CharCode.SP);
    // Write HTTP/1.1.
    buffer.add(_Const.HTTP11);
    buffer.addByte(_CharCode.CR);
    buffer.addByte(_CharCode.LF);

    // Add the cookies to the headers.
    if (!cookies.isEmpty) {
      StringBuffer sb = new StringBuffer();
      for (int i = 0; i < cookies.length; i++) {
        if (i > 0) sb.write("; ");
        sb..write(cookies[i].name)..write("=")..write(cookies[i].value);
      }
      headers.add(HttpHeaders.cookieHeader, sb.toString());
    }

    headers._finalize();

    // Write headers.
    headers._build(buffer);
    buffer.addByte(_CharCode.CR);
    buffer.addByte(_CharCode.LF);
    Uint8List headerBytes = buffer.takeBytes();
    _outgoing.setHeader(headerBytes, headerBytes.length);
  }

  @override
  void abort([Object exception, StackTrace stackTrace]) {}
}

// Used by _HttpOutgoing as a target of a chunked converter for gzip
// compression.
class _HttpGZipSink extends ByteConversionSink {
  final _BytesConsumer _consume;
  _HttpGZipSink(this._consume);

  void add(List<int> chunk) {
    _consume(chunk);
  }

  void addSlice(List<int> chunk, int start, int end, bool isLast) {
    if (chunk is Uint8List) {
      _consume(new Uint8List.view(
          chunk.buffer, chunk.offsetInBytes + start, end - start));
    } else {
      _consume(chunk.sublist(start, end - start));
    }
  }

  void close() {}
}

// The _HttpOutgoing handles all of the following:
//  - Buffering
//  - GZip compression
//  - Content-Length validation.
//  - Errors.
//
// Most notable is the GZip compression, that uses a double-buffering system,
// one before gzip (_gzipBuffer) and one after (_buffer).
class _HttpOutgoing implements StreamConsumer<List<int>> {
  static const List<int> _footerAndChunk0Length = const [
    _CharCode.CR,
    _CharCode.LF,
    0x30,
    _CharCode.CR,
    _CharCode.LF,
    _CharCode.CR,
    _CharCode.LF
  ];

  static const List<int> _chunk0Length = const [
    0x30,
    _CharCode.CR,
    _CharCode.LF,
    _CharCode.CR,
    _CharCode.LF
  ];

  final Completer<Socket> _doneCompleter = new Completer<Socket>();
  final Socket socket;

  bool ignoreBody = false;
  bool headersWritten = false;

  Uint8List _buffer;
  int _length = 0;

  Future _closeFuture;

  bool chunked = false;
  int _pendingChunkedFooter = 0;

  int contentLength;
  int _bytesWritten = 0;

  bool _gzip = false;
  ByteConversionSink _gzipSink;
  // _gzipAdd is set iff the sink is being added to. It's used to specify where
  // gzipped data should be taken (sometimes a controller, sometimes a socket).
  _BytesConsumer _gzipAdd;
  Uint8List _gzipBuffer;
  int _gzipBufferLength = 0;

  bool _socketError = false;

  _HttpOutboundMessage outbound;

  _HttpOutgoing(this.socket);

  // Returns either a future or 'null', if it was able to write headers
  // immediately.
  Future writeHeaders({bool drainRequest: true, bool setOutgoing: true}) {
    if (headersWritten) return null;
    headersWritten = true;
    Future drainFuture;
    bool gzip = false;
    if (outbound is _HttpResponse) {
      // Server side.
      _HttpResponse response = outbound;
      if (response._httpRequest._httpServer.autoCompress &&
          outbound.bufferOutput &&
          outbound.headers.chunkedTransferEncoding) {
        List acceptEncodings =
            response._httpRequest.headers[HttpHeaders.acceptEncodingHeader];
        List contentEncoding =
            outbound.headers[HttpHeaders.contentEncodingHeader];
        if (acceptEncodings != null &&
            acceptEncodings
                .expand((list) => list.split(","))
                .any((encoding) => encoding.trim().toLowerCase() == "gzip") &&
            contentEncoding == null) {
          outbound.headers.set(HttpHeaders.contentEncodingHeader, "gzip");
          gzip = true;
        }
      }
      if (drainRequest && !response._httpRequest._incoming.hasSubscriber) {
        drainFuture = response._httpRequest.drain().catchError((_) {});
      }
    } else {
      drainRequest = false;
    }
    if (!ignoreBody) {
      if (setOutgoing) {
        int contentLength = outbound.headers.contentLength;
        if (outbound.headers.chunkedTransferEncoding) {
          chunked = true;
          if (gzip) this.gzip = true;
        } else if (contentLength >= 0) {
          this.contentLength = contentLength;
        }
      }
      if (drainFuture != null) {
        return drainFuture.then((_) => outbound._writeHeader());
      }
    }
    outbound._writeHeader();
    return null;
  }

  Future addStream(Stream<List<int>> stream) {
    if (_socketError) {
      stream.listen(null).cancel();
      return new Future.value(outbound);
    }
    if (ignoreBody) {
      stream.drain().catchError((_) {});
      var future = writeHeaders();
      if (future != null) {
        return future.then((_) => close());
      }
      return close();
    }
    StreamSubscription<List<int>> sub;
    // Use new stream so we are able to pause (see below listen). The
    // alternative is to use stream.extand, but that won't give us a way of
    // pausing.
    var controller = new StreamController<List<int>>(
        onPause: () => sub.pause(), onResume: () => sub.resume(), sync: true);

    void onData(List<int> data) {
      if (_socketError) return;
      if (data.length == 0) return;
      if (chunked) {
        if (_gzip) {
          _gzipAdd = controller.add;
          _addGZipChunk(data, _gzipSink.add);
          _gzipAdd = null;
          return;
        }
        _addChunk(_chunkHeader(data.length), controller.add);
        _pendingChunkedFooter = 2;
      } else {
        if (contentLength != null) {
          _bytesWritten += data.length;
          if (_bytesWritten > contentLength) {
            controller.addError(new HttpException(
                "Content size exceeds specified contentLength. "
                "$_bytesWritten bytes written while expected "
                "$contentLength. "
                "[${new String.fromCharCodes(data)}]"));
            return;
          }
        }
      }
      _addChunk(data, controller.add);
    }

    sub = stream.listen(onData,
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: true);
    // Write headers now that we are listening to the stream.
    if (!headersWritten) {
      var future = writeHeaders();
      if (future != null) {
        // While incoming is being drained, the pauseFuture is non-null. Pause
        // output until it's drained.
        sub.pause(future);
      }
    }
    return socket.addStream(controller.stream).then((_) {
      return outbound;
    }, onError: (error, stackTrace) {
      // Be sure to close it in case of an error.
      if (_gzip) _gzipSink.close();
      _socketError = true;
      _doneCompleter.completeError(error, stackTrace);
      if (_ignoreError(error)) {
        return outbound;
      } else {
        throw error;
      }
    });
  }

  Future close() {
    // If we are already closed, return that future.
    if (_closeFuture != null) return _closeFuture;
    // If we earlier saw an error, return immediate. The notification to
    // _Http*Connection is already done.
    if (_socketError) return new Future.value(outbound);
    if (outbound._isConnectionClosed) return new Future.value(outbound);
    if (!headersWritten && !ignoreBody) {
      if (outbound.headers.contentLength == -1) {
        // If no body was written, ignoreBody is false (it's not a HEAD
        // request) and the content-length is unspecified, set contentLength to
        // 0.
        outbound.headers.chunkedTransferEncoding = false;
        outbound.headers.contentLength = 0;
      } else if (outbound.headers.contentLength > 0) {
        var error = new HttpException(
            "No content even though contentLength was specified to be "
            "greater than 0: ${outbound.headers.contentLength}.",
            uri: outbound._uri);
        _doneCompleter.completeError(error);
        return _closeFuture = new Future.error(error);
      }
    }
    // If contentLength was specified, validate it.
    if (contentLength != null) {
      if (_bytesWritten < contentLength) {
        var error = new HttpException(
            "Content size below specified contentLength. "
            " $_bytesWritten bytes written but expected "
            "$contentLength.",
            uri: outbound._uri);
        _doneCompleter.completeError(error);
        return _closeFuture = new Future.error(error);
      }
    }

    Future finalize() {
      // In case of chunked encoding (and gzip), handle remaining gzip data and
      // append the 'footer' for chunked encoding.
      if (chunked) {
        if (_gzip) {
          _gzipAdd = socket.add;
          if (_gzipBufferLength > 0) {
            _gzipSink.add(new Uint8List.view(_gzipBuffer.buffer,
                _gzipBuffer.offsetInBytes, _gzipBufferLength));
          }
          _gzipBuffer = null;
          _gzipSink.close();
          _gzipAdd = null;
        }
        _addChunk(_chunkHeader(0), socket.add);
      }
      // Add any remaining data in the buffer.
      if (_length > 0) {
        socket.add(
            new Uint8List.view(_buffer.buffer, _buffer.offsetInBytes, _length));
      }
      // Clear references, for better GC.
      _buffer = null;
      // And finally flush it. As we support keep-alive, never close it from
      // here. Once the socket is flushed, we'll be able to reuse it (signaled
      // by the 'done' future).
      return socket.flush().then((_) {
        _doneCompleter.complete(socket);
        return outbound;
      }, onError: (error, stackTrace) {
        _doneCompleter.completeError(error, stackTrace);
        if (_ignoreError(error)) {
          return outbound;
        } else {
          throw error;
        }
      });
    }

    var future = writeHeaders();
    if (future != null) {
      return _closeFuture = future.whenComplete(finalize);
    }
    return _closeFuture = finalize();
  }

  Future<Socket> get done => _doneCompleter.future;

  void setHeader(List<int> data, int length) {
    assert(_length == 0);
    _buffer = data;
    _length = length;
  }

  set gzip(bool value) {
    _gzip = value;
    if (_gzip) {
      _gzipBuffer = new Uint8List(_OUTGOING_BUFFER_SIZE);
      assert(_gzipSink == null);
      _gzipSink = new ZLibEncoder(gzip: true)
          .startChunkedConversion(new _HttpGZipSink((data) {
        // We are closing down prematurely, due to an error. Discard.
        if (_gzipAdd == null) return;
        _addChunk(_chunkHeader(data.length), _gzipAdd);
        _pendingChunkedFooter = 2;
        _addChunk(data, _gzipAdd);
      }));
    }
  }

  bool _ignoreError(error) =>
      (error is SocketException || error is TlsException) &&
      outbound is HttpResponse;

  void _addGZipChunk(List<int> chunk, void add(List<int> data)) {
    if (!outbound.bufferOutput) {
      add(chunk);
      return;
    }
    if (chunk.length > _gzipBuffer.length - _gzipBufferLength) {
      add(new Uint8List.view(
          _gzipBuffer.buffer, _gzipBuffer.offsetInBytes, _gzipBufferLength));
      _gzipBuffer = new Uint8List(_OUTGOING_BUFFER_SIZE);
      _gzipBufferLength = 0;
    }
    if (chunk.length > _OUTGOING_BUFFER_SIZE) {
      add(chunk);
    } else {
      _gzipBuffer.setRange(
          _gzipBufferLength, _gzipBufferLength + chunk.length, chunk);
      _gzipBufferLength += chunk.length;
    }
  }

  void _addChunk(List<int> chunk, void add(List<int> data)) {
    if (!outbound.bufferOutput) {
      if (_buffer != null) {
        // If _buffer is not null, we have not written the header yet. Write
        // it now.
        add(new Uint8List.view(_buffer.buffer, _buffer.offsetInBytes, _length));
        _buffer = null;
        _length = 0;
      }
      add(chunk);
      return;
    }
    if (chunk.length > _buffer.length - _length) {
      add(new Uint8List.view(_buffer.buffer, _buffer.offsetInBytes, _length));
      _buffer = new Uint8List(_OUTGOING_BUFFER_SIZE);
      _length = 0;
    }
    if (chunk.length > _OUTGOING_BUFFER_SIZE) {
      add(chunk);
    } else {
      _buffer.setRange(_length, _length + chunk.length, chunk);
      _length += chunk.length;
    }
  }

  List<int> _chunkHeader(int length) {
    const hexDigits = const [
      0x30,
      0x31,
      0x32,
      0x33,
      0x34,
      0x35,
      0x36,
      0x37,
      0x38,
      0x39,
      0x41,
      0x42,
      0x43,
      0x44,
      0x45,
      0x46
    ];
    if (length == 0) {
      if (_pendingChunkedFooter == 2) return _footerAndChunk0Length;
      return _chunk0Length;
    }
    int size = _pendingChunkedFooter;
    int len = length;
    // Compute a fast integer version of (log(length + 1) / log(16)).ceil().
    while (len > 0) {
      size++;
      len >>= 4;
    }
    var footerAndHeader = new Uint8List(size + 2);
    if (_pendingChunkedFooter == 2) {
      footerAndHeader[0] = _CharCode.CR;
      footerAndHeader[1] = _CharCode.LF;
    }
    int index = size;
    while (index > _pendingChunkedFooter) {
      footerAndHeader[--index] = hexDigits[length & 15];
      length = length >> 4;
    }
    footerAndHeader[size + 0] = _CharCode.CR;
    footerAndHeader[size + 1] = _CharCode.LF;
    return footerAndHeader;
  }
}

class _HttpClientConnection {
  final String key;
  final Socket _socket;
  final bool _proxyTunnel;
  final SecurityContext _context;
  final _HttpParser _httpParser;
  StreamSubscription _subscription;
  final _HttpClient _httpClient;
  bool _dispose = false;
  Timer _idleTimer;
  bool closed = false;
  Uri _currentUri;

  Completer<_HttpIncoming> _nextResponseCompleter;
  Future<Socket> _streamFuture;

  _HttpClientConnection(this.key, this._socket, this._httpClient,
      [this._proxyTunnel = false, this._context])
      : _httpParser = new _HttpParser.responseParser() {
    _httpParser.listenToStream(_socket);

    // Set up handlers on the parser here, so we are sure to get 'onDone' from
    // the parser.
    _subscription = _httpParser.listen((incoming) {
      // Only handle one incoming response at the time. Keep the
      // stream paused until the response have been processed.
      _subscription.pause();
      // We assume the response is not here, until we have send the request.
      if (_nextResponseCompleter == null) {
        throw new HttpException(
            "Unexpected response (unsolicited response without request).",
            uri: _currentUri);
      }

      // Check for status code '100 Continue'. In that case just
      // consume that response as the final response will follow
      // it. There is currently no API for the client to wait for
      // the '100 Continue' response.
      // ! custom changes
      if (incoming?.statusCode == 100) {
        incoming.drain().then((_) {
          _subscription.resume();
        }).catchError((error, [StackTrace stackTrace]) {
          _nextResponseCompleter.completeError(
              new HttpException(error.message, uri: _currentUri), stackTrace);
          _nextResponseCompleter = null;
        });
      } else {
        // ! custom changes
        if (incoming == null) {
          _subscription.resume();
        }
        _nextResponseCompleter.complete(incoming);
        _nextResponseCompleter = null;
      }
    }, onError: (error, [StackTrace stackTrace]) {
      if (_nextResponseCompleter != null) {
        _nextResponseCompleter.completeError(
            new HttpException(error.message, uri: _currentUri), stackTrace);
        _nextResponseCompleter = null;
      }
    }, onDone: () {
      if (_nextResponseCompleter != null) {
        _nextResponseCompleter.completeError(new HttpException(
            "Connection closed before response was received",
            uri: _currentUri));
        _nextResponseCompleter = null;
      }
      close();
    });
  }

  _HttpClientRequest send(
      Uri uri, int port, String method, _Proxy proxy, TimelineTask timeline) {
    if (closed) {
      throw new HttpException("Socket closed before request was sent",
          uri: uri);
    }
    _currentUri = uri;
    // Start with pausing the parser.
    _subscription.pause();
    if (method == "CONNECT") {
      // Parser will ignore Content-Length or Transfer-Encoding header
      _httpParser.connectMethod = true;
    }
    _ProxyCredentials proxyCreds; // Credentials used to authorize proxy.
    _SiteCredentials creds; // Credentials used to authorize this request.
    var outgoing = new _HttpOutgoing(_socket);
    // Create new request object, wrapping the outgoing connection.
    var request = new _HttpClientRequest(
        outgoing, uri, method, proxy, _httpClient, this, timeline);
    // For the Host header an IPv6 address must be enclosed in []'s.
    var host = uri.host;
    if (host.contains(':')) host = "[$host]";
    request.headers
      ..host = host
      ..port = port
      ..add(HttpHeaders.acceptEncodingHeader, "gzip");
    if (_httpClient.userAgent != null) {
      request.headers.add(HttpHeaders.userAgentHeader, _httpClient.userAgent);
    }
    if (proxy.isAuthenticated) {
      // If the proxy configuration contains user information use that
      // for proxy basic authorization.
      String auth = _CryptoUtils.bytesToBase64(
          utf8.encode("${proxy.username}:${proxy.password}"));
      request.headers.set(HttpHeaders.proxyAuthorizationHeader, "Basic $auth");
    } else if (!proxy.isDirect && _httpClient._proxyCredentials.length > 0) {
      proxyCreds = _httpClient._findProxyCredentials(proxy);
      if (proxyCreds != null) {
        proxyCreds.authorize(request);
      }
    }
    if (uri.userInfo != null && !uri.userInfo.isEmpty) {
      // If the URL contains user information use that for basic
      // authorization.
      String auth = _CryptoUtils.bytesToBase64(utf8.encode(uri.userInfo));
      request.headers.set(HttpHeaders.authorizationHeader, "Basic $auth");
    } else {
      // Look for credentials.
      creds = _httpClient._findCredentials(uri);
      if (creds != null) {
        creds.authorize(request);
      }
    }

    // Start sending the request (lazy, delayed until the user provides
    // data).
    _httpParser.isHead = method == "HEAD";
    _streamFuture = outgoing.done.then<Socket>((Socket s) {
      // Request sent, set up response completer.
      _nextResponseCompleter = new Completer<_HttpIncoming>();

      // Listen for response.
      _nextResponseCompleter.future.then((incoming) {
        _currentUri = null;
        incoming.dataDone.then((closing) {
          if (incoming.upgraded) {
            _httpClient._connectionClosed(this);
            startTimer();
            return;
          }
          if (closed) return;
          if (!closing &&
              !_dispose &&
              incoming.headers.persistentConnection &&
              request.persistentConnection) {
            // Return connection, now we are done.
            _httpClient._returnConnection(this);
            _subscription.resume();
          } else {
            destroy();
          }
        });
        // For digest authentication if proxy check if the proxy
        // requests the client to start using a new nonce for proxy
        // authentication.
        if (proxyCreds != null &&
            proxyCreds.scheme == _AuthenticationScheme.DIGEST) {
          var authInfo = incoming.headers["proxy-authentication-info"];
          if (authInfo != null && authInfo.length == 1) {
            var header =
                _HeaderValue.parse(authInfo[0], parameterSeparator: ',');
            var nextnonce = header.parameters["nextnonce"];
            if (nextnonce != null) proxyCreds.nonce = nextnonce;
          }
        }
        // For digest authentication check if the server requests the
        // client to start using a new nonce.
        if (creds != null && creds.scheme == _AuthenticationScheme.DIGEST) {
          var authInfo = incoming.headers["authentication-info"];
          if (authInfo != null && authInfo.length == 1) {
            var header =
                _HeaderValue.parse(authInfo[0], parameterSeparator: ',');
            var nextnonce = header.parameters["nextnonce"];
            if (nextnonce != null) creds.nonce = nextnonce;
          }
        }
        request._onIncoming(incoming);
      })
          // If we see a state error, we failed to get the 'first'
          // element.
          .catchError((error) {
        throw new HttpException("Connection closed before data was received",
            uri: uri);
      }, test: (error) => error is StateError).catchError((error, stackTrace) {
        // We are done with the socket.
        destroy();
        request._onError(error, stackTrace);
      });

      // Resume the parser now we have a handler.
      _subscription.resume();
      return s;
    }, onError: (e) {
      destroy();
    });
    return request;
  }

  Future<Socket> detachSocket() {
    return _streamFuture.then(
        (_) => new _DetachedSocket(_socket, _httpParser.detachIncoming()));
  }

  void destroy() {
    closed = true;
    _httpClient._connectionClosed(this);
    _socket.destroy();
  }

  void close() {
    closed = true;
    _httpClient._connectionClosed(this);
    // ! custom changes
    if (_streamFuture != null) {
      _streamFuture
          .timeout(_httpClient.idleTimeout)
          .then((_) => _socket.destroy());
    } else {
      _socket.destroy();
    }
  }

  Future<_HttpClientConnection> createProxyTunnel(
      // ! custom changes
      String host,
      int port,
      _Proxy proxy,
      bool callback(X509Certificate certificate),
      TimelineTask timeline) async {
    timeline?.instant('Establishing proxy tunnel', arguments: {
      'proxyInfo': {
        if (proxy.host != null) 'host': proxy.host,
        if (proxy.port != null)
          'port': proxy.port,
        if (proxy.username != null)
          'username': proxy.username,
        // TODO(bkonyi): is this something we would want to surface? Initial
        // thought is no.
        // if (proxy.password != null)
        //   'password': proxy.password,
        'isDirect': proxy.isDirect,
        'isSocks4a': proxy.isSocks4a,
      }
    });

    if (proxy.isSocks4a) {
      var uriPortBytes = [(port >> 8) & 0xFF, port & 0xFF];
      var uriAuthorityAscii = ascii.encode(host);

      _socket.add([
        0x04, // SOCKS version
        0x01, // request establish a TCP/IP stream connection
        ...uriPortBytes, // 2 bytes destination port
        0x00, // 4 bytes of destination ip
        0x00, // if socks4a and destination ip equals 0.0.0.NonZero
        0x00, // then we can pass destination domen after first 0x00 byte
        0x01,
        0x00,
        ...uriAuthorityAscii, // destination domen
        0x00,
      ]);

      _nextResponseCompleter = new Completer<_HttpIncoming>();

      return _nextResponseCompleter.future.then<SecureSocket>((_) {
        return SecureSocket.secure(
          _socket,
          host: host,
          context: _context,
          onBadCertificate: callback,
        );
      }).then<_HttpClientConnection>((socket) {
        String key = _HttpClientConnection.makeKey(true, host, port);
        timeline?.instant('Proxy tunnel established');
        return new _HttpClientConnection(key, socket, _httpClient, true);
      });
    }

    final method = "CONNECT";
    final uri = Uri(host: host, port: port);
    _HttpClient._startRequestTimelineEvent(timeline, method, uri);
    _HttpClientRequest request =
        send(Uri(host: host, port: port), port, method, proxy, timeline);
    if (proxy.isAuthenticated) {
      // If the proxy configuration contains user information use that
      // for proxy basic authorization.
      String auth = _CryptoUtils.bytesToBase64(
          utf8.encode("${proxy.username}:${proxy.password}"));
      request.headers.set(HttpHeaders.proxyAuthorizationHeader, "Basic $auth");
    }
    return request.close().then((response) {
      if (response.statusCode != HttpStatus.ok) {
        final error = "Proxy failed to establish tunnel "
            "(${response.statusCode} ${response.reasonPhrase})";
        timeline?.instant(error);
        throw new HttpException(error, uri: request.uri);
      }
      var socket = (response as _HttpClientResponse)
          ._httpRequest
          ._httpClientConnection
          ._socket;
      return SecureSocket.secure(socket,
          host: host, context: _context, onBadCertificate: callback);
    }).then((secureSocket) {
      String key = _HttpClientConnection.makeKey(true, host, port);
      timeline?.instant('Proxy tunnel established');
      return new _HttpClientConnection(
        key,
        secureSocket,
        request._httpClient,
        true,
      );
    });
  }

  HttpConnectionInfo get connectionInfo => _HttpConnectionInfo.create(_socket);

  static makeKey(bool isSecure, String host, int port) {
    return isSecure ? "ssh:$host:$port" : "$host:$port";
  }

  void stopTimer() {
    if (_idleTimer != null) {
      _idleTimer.cancel();
      _idleTimer = null;
    }
  }

  void startTimer() {
    assert(_idleTimer == null);
    _idleTimer = new Timer(_httpClient.idleTimeout, () {
      _idleTimer = null;
      close();
    });
  }
}

class _ConnectionInfo {
  final _HttpClientConnection connection;
  final _Proxy proxy;

  _ConnectionInfo(this.connection, this.proxy);
}

class _ConnectionTarget {
  // Unique key for this connection target.
  final String key;
  final String host;
  final int port;
  final bool isSecure;
  final SecurityContext context;
  final Set<_HttpClientConnection> _idle = new HashSet();
  final Set<_HttpClientConnection> _active = new HashSet();
  final Set<ConnectionTask> _socketTasks = new HashSet();
  final Queue _pending = new ListQueue();
  int _connecting = 0;

  _ConnectionTarget(
      this.key, this.host, this.port, this.isSecure, this.context);

  bool get isEmpty => _idle.isEmpty && _active.isEmpty && _connecting == 0;

  bool get hasIdle => _idle.isNotEmpty;

  bool get hasActive => _active.isNotEmpty || _connecting > 0;

  _HttpClientConnection takeIdle() {
    assert(hasIdle);
    _HttpClientConnection connection = _idle.first;
    _idle.remove(connection);
    connection.stopTimer();
    _active.add(connection);
    return connection;
  }

  _checkPending() {
    if (_pending.isNotEmpty) {
      _pending.removeFirst()();
    }
  }

  void addNewActive(_HttpClientConnection connection) {
    _active.add(connection);
  }

  void returnConnection(_HttpClientConnection connection) {
    assert(_active.contains(connection));
    _active.remove(connection);
    _idle.add(connection);
    connection.startTimer();
    _checkPending();
  }

  void connectionClosed(_HttpClientConnection connection) {
    assert(!_active.contains(connection) || !_idle.contains(connection));
    _active.remove(connection);
    _idle.remove(connection);
    _checkPending();
  }

  void close(bool force) {
    // Always cancel pending socket connections.
    for (var t in _socketTasks.toList()) {
      // Make sure the socket is destroyed if the ConnectionTask is cancelled.
      t.socket.then((s) {
        s.destroy();
      }, onError: (e) {});
      t.cancel();
    }
    if (force) {
      for (var c in _idle.toList()) {
        c.destroy();
      }
      for (var c in _active.toList()) {
        c.destroy();
      }
    } else {
      for (var c in _idle.toList()) {
        c.close();
      }
    }
  }

  Future<_ConnectionInfo> connect(String uriHost, int uriPort, _Proxy proxy,
      _HttpClient client, TimelineTask timeline) {
    if (hasIdle) {
      var connection = takeIdle();
      client._connectionsChanged();
      return new Future.value(new _ConnectionInfo(connection, proxy));
    }
    if (client.maxConnectionsPerHost != null &&
        _active.length + _connecting >= client.maxConnectionsPerHost) {
      var completer = new Completer<_ConnectionInfo>();
      _pending.add(() {
        completer.complete(connect(uriHost, uriPort, proxy, client, timeline));
      });
      return completer.future;
    }
    var currentBadCertificateCallback = client._badCertificateCallback;

    bool callback(X509Certificate certificate) {
      if (currentBadCertificateCallback == null) return false;
      return currentBadCertificateCallback(certificate, uriHost, uriPort);
    }

    Future<ConnectionTask> connectionTask = (isSecure && proxy.isDirect
        ? SecureSocket.startConnect(host, port,
            context: context, onBadCertificate: callback)
        : Socket.startConnect(host, port));
    _connecting++;
    return connectionTask.then((ConnectionTask task) {
      _socketTasks.add(task);
      Future socketFuture = task.socket;
      final Duration connectionTimeout = client.connectionTimeout;
      if (connectionTimeout != null) {
        socketFuture = socketFuture.timeout(connectionTimeout, onTimeout: () {
          _socketTasks.remove(task);
          task.cancel();
          return null;
        });
      }
      return socketFuture.then((socket) {
        // When there is a timeout, there is a race in which the connectionTask
        // Future won't be completed with an error before the socketFuture here
        // is completed with 'null' by the onTimeout callback above. In this
        // case, propagate a SocketException as specified by the
        // HttpClient.connectionTimeout docs.
        if (socket == null) {
          assert(connectionTimeout != null);
          throw new SocketException(
              "HTTP connection timed out after ${connectionTimeout}, "
              "host: ${host}, port: ${port}");
        }
        _connecting--;
        socket.setOption(SocketOption.tcpNoDelay, true);
        var connection =
            new _HttpClientConnection(key, socket, client, false, context);
        if (isSecure && !proxy.isDirect) {
          connection._dispose = true;
          return connection
              .createProxyTunnel(uriHost, uriPort, proxy, callback, timeline)
              .then((tunnel) {
            client
                ._getConnectionTarget(uriHost, uriPort, isSecure)
                .addNewActive(tunnel);
            _socketTasks.remove(task);
            return new _ConnectionInfo(tunnel, proxy);
          });
        } else {
          if (!proxy.isDirect && proxy.isSocks4a) {
            // ! custom changes
            var uriPortBytes = [(uriPort >> 8) & 0xFF, uriPort & 0xFF];
            var uriAuthorityAscii = ascii.encode(uriHost);

            socket.add([
              0x04, // SOCKS version
              0x01, // request establish a TCP/IP stream connection
              ...uriPortBytes, // 2 bytes destination port
              0x00, // 4 bytes of destination ip
              0x00, // if socks4a and destination ip equals 0.0.0.NonZero
              0x00, // then we can pass destination domen after first 0x00 byte
              0x01,
              0x00,
              ...uriAuthorityAscii, // destination domen
              0x00,
            ]);
            connection._nextResponseCompleter = new Completer<_HttpIncoming>();

            return connection._nextResponseCompleter.future
                .then<_ConnectionInfo>((_) {
              addNewActive(connection);
              _socketTasks.remove(task);
              return new _ConnectionInfo(connection, proxy);
            });
          }
          addNewActive(connection);
          _socketTasks.remove(task);
          return new _ConnectionInfo(connection, proxy);
        }
      }, onError: (error) {
        _connecting--;
        _socketTasks.remove(task);
        _checkPending();
        throw error;
      });
    });
  }
}

typedef bool BadCertificateCallback(X509Certificate cr, String host, int port);

class _HttpClient implements HttpClient {
  bool _closing = false;
  bool _closingForcefully = false;
  final Map<String, _ConnectionTarget> _connectionTargets =
      new HashMap<String, _ConnectionTarget>();
  final List<_Credentials> _credentials = [];
  final List<_ProxyCredentials> _proxyCredentials = [];
  final SecurityContext _context;
  Function _authenticate;
  Function _authenticateProxy;
  Function _findProxy = HttpClient.findProxyFromEnvironment;
  Duration _idleTimeout = const Duration(seconds: 15);
  BadCertificateCallback _badCertificateCallback;

  Duration get idleTimeout => _idleTimeout;

  Duration connectionTimeout;

  int maxConnectionsPerHost;

  bool autoUncompress = true;

  String userAgent = _getHttpVersion();

  _HttpClient(this._context);

  set idleTimeout(Duration timeout) {
    _idleTimeout = timeout;
    for (var c in _connectionTargets.values) {
      for (var idle in c._idle) {
        // Reset timer. This is fine, as it's not happening often.
        idle.stopTimer();
        idle.startTimer();
      }
    }
  }

  set badCertificateCallback(
      bool callback(X509Certificate cert, String host, int port)) {
    _badCertificateCallback = callback;
  }

  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    const int hashMark = 0x23;
    const int questionMark = 0x3f;
    int fragmentStart = path.length;
    int queryStart = path.length;
    for (int i = path.length - 1; i >= 0; i--) {
      var char = path.codeUnitAt(i);
      if (char == hashMark) {
        fragmentStart = i;
        queryStart = i;
      } else if (char == questionMark) {
        queryStart = i;
      }
    }
    String query = null;
    if (queryStart < fragmentStart) {
      query = path.substring(queryStart + 1, fragmentStart);
      path = path.substring(0, queryStart);
    }
    Uri uri = new Uri(
        scheme: "http", host: host, port: port, path: path, query: query);
    return _openUrl(method, uri);
  }

  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _openUrl(method, url);

  Future<HttpClientRequest> get(String host, int port, String path) =>
      open("get", host, port, path);

  Future<HttpClientRequest> getUrl(Uri url) => _openUrl("get", url);

  Future<HttpClientRequest> post(String host, int port, String path) =>
      open("post", host, port, path);

  Future<HttpClientRequest> postUrl(Uri url) => _openUrl("post", url);

  Future<HttpClientRequest> put(String host, int port, String path) =>
      open("put", host, port, path);

  Future<HttpClientRequest> putUrl(Uri url) => _openUrl("put", url);

  Future<HttpClientRequest> delete(String host, int port, String path) =>
      open("delete", host, port, path);

  Future<HttpClientRequest> deleteUrl(Uri url) => _openUrl("delete", url);

  Future<HttpClientRequest> head(String host, int port, String path) =>
      open("head", host, port, path);

  Future<HttpClientRequest> headUrl(Uri url) => _openUrl("head", url);

  Future<HttpClientRequest> patch(String host, int port, String path) =>
      open("patch", host, port, path);

  Future<HttpClientRequest> patchUrl(Uri url) => _openUrl("patch", url);

  void close({bool force: false}) {
    _closing = true;
    _closingForcefully = force;
    _closeConnections(_closingForcefully);
    assert(!_connectionTargets.values.any((s) => s.hasIdle));
    assert(
        !force || !_connectionTargets.values.any((s) => s._active.isNotEmpty));
  }

  set authenticate(Future<bool> f(Uri url, String scheme, String realm)) {
    _authenticate = f;
  }

  void addCredentials(Uri url, String realm, HttpClientCredentials cr) {
    _credentials.add(new _SiteCredentials(url, realm, cr));
  }

  set authenticateProxy(
      Future<bool> f(String host, int port, String scheme, String realm)) {
    _authenticateProxy = f;
  }

  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials cr) {
    _proxyCredentials.add(new _ProxyCredentials(host, port, realm, cr));
  }

  set findProxy(String f(Uri uri)) => _findProxy = f;

  static void _startRequestTimelineEvent(
      TimelineTask timeline, String method, Uri uri) {
    timeline?.start('HTTP CLIENT ${method.toUpperCase()}', arguments: {
      'method': method.toUpperCase(),
      'uri': uri.toString(),
    });
  }

  Future<_HttpClientRequest> _openUrl(String method, Uri uri) {
    if (_closing) {
      throw new StateError("Client is closed");
    }

    // Ignore any fragments on the request URI.
    uri = uri.removeFragment();

    if (method == null) {
      throw new ArgumentError(method);
    }
    if (method != "CONNECT") {
      if (uri.host.isEmpty) {
        throw new ArgumentError("No host specified in URI $uri");
      } else if (uri.scheme != "http" && uri.scheme != "https") {
        throw new ArgumentError(
            "Unsupported scheme '${uri.scheme}' in URI $uri");
      }
    }

    bool isSecure = (uri.scheme == "https");
    int port = uri.port;
    if (port == 0) {
      port =
          isSecure ? HttpClient.defaultHttpsPort : HttpClient.defaultHttpPort;
    }
    // Check to see if a proxy server should be used for this connection.
    var proxyConf = const _ProxyConfiguration.direct();
    if (_findProxy != null) {
      // TODO(sgjesse): Keep a map of these as normally only a few
      // configuration strings will be used.
      try {
        proxyConf = new _ProxyConfiguration(_findProxy(uri));
      } catch (error, stackTrace) {
        return new Future.error(error, stackTrace);
      }
    }
    TimelineTask timeline;
    // TODO(bkonyi): do we want this to be opt-in?
    if (HttpClient.enableTimelineLogging) {
      timeline = TimelineTask(filterKey: 'HTTP/client');
      _startRequestTimelineEvent(timeline, method, uri);
    }
    return _getConnection(uri.host, port, proxyConf, isSecure, timeline).then(
        (_ConnectionInfo info) {
      _HttpClientRequest send(_ConnectionInfo info) {
        timeline?.instant('Connection established');
        return info.connection
            .send(uri, port, method.toUpperCase(), info.proxy, timeline);
      }

      // If the connection was closed before the request was sent, create
      // and use another connection.
      if (info.connection.closed) {
        return _getConnection(uri.host, port, proxyConf, isSecure, timeline)
            .then(send);
      }
      return send(info);
    }, onError: (error) {
      timeline?.finish(arguments: {
        'error': error.toString(),
      });
      throw error;
    });
  }

  Future<_HttpClientRequest> _openUrlFromRequest(
      String method, Uri uri, _HttpClientRequest previous) {
    // If the new URI is relative (to either '/' or some sub-path),
    // construct a full URI from the previous one.
    Uri resolved = previous.uri.resolveUri(uri);
    return _openUrl(method, resolved).then((_HttpClientRequest request) {
      request
        // Only follow redirects if initial request did.
        ..followRedirects = previous.followRedirects
        // Allow same number of redirects.
        ..maxRedirects = previous.maxRedirects;
      // Copy headers.
      for (var header in previous.headers._headers.keys) {
        if (request.headers[header] == null) {
          request.headers.set(header, previous.headers[header]);
        }
      }
      return request
        ..headers.chunkedTransferEncoding = false
        ..contentLength = 0;
    });
  }

  // Return a live connection to the idle pool.
  void _returnConnection(_HttpClientConnection connection) {
    _connectionTargets[connection.key].returnConnection(connection);
    _connectionsChanged();
  }

  // Remove a closed connection from the active set.
  void _connectionClosed(_HttpClientConnection connection) {
    connection.stopTimer();
    var connectionTarget = _connectionTargets[connection.key];
    if (connectionTarget != null) {
      connectionTarget.connectionClosed(connection);
      if (connectionTarget.isEmpty) {
        _connectionTargets.remove(connection.key);
      }
      _connectionsChanged();
    }
  }

  void _connectionsChanged() {
    if (_closing) {
      _closeConnections(_closingForcefully);
    }
  }

  void _closeConnections(bool force) {
    for (var connectionTarget in _connectionTargets.values.toList()) {
      connectionTarget.close(force);
    }
  }

  _ConnectionTarget _getConnectionTarget(String host, int port, bool isSecure) {
    String key = _HttpClientConnection.makeKey(isSecure, host, port);
    return _connectionTargets.putIfAbsent(key, () {
      return new _ConnectionTarget(key, host, port, isSecure, _context);
    });
  }

  // Get a new _HttpClientConnection, from the matching _ConnectionTarget.
  Future<_ConnectionInfo> _getConnection(String uriHost, int uriPort,
      _ProxyConfiguration proxyConf, bool isSecure, TimelineTask timeline) {
    Iterator<_Proxy> proxies = proxyConf.proxies.iterator;

    Future<_ConnectionInfo> connect(error) {
      if (!proxies.moveNext()) return new Future.error(error);
      _Proxy proxy = proxies.current;
      String host = proxy.isDirect ? uriHost : proxy.host;
      int port = proxy.isDirect ? uriPort : proxy.port;
      return _getConnectionTarget(host, port, isSecure)
          .connect(uriHost, uriPort, proxy, this, timeline)
          // On error, continue with next proxy.
          .catchError(connect);
    }

    return connect(new HttpException("No proxies given"));
  }

  _SiteCredentials _findCredentials(Uri url, [_AuthenticationScheme scheme]) {
    // Look for credentials.
    _SiteCredentials cr =
        _credentials.fold(null, (_SiteCredentials prev, value) {
      var siteCredentials = value as _SiteCredentials;
      if (siteCredentials.applies(url, scheme)) {
        if (prev == null) return value;
        return siteCredentials.uri.path.length > prev.uri.path.length
            ? siteCredentials
            : prev;
      } else {
        return prev;
      }
    });
    return cr;
  }

  _ProxyCredentials _findProxyCredentials(_Proxy proxy,
      [_AuthenticationScheme scheme]) {
    // Look for credentials.
    var it = _proxyCredentials.iterator;
    while (it.moveNext()) {
      if (it.current.applies(proxy, scheme)) {
        return it.current;
      }
    }
    return null;
  }

  void _removeCredentials(_Credentials cr) {
    int index = _credentials.indexOf(cr);
    if (index != -1) {
      _credentials.removeAt(index);
    }
  }

  void _removeProxyCredentials(_Credentials cr) {
    int index = _proxyCredentials.indexOf(cr);
    if (index != -1) {
      _proxyCredentials.removeAt(index);
    }
  }

  static String _findProxyFromEnvironment(
      Uri url, Map<String, String> environment) {
    checkNoProxy(String option) {
      if (option == null) return null;
      Iterator<String> names = option.split(",").map((s) => s.trim()).iterator;
      while (names.moveNext()) {
        var name = names.current;
        if ((name.startsWith("[") &&
                name.endsWith("]") &&
                "[${url.host}]" == name) ||
            (name.isNotEmpty && url.host.endsWith(name))) {
          return "DIRECT";
        }
      }
      return null;
    }

    checkProxy(String option) {
      if (option == null) return null;
      option = option.trim();
      if (option.isEmpty) return null;
      int pos = option.indexOf("://");
      if (pos >= 0) {
        option = option.substring(pos + 3);
      }
      pos = option.indexOf("/");
      if (pos >= 0) {
        option = option.substring(0, pos);
      }
      // Add default port if no port configured.
      if (option.indexOf("[") == 0) {
        var pos = option.lastIndexOf(":");
        if (option.indexOf("]") > pos) option = "$option:1080";
      } else {
        if (option.indexOf(":") == -1) option = "$option:1080";
      }
      return "PROXY $option";
    }

    // Default to using the process current environment.
    if (environment == null) environment = _platformEnvironmentCache;

    String proxyCfg;

    String noProxy = environment["no_proxy"];
    if (noProxy == null) noProxy = environment["NO_PROXY"];
    if ((proxyCfg = checkNoProxy(noProxy)) != null) {
      return proxyCfg;
    }

    if (url.scheme == "http") {
      String proxy = environment["http_proxy"];
      if (proxy == null) proxy = environment["HTTP_PROXY"];
      if ((proxyCfg = checkProxy(proxy)) != null) {
        return proxyCfg;
      }
    } else if (url.scheme == "https") {
      String proxy = environment["https_proxy"];
      if (proxy == null) proxy = environment["HTTPS_PROXY"];
      if ((proxyCfg = checkProxy(proxy)) != null) {
        return proxyCfg;
      }
    }
    return "DIRECT";
  }

  static Map<String, String> _platformEnvironmentCache = Platform.environment;
}

class _HttpConnection extends LinkedListEntry<_HttpConnection>
    with _ServiceObject {
  static const _ACTIVE = 0;
  static const _IDLE = 1;
  static const _CLOSING = 2;
  static const _DETACHED = 3;

  // Use HashMap, as we don't need to keep order.
  static Map<int, _HttpConnection> _connections =
      new HashMap<int, _HttpConnection>();

  final /*_ServerSocket*/ _socket;
  final _HttpServer _httpServer;
  final _HttpParser _httpParser;
  int _state = _IDLE;
  StreamSubscription _subscription;
  bool _idleMark = false;
  Future _streamFuture;

  _HttpConnection(this._socket, this._httpServer)
      : _httpParser = new _HttpParser.requestParser() {
    _connections[_serviceId] = this;
    _httpParser.listenToStream(_socket);
    _subscription = _httpParser.listen((incoming) {
      _httpServer._markActive(this);
      // If the incoming was closed, close the connection.
      incoming.dataDone.then((closing) {
        if (closing) destroy();
      });
      // Only handle one incoming request at the time. Keep the
      // stream paused until the request has been send.
      _subscription.pause();
      _state = _ACTIVE;
      var outgoing = new _HttpOutgoing(_socket);
      var response = new _HttpResponse(
          incoming.uri,
          incoming.headers.protocolVersion,
          outgoing,
          _httpServer.defaultResponseHeaders,
          _httpServer.serverHeader);
      // Parser found badRequest and sent out Response.
      if (incoming.statusCode == HttpStatus.badRequest) {
        response.statusCode = HttpStatus.badRequest;
      }
      var request = new _HttpRequest(response, incoming, _httpServer, this);
      _streamFuture = outgoing.done.then((_) {
        response.deadline = null;
        if (_state == _DETACHED) return;
        if (response.persistentConnection &&
            request.persistentConnection &&
            incoming.fullBodyRead &&
            !_httpParser.upgrade &&
            !_httpServer.closed) {
          _state = _IDLE;
          _idleMark = false;
          _httpServer._markIdle(this);
          // Resume the subscription for incoming requests as the
          // request is now processed.
          _subscription.resume();
        } else {
          // Close socket, keep-alive not used or body sent before
          // received data was handled.
          destroy();
        }
      }, onError: (_) {
        destroy();
      });
      outgoing.ignoreBody = request.method == "HEAD";
      response._httpRequest = request;
      _httpServer._handleRequest(request);
    }, onDone: () {
      destroy();
    }, onError: (error) {
      // Ignore failed requests that was closed before headers was received.
      destroy();
    });
  }

  void markIdle() {
    _idleMark = true;
  }

  bool get isMarkedIdle => _idleMark;

  void destroy() {
    if (_state == _CLOSING || _state == _DETACHED) return;
    _state = _CLOSING;
    _socket.destroy();
    _httpServer._connectionClosed(this);
    _connections.remove(_serviceId);
  }

  Future<Socket> detachSocket() {
    _state = _DETACHED;
    // Remove connection from server.
    _httpServer._connectionClosed(this);

    _HttpDetachedIncoming detachedIncoming = _httpParser.detachIncoming();

    return _streamFuture.then((_) {
      _connections.remove(_serviceId);
      return new _DetachedSocket(_socket, detachedIncoming);
    });
  }

  HttpConnectionInfo get connectionInfo => _HttpConnectionInfo.create(_socket);

  bool get _isActive => _state == _ACTIVE;
  bool get _isIdle => _state == _IDLE;
  bool get _isClosing => _state == _CLOSING;

  String get _serviceTypePath => 'io/http/serverconnections';
  String get _serviceTypeName => 'HttpServerConnection';

  Map _toJSON(bool ref) {
    var name = "${_socket.address.host}:${_socket.port} <-> "
        "${_socket.remoteAddress.host}:${_socket.remotePort}";
    var r = <String, dynamic>{
      'id': _servicePath,
      'type': _serviceType(ref),
      'name': name,
      'user_name': name,
    };
    if (ref) {
      return r;
    }
    r['server'] = _httpServer._toJSON(true);
    try {
      r['socket'] = _socket._toJSON(true);
    } catch (_) {
      r['socket'] = {
        'id': _servicePath,
        'type': '@Socket',
        'name': 'UserSocket',
        'user_name': 'UserSocket',
      };
    }
    switch (_state) {
      case _ACTIVE:
        r['state'] = "Active";
        break;
      case _IDLE:
        r['state'] = "Idle";
        break;
      case _CLOSING:
        r['state'] = "Closing";
        break;
      case _DETACHED:
        r['state'] = "Detached";
        break;
      default:
        r['state'] = 'Unknown';
        break;
    }
    return r;
  }
}

// HTTP server waiting for socket connections.
class _HttpServer extends Stream<HttpRequest>
    with _ServiceObject
    implements HttpServer {
  // Use default Map so we keep order.
  static Map<int, _HttpServer> _servers = new Map<int, _HttpServer>();

  String serverHeader;
  final HttpHeaders defaultResponseHeaders = _initDefaultResponseHeaders();
  bool autoCompress = false;

  Duration _idleTimeout;
  Timer _idleTimer;

  static Future<HttpServer> bind(
      address, int port, int backlog, bool v6Only, bool shared) {
    return ServerSocket.bind(address, port,
            backlog: backlog, v6Only: v6Only, shared: shared)
        .then<HttpServer>((socket) {
      return new _HttpServer._(socket, true);
    });
  }

  static Future<HttpServer> bindSecure(
      address,
      int port,
      SecurityContext context,
      int backlog,
      bool v6Only,
      bool requestClientCertificate,
      bool shared) {
    return SecureServerSocket.bind(address, port, context,
            backlog: backlog,
            v6Only: v6Only,
            requestClientCertificate: requestClientCertificate,
            shared: shared)
        .then<HttpServer>((socket) {
      return new _HttpServer._(socket, true);
    });
  }

  _HttpServer._(this._serverSocket, this._closeServer) {
    _controller =
        new StreamController<HttpRequest>(sync: true, onCancel: close);
    idleTimeout = const Duration(seconds: 120);
    _servers[_serviceId] = this;
  }

  _HttpServer.listenOn(this._serverSocket) : _closeServer = false {
    _controller =
        new StreamController<HttpRequest>(sync: true, onCancel: close);
    idleTimeout = const Duration(seconds: 120);
    _servers[_serviceId] = this;
  }

  static HttpHeaders _initDefaultResponseHeaders() {
    var defaultResponseHeaders = new _HttpHeaders('1.1');
    defaultResponseHeaders.contentType = ContentType.text;
    defaultResponseHeaders.set('X-Frame-Options', 'SAMEORIGIN');
    defaultResponseHeaders.set('X-Content-Type-Options', 'nosniff');
    defaultResponseHeaders.set('X-XSS-Protection', '1; mode=block');
    return defaultResponseHeaders;
  }

  Duration get idleTimeout => _idleTimeout;

  set idleTimeout(Duration duration) {
    if (_idleTimer != null) {
      _idleTimer.cancel();
      _idleTimer = null;
    }
    _idleTimeout = duration;
    if (_idleTimeout != null) {
      _idleTimer = new Timer.periodic(_idleTimeout, (_) {
        for (var idle in _idleConnections.toList()) {
          if (idle.isMarkedIdle) {
            idle.destroy();
          } else {
            idle.markIdle();
          }
        }
      });
    }
  }

  StreamSubscription<HttpRequest> listen(void onData(HttpRequest event),
      {Function onError, void onDone(), bool cancelOnError}) {
    _serverSocket.listen((Socket socket) {
      socket.setOption(SocketOption.tcpNoDelay, true);
      // Accept the client connection.
      _HttpConnection connection = new _HttpConnection(socket, this);
      _idleConnections.add(connection);
    }, onError: (error, stackTrace) {
      // Ignore HandshakeExceptions as they are bound to a single request,
      // and are not fatal for the server.
      if (error is! HandshakeException) {
        _controller.addError(error, stackTrace);
      }
    }, onDone: _controller.close);
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future close({bool force: false}) {
    closed = true;
    Future result;
    if (_serverSocket != null && _closeServer) {
      result = _serverSocket.close();
    } else {
      result = new Future.value();
    }
    idleTimeout = null;
    if (force) {
      for (var c in _activeConnections.toList()) {
        c.destroy();
      }
      assert(_activeConnections.isEmpty);
    }
    for (var c in _idleConnections.toList()) {
      c.destroy();
    }
    _maybePerformCleanup();
    return result;
  }

  void _maybePerformCleanup() {
    if (closed &&
        _idleConnections.isEmpty &&
        _activeConnections.isEmpty &&
        _sessionManagerInstance != null) {
      _sessionManagerInstance.close();
      _sessionManagerInstance = null;
      _servers.remove(_serviceId);
    }
  }

  int get port {
    if (closed) throw new HttpException("HttpServer is not bound to a socket");
    return _serverSocket.port;
  }

  InternetAddress get address {
    if (closed) throw new HttpException("HttpServer is not bound to a socket");
    return _serverSocket.address;
  }

  set sessionTimeout(int timeout) {
    _sessionManager.sessionTimeout = timeout;
  }

  void _handleRequest(_HttpRequest request) {
    if (!closed) {
      _controller.add(request);
    } else {
      request._httpConnection.destroy();
    }
  }

  void _connectionClosed(_HttpConnection connection) {
    // Remove itself from either idle or active connections.
    connection.unlink();
    _maybePerformCleanup();
  }

  void _markIdle(_HttpConnection connection) {
    _activeConnections.remove(connection);
    _idleConnections.add(connection);
  }

  void _markActive(_HttpConnection connection) {
    _idleConnections.remove(connection);
    _activeConnections.add(connection);
  }

  _HttpSessionManager get _sessionManager {
    // Lazy init.
    if (_sessionManagerInstance == null) {
      _sessionManagerInstance = new _HttpSessionManager();
    }
    return _sessionManagerInstance;
  }

  HttpConnectionsInfo connectionsInfo() {
    HttpConnectionsInfo result = new HttpConnectionsInfo();
    result.total = _activeConnections.length + _idleConnections.length;
    _activeConnections.forEach((_HttpConnection conn) {
      if (conn._isActive) {
        result.active++;
      } else {
        assert(conn._isClosing);
        result.closing++;
      }
    });
    _idleConnections.forEach((_HttpConnection conn) {
      result.idle++;
      assert(conn._isIdle);
    });
    return result;
  }

  String get _serviceTypePath => 'io/http/servers';
  String get _serviceTypeName => 'HttpServer';

  Map<String, dynamic> _toJSON(bool ref) {
    var r = <String, dynamic>{
      'id': _servicePath,
      'type': _serviceType(ref),
      'name': '${address.host}:$port',
      'user_name': '${address.host}:$port',
    };
    if (ref) {
      return r;
    }
    try {
      r['socket'] = _serverSocket._toJSON(true);
    } catch (_) {
      r['socket'] = {
        'id': _servicePath,
        'type': '@Socket',
        'name': 'UserSocket',
        'user_name': 'UserSocket',
      };
    }
    r['port'] = port;
    r['address'] = address.host;
    r['active'] = _activeConnections.map((c) => c._toJSON(true)).toList();
    r['idle'] = _idleConnections.map((c) => c._toJSON(true)).toList();
    r['closed'] = closed;
    return r;
  }

  _HttpSessionManager _sessionManagerInstance;

  // Indicated if the http server has been closed.
  bool closed = false;

  // The server listen socket. Untyped as it can be both ServerSocket and
  // SecureServerSocket.
  final dynamic /*ServerSocket|SecureServerSocket*/ _serverSocket;
  final bool _closeServer;

  // Set of currently connected clients.
  final LinkedList<_HttpConnection> _activeConnections =
      new LinkedList<_HttpConnection>();
  final LinkedList<_HttpConnection> _idleConnections =
      new LinkedList<_HttpConnection>();
  StreamController<HttpRequest> _controller;
}

class _ProxyConfiguration {
  // ! custom changes
  static const String SOCKS_PREFIX = "SOCKS4A ";
  static const String PROXY_PREFIX = "PROXY ";
  static const String DIRECT_PREFIX = "DIRECT";

  _ProxyConfiguration(String configuration) : proxies = new List<_Proxy>() {
    if (configuration == null) {
      throw new HttpException("Invalid proxy configuration $configuration");
    }
    List<String> list = configuration.split(";");
    list.forEach((String proxy) {
      proxy = proxy.trim();
      if (!proxy.isEmpty) {
        if (proxy.startsWith(PROXY_PREFIX)) {
          String username;
          String password;
          // Skip the "PROXY " prefix.
          proxy = proxy.substring(PROXY_PREFIX.length).trim();
          // Look for proxy authentication.
          int at = proxy.indexOf("@");
          if (at != -1) {
            String userinfo = proxy.substring(0, at).trim();
            proxy = proxy.substring(at + 1).trim();
            int colon = userinfo.indexOf(":");
            if (colon == -1 || colon == 0 || colon == proxy.length - 1) {
              throw new HttpException(
                  "Invalid proxy configuration $configuration");
            }
            username = userinfo.substring(0, colon).trim();
            password = userinfo.substring(colon + 1).trim();
          }
          // Look for proxy host and port.
          int colon = proxy.lastIndexOf(":");
          if (colon == -1 || colon == 0 || colon == proxy.length - 1) {
            throw new HttpException(
                "Invalid proxy configuration $configuration");
          }
          String host = proxy.substring(0, colon).trim();
          if (host.startsWith("[") && host.endsWith("]")) {
            host = host.substring(1, host.length - 1);
          }
          String portString = proxy.substring(colon + 1).trim();
          int port;
          try {
            port = int.parse(portString);
          } on FormatException {
            throw new HttpException(
                "Invalid proxy configuration $configuration, "
                "invalid port '$portString'");
          }
          proxies.add(new _Proxy(host, port, username, password));
        } else if (proxy.trim() == DIRECT_PREFIX) {
          proxies.add(new _Proxy.direct());
        } else if (proxy.startsWith(SOCKS_PREFIX)) {
          // Skip the "SOCKS4A " prefix.
          proxy = proxy.substring(SOCKS_PREFIX.length).trim();

          int at = proxy.indexOf("@");
          if (at != -1) {
            throw new HttpException(
                "Socks4a proxy does not support auth. Configuration: $configuration");
          }

          // Look for proxy host and port.
          int colon = proxy.lastIndexOf(":");
          if (colon == -1 || colon == 0 || colon == proxy.length - 1) {
            throw new HttpException(
                "Invalid proxy configuration $configuration");
          }
          String host = proxy.substring(0, colon).trim();
          if (host.startsWith("[") && host.endsWith("]")) {
            host = host.substring(1, host.length - 1);
          }
          String portString = proxy.substring(colon + 1).trim();
          int port;
          try {
            port = int.parse(portString);
          } on FormatException {
            throw new HttpException(
                "Invalid proxy configuration $configuration, "
                "invalid port '$portString'");
          }
          proxies.add(new _Proxy(
            host,
            port,
            null,
            null,
            isSocks4a: true,
          ));
        } else {
          throw new HttpException("Invalid proxy configuration $configuration");
        }
      }
    });
  }

  const _ProxyConfiguration.direct() : proxies = const [const _Proxy.direct()];

  final List<_Proxy> proxies;
}

class _Proxy {
  // ! custom changes
  final String host;
  final int port;
  final String username;
  final String password;
  final bool isDirect;
  final bool isSocks4a;

  const _Proxy(this.host, this.port, this.username, this.password,
      {this.isSocks4a = false})
      : isDirect = false;
  const _Proxy.direct()
      : host = null,
        port = null,
        username = null,
        password = null,
        isDirect = true,
        isSocks4a = false;

  bool get isAuthenticated => username != null;
}

class _HttpConnectionInfo implements HttpConnectionInfo {
  InternetAddress remoteAddress;
  int remotePort;
  int localPort;

  static _HttpConnectionInfo create(Socket socket) {
    if (socket == null) return null;
    try {
      _HttpConnectionInfo info = new _HttpConnectionInfo();
      return info
        ..remoteAddress = socket.remoteAddress
        ..remotePort = socket.remotePort
        ..localPort = socket.port;
    } catch (e) {}
    return null;
  }
}

class _DetachedSocket extends Stream<Uint8List> implements Socket {
  final Stream<Uint8List> _incoming;
  final Socket _socket;

  _DetachedSocket(this._socket, this._incoming);

  StreamSubscription<Uint8List> listen(void onData(Uint8List event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _incoming.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Encoding get encoding => _socket.encoding;

  set encoding(Encoding value) {
    _socket.encoding = value;
  }

  void write(Object obj) {
    _socket.write(obj);
  }

  void writeln([Object obj = ""]) {
    _socket.writeln(obj);
  }

  void writeCharCode(int charCode) {
    _socket.writeCharCode(charCode);
  }

  void writeAll(Iterable objects, [String separator = ""]) {
    _socket.writeAll(objects, separator);
  }

  void add(List<int> bytes) {
    _socket.add(bytes);
  }

  void addError(error, [StackTrace stackTrace]) =>
      _socket.addError(error, stackTrace);

  Future addStream(Stream<List<int>> stream) {
    return _socket.addStream(stream);
  }

  void destroy() {
    _socket.destroy();
  }

  Future flush() => _socket.flush();

  Future close() => _socket.close();

  Future get done => _socket.done;

  int get port => _socket.port;

  InternetAddress get address => _socket.address;

  InternetAddress get remoteAddress => _socket.remoteAddress;

  int get remotePort => _socket.remotePort;

  bool setOption(SocketOption option, bool enabled) {
    return _socket.setOption(option, enabled);
  }

  Uint8List getRawOption(RawSocketOption option) {
    return _socket.getRawOption(option);
  }

  void setRawOption(RawSocketOption option) {
    _socket.setRawOption(option);
  }

  Map _toJSON(bool ref) {
    return (_socket as dynamic)._toJSON(ref);
  }
}

class _AuthenticationScheme {
  final int _scheme;

  static const UNKNOWN = const _AuthenticationScheme(-1);
  static const BASIC = const _AuthenticationScheme(0);
  static const DIGEST = const _AuthenticationScheme(1);

  const _AuthenticationScheme(this._scheme);

  factory _AuthenticationScheme.fromString(String scheme) {
    if (scheme.toLowerCase() == "basic") return BASIC;
    if (scheme.toLowerCase() == "digest") return DIGEST;
    return UNKNOWN;
  }

  String toString() {
    if (this == BASIC) return "Basic";
    if (this == DIGEST) return "Digest";
    return "Unknown";
  }
}

abstract class _Credentials {
  _HttpClientCredentials credentials;
  String realm;
  bool used = false;

  // Digest specific fields.
  String ha1;
  String nonce;
  String algorithm;
  String qop;
  int nonceCount;

  _Credentials(this.credentials, this.realm) {
    if (credentials.scheme == _AuthenticationScheme.DIGEST) {
      // Calculate the H(A1) value once. There is no mentioning of
      // username/password encoding in RFC 2617. However there is an
      // open draft for adding an additional accept-charset parameter to
      // the WWW-Authenticate and Proxy-Authenticate headers, see
      // http://tools.ietf.org/html/draft-reschke-basicauth-enc-06. For
      // now always use UTF-8 encoding.
      _HttpClientDigestCredentials creds = credentials;
      var hasher = new _MD5()
        ..add(utf8.encode(creds.username))
        ..add([_CharCode.COLON])
        ..add(realm.codeUnits)
        ..add([_CharCode.COLON])
        ..add(utf8.encode(creds.password));
      ha1 = _CryptoUtils.bytesToHex(hasher.close());
    }
  }

  _AuthenticationScheme get scheme => credentials.scheme;

  void authorize(HttpClientRequest request);
}

class _SiteCredentials extends _Credentials {
  Uri uri;

  _SiteCredentials(this.uri, realm, _HttpClientCredentials creds)
      : super(creds, realm);

  bool applies(Uri uri, _AuthenticationScheme scheme) {
    if (scheme != null && credentials.scheme != scheme) return false;
    if (uri.host != this.uri.host) return false;
    int thisPort =
        this.uri.port == 0 ? HttpClient.defaultHttpPort : this.uri.port;
    int otherPort = uri.port == 0 ? HttpClient.defaultHttpPort : uri.port;
    if (otherPort != thisPort) return false;
    return uri.path.startsWith(this.uri.path);
  }

  void authorize(HttpClientRequest request) {
    // Digest credentials cannot be used without a nonce from the
    // server.
    if (credentials.scheme == _AuthenticationScheme.DIGEST && nonce == null) {
      return;
    }
    credentials.authorize(this, request);
    used = true;
  }
}

class _ProxyCredentials extends _Credentials {
  String host;
  int port;

  _ProxyCredentials(this.host, this.port, realm, _HttpClientCredentials creds)
      : super(creds, realm);

  bool applies(_Proxy proxy, _AuthenticationScheme scheme) {
    if (scheme != null && credentials.scheme != scheme) return false;
    return proxy.host == host && proxy.port == port;
  }

  void authorize(HttpClientRequest request) {
    // Digest credentials cannot be used without a nonce from the
    // server.
    if (credentials.scheme == _AuthenticationScheme.DIGEST && nonce == null) {
      return;
    }
    credentials.authorizeProxy(this, request);
  }
}

abstract class _HttpClientCredentials implements HttpClientCredentials {
  _AuthenticationScheme get scheme;
  void authorize(_Credentials credentials, HttpClientRequest request);
  void authorizeProxy(_ProxyCredentials credentials, HttpClientRequest request);
}

class _HttpClientBasicCredentials extends _HttpClientCredentials
    implements HttpClientBasicCredentials {
  String username;
  String password;

  _HttpClientBasicCredentials(this.username, this.password);

  _AuthenticationScheme get scheme => _AuthenticationScheme.BASIC;

  String authorization() {
    // There is no mentioning of username/password encoding in RFC
    // 2617. However there is an open draft for adding an additional
    // accept-charset parameter to the WWW-Authenticate and
    // Proxy-Authenticate headers, see
    // http://tools.ietf.org/html/draft-reschke-basicauth-enc-06. For
    // now always use UTF-8 encoding.
    String auth =
        _CryptoUtils.bytesToBase64(utf8.encode("$username:$password"));
    return "Basic $auth";
  }

  void authorize(_Credentials _, HttpClientRequest request) {
    request.headers.set(HttpHeaders.authorizationHeader, authorization());
  }

  void authorizeProxy(_ProxyCredentials _, HttpClientRequest request) {
    request.headers.set(HttpHeaders.proxyAuthorizationHeader, authorization());
  }
}

class _HttpClientDigestCredentials extends _HttpClientCredentials
    implements HttpClientDigestCredentials {
  String username;
  String password;

  _HttpClientDigestCredentials(this.username, this.password);

  _AuthenticationScheme get scheme => _AuthenticationScheme.DIGEST;

  String authorization(_Credentials credentials, _HttpClientRequest request) {
    String requestUri = request._requestUri();
    _MD5 hasher = new _MD5()
      ..add(request.method.codeUnits)
      ..add([_CharCode.COLON])
      ..add(requestUri.codeUnits);
    var ha2 = _CryptoUtils.bytesToHex(hasher.close());

    String qop;
    String cnonce;
    String nc;
    hasher = new _MD5()..add(credentials.ha1.codeUnits)..add([_CharCode.COLON]);
    if (credentials.qop == "auth") {
      qop = credentials.qop;
      cnonce = _CryptoUtils.bytesToHex(_CryptoUtils.getRandomBytes(4));
      ++credentials.nonceCount;
      nc = credentials.nonceCount.toRadixString(16);
      nc = "00000000".substring(0, 8 - nc.length + 1) + nc;
      hasher
        ..add(credentials.nonce.codeUnits)
        ..add([_CharCode.COLON])
        ..add(nc.codeUnits)
        ..add([_CharCode.COLON])
        ..add(cnonce.codeUnits)
        ..add([_CharCode.COLON])
        ..add(credentials.qop.codeUnits)
        ..add([_CharCode.COLON])
        ..add(ha2.codeUnits);
    } else {
      hasher
        ..add(credentials.nonce.codeUnits)
        ..add([_CharCode.COLON])
        ..add(ha2.codeUnits);
    }
    var response = _CryptoUtils.bytesToHex(hasher.close());

    StringBuffer buffer = new StringBuffer()
      ..write('Digest ')
      ..write('username="$username"')
      ..write(', realm="${credentials.realm}"')
      ..write(', nonce="${credentials.nonce}"')
      ..write(', uri="$requestUri"')
      ..write(', algorithm="${credentials.algorithm}"');
    if (qop == "auth") {
      buffer
        ..write(', qop="$qop"')
        ..write(', cnonce="$cnonce"')
        ..write(', nc="$nc"');
    }
    buffer.write(', response="$response"');
    return buffer.toString();
  }

  void authorize(_Credentials credentials, HttpClientRequest request) {
    request.headers.set(
        HttpHeaders.authorizationHeader, authorization(credentials, request));
  }

  void authorizeProxy(
      _ProxyCredentials credentials, HttpClientRequest request) {
    request.headers.set(HttpHeaders.proxyAuthorizationHeader,
        authorization(credentials, request));
  }
}

class _RedirectInfo implements RedirectInfo {
  final int statusCode;
  final String method;
  final Uri location;
  const _RedirectInfo(this.statusCode, this.method, this.location);
}

String _getHttpVersion() {
  var version = Platform.version;
  // Only include major and minor version numbers.
  int index = version.indexOf('.', version.indexOf('.') + 1);
  version = version.substring(0, index);
  return 'Dart/$version (dart:io)';
}

class _CryptoUtils {
  static const int PAD = 61; // '='
  static const int CR = 13; // '\r'
  static const int LF = 10; // '\n'
  static const int LINE_LENGTH = 76;

  static const String _encodeTable =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  static const String _encodeTableUrlSafe =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

  // Lookup table used for finding Base 64 alphabet index of a given byte.
  // -2 : Outside Base 64 alphabet.
  // -1 : '\r' or '\n'
  //  0 : = (Padding character).
  // >0 : Base 64 alphabet index of given byte.
  static const List<int> _decodeTable = const [
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -2, -2, -1, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, 62, -2, 63, //
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, 00, -2, -2, //
    -2, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, //
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, 63, //
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, //
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, //
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
  ];

  static Random _rng = new Random.secure();

  static Uint8List getRandomBytes(int count) {
    final Uint8List result = new Uint8List(count);
    for (int i = 0; i < count; i++) {
      result[i] = _rng.nextInt(0xff);
    }
    return result;
  }

  static String bytesToHex(List<int> bytes) {
    var result = new StringBuffer();
    for (var part in bytes) {
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return result.toString();
  }

  static String bytesToBase64(List<int> bytes,
      [bool urlSafe = false, bool addLineSeparator = false]) {
    int len = bytes.length;
    if (len == 0) {
      return "";
    }
    final String lookup = urlSafe ? _encodeTableUrlSafe : _encodeTable;
    // Size of 24 bit chunks.
    final int remainderLength = len.remainder(3);
    final int chunkLength = len - remainderLength;
    // Size of base output.
    int outputLen = ((len ~/ 3) * 4) + ((remainderLength > 0) ? 4 : 0);
    // Add extra for line separators.
    if (addLineSeparator) {
      outputLen += ((outputLen - 1) ~/ LINE_LENGTH) << 1;
    }
    List<int> out = new List<int>(outputLen);

    // Encode 24 bit chunks.
    int j = 0, i = 0, c = 0;
    while (i < chunkLength) {
      int x = ((bytes[i++] << 16) & 0xFFFFFF) |
          ((bytes[i++] << 8) & 0xFFFFFF) |
          bytes[i++];
      out[j++] = lookup.codeUnitAt(x >> 18);
      out[j++] = lookup.codeUnitAt((x >> 12) & 0x3F);
      out[j++] = lookup.codeUnitAt((x >> 6) & 0x3F);
      out[j++] = lookup.codeUnitAt(x & 0x3f);
      // Add optional line separator for each 76 char output.
      if (addLineSeparator && ++c == 19 && j < outputLen - 2) {
        out[j++] = CR;
        out[j++] = LF;
        c = 0;
      }
    }

    // If input length if not a multiple of 3, encode remaining bytes and
    // add padding.
    if (remainderLength == 1) {
      int x = bytes[i];
      out[j++] = lookup.codeUnitAt(x >> 2);
      out[j++] = lookup.codeUnitAt((x << 4) & 0x3F);
      out[j++] = PAD;
      out[j++] = PAD;
    } else if (remainderLength == 2) {
      int x = bytes[i];
      int y = bytes[i + 1];
      out[j++] = lookup.codeUnitAt(x >> 2);
      out[j++] = lookup.codeUnitAt(((x << 4) | (y >> 4)) & 0x3F);
      out[j++] = lookup.codeUnitAt((y << 2) & 0x3F);
      out[j++] = PAD;
    }

    return new String.fromCharCodes(out);
  }

  static List<int> base64StringToBytes(String input,
      [bool ignoreInvalidCharacters = true]) {
    int len = input.length;
    if (len == 0) {
      return new List<int>(0);
    }

    // Count '\r', '\n' and illegal characters, For illegal characters,
    // if [ignoreInvalidCharacters] is false, throw an exception.
    int extrasLen = 0;
    for (int i = 0; i < len; i++) {
      int c = _decodeTable[input.codeUnitAt(i)];
      if (c < 0) {
        extrasLen++;
        if (c == -2 && !ignoreInvalidCharacters) {
          throw new FormatException('Invalid character: ${input[i]}');
        }
      }
    }

    if ((len - extrasLen) % 4 != 0) {
      throw new FormatException('''Size of Base 64 characters in Input
          must be a multiple of 4. Input: $input''');
    }

    // Count pad characters, ignore illegal characters at the end.
    int padLength = 0;
    for (int i = len - 1; i >= 0; i--) {
      int currentCodeUnit = input.codeUnitAt(i);
      if (_decodeTable[currentCodeUnit] > 0) break;
      if (currentCodeUnit == PAD) padLength++;
    }
    int outputLen = (((len - extrasLen) * 6) >> 3) - padLength;
    List<int> out = new List<int>(outputLen);

    for (int i = 0, o = 0; o < outputLen;) {
      // Accumulate 4 valid 6 bit Base 64 characters into an int.
      int x = 0;
      for (int j = 4; j > 0;) {
        int c = _decodeTable[input.codeUnitAt(i++)];
        if (c >= 0) {
          x = ((x << 6) & 0xFFFFFF) | c;
          j--;
        }
      }
      out[o++] = x >> 16;
      if (o < outputLen) {
        out[o++] = (x >> 8) & 0xFF;
        if (o < outputLen) out[o++] = x & 0xFF;
      }
    }
    return out;
  }
}

// Constants.
const _MASK_8 = 0xff;
const _MASK_32 = 0xffffffff;
const _BITS_PER_BYTE = 8;
const _BYTES_PER_WORD = 4;

// Base class encapsulating common behavior for cryptographic hash
// functions.
abstract class _HashBase {
  // Hasher state.
  final int _chunkSizeInWords;
  final int _digestSizeInWords;
  final bool _bigEndianWords;
  int _lengthInBytes = 0;
  List<int> _pendingData;
  List<int> _currentChunk;
  List<int> _h;
  bool _digestCalled = false;

  _HashBase(
      this._chunkSizeInWords, this._digestSizeInWords, this._bigEndianWords)
      : _pendingData = [] {
    _currentChunk = new List(_chunkSizeInWords);
    _h = new List(_digestSizeInWords);
  }

  // Update the hasher with more data.
  add(List<int> data) {
    if (_digestCalled) {
      throw new StateError(
          'Hash update method called after digest was retrieved');
    }
    _lengthInBytes += data.length;
    _pendingData.addAll(data);
    _iterate();
  }

  // Finish the hash computation and return the digest string.
  List<int> close() {
    if (_digestCalled) {
      return _resultAsBytes();
    }
    _digestCalled = true;
    _finalizeData();
    _iterate();
    assert(_pendingData.length == 0);
    return _resultAsBytes();
  }

  // Returns the block size of the hash in bytes.
  int get blockSize {
    return _chunkSizeInWords * _BYTES_PER_WORD;
  }

  // Create a fresh instance of this Hash.
  newInstance();

  // One round of the hash computation.
  _updateHash(List<int> m);

  // Helper methods.
  _add32(x, y) => (x + y) & _MASK_32;
  _roundUp(val, n) => (val + n - 1) & -n;

  // Rotate left limiting to unsigned 32-bit values.
  int _rotl32(int val, int shift) {
    var modShift = shift & 31;
    return ((val << modShift) & _MASK_32) |
        ((val & _MASK_32) >> (32 - modShift));
  }

  // Compute the final result as a list of bytes from the hash words.
  List<int> _resultAsBytes() {
    var result = <int>[];
    for (var i = 0; i < _h.length; i++) {
      result.addAll(_wordToBytes(_h[i]));
    }
    return result;
  }

  // Converts a list of bytes to a chunk of 32-bit words.
  _bytesToChunk(List<int> data, int dataIndex) {
    assert((data.length - dataIndex) >= (_chunkSizeInWords * _BYTES_PER_WORD));

    for (var wordIndex = 0; wordIndex < _chunkSizeInWords; wordIndex++) {
      var w3 = _bigEndianWords ? data[dataIndex] : data[dataIndex + 3];
      var w2 = _bigEndianWords ? data[dataIndex + 1] : data[dataIndex + 2];
      var w1 = _bigEndianWords ? data[dataIndex + 2] : data[dataIndex + 1];
      var w0 = _bigEndianWords ? data[dataIndex + 3] : data[dataIndex];
      dataIndex += 4;
      var word = (w3 & 0xff) << 24;
      word |= (w2 & _MASK_8) << 16;
      word |= (w1 & _MASK_8) << 8;
      word |= (w0 & _MASK_8);
      _currentChunk[wordIndex] = word;
    }
  }

  // Convert a 32-bit word to four bytes.
  List<int> _wordToBytes(int word) {
    List<int> bytes = new List(_BYTES_PER_WORD);
    bytes[0] = (word >> (_bigEndianWords ? 24 : 0)) & _MASK_8;
    bytes[1] = (word >> (_bigEndianWords ? 16 : 8)) & _MASK_8;
    bytes[2] = (word >> (_bigEndianWords ? 8 : 16)) & _MASK_8;
    bytes[3] = (word >> (_bigEndianWords ? 0 : 24)) & _MASK_8;
    return bytes;
  }

  // Iterate through data updating the hash computation for each
  // chunk.
  _iterate() {
    var len = _pendingData.length;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    if (len >= chunkSizeInBytes) {
      var index = 0;
      for (; (len - index) >= chunkSizeInBytes; index += chunkSizeInBytes) {
        _bytesToChunk(_pendingData, index);
        _updateHash(_currentChunk);
      }
      _pendingData = _pendingData.sublist(index, len);
    }
  }

  // Finalize the data. Add a 1 bit to the end of the message. Expand with
  // 0 bits and add the length of the message.
  _finalizeData() {
    _pendingData.add(0x80);
    var contentsLength = _lengthInBytes + 9;
    var chunkSizeInBytes = _chunkSizeInWords * _BYTES_PER_WORD;
    var finalizedLength = _roundUp(contentsLength, chunkSizeInBytes);
    var zeroPadding = finalizedLength - contentsLength;
    for (var i = 0; i < zeroPadding; i++) {
      _pendingData.add(0);
    }
    var lengthInBits = _lengthInBytes * _BITS_PER_BYTE;
    assert(lengthInBits < pow(2, 32));
    if (_bigEndianWords) {
      _pendingData.addAll(_wordToBytes(0));
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
    } else {
      _pendingData.addAll(_wordToBytes(lengthInBits & _MASK_32));
      _pendingData.addAll(_wordToBytes(0));
    }
  }
}

// The MD5 hasher is used to compute an MD5 message digest.
class _MD5 extends _HashBase {
  _MD5() : super(16, 4, false) {
    _h[0] = 0x67452301;
    _h[1] = 0xefcdab89;
    _h[2] = 0x98badcfe;
    _h[3] = 0x10325476;
  }

  // Returns a new instance of this Hash.
  _MD5 newInstance() {
    return new _MD5();
  }

  static const _k = const [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, //
    0xa8304613, 0xfd469501, 0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, //
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821, 0xf61e2562, 0xc040b340, //
    0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8, //
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, //
    0x676f02d9, 0x8d2a4c8a, 0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, //
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70, 0x289b7ec6, 0xeaa127fa, //
    0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665, //
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, //
    0xffeff47d, 0x85845dd1, 0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, //
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
  ];

  static const _r = const [
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9, 14, //
    20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, //
    16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, //
    10, 15, 21, 6, 10, 15, 21
  ];

  // Compute one iteration of the MD5 algorithm with a chunk of
  // 16 32-bit pieces.
  void _updateHash(List<int> m) {
    assert(m.length == 16);

    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];

    var t0;
    var t1;

    for (var i = 0; i < 64; i++) {
      if (i < 16) {
        t0 = (b & c) | ((~b & _MASK_32) & d);
        t1 = i;
      } else if (i < 32) {
        t0 = (d & b) | ((~d & _MASK_32) & c);
        t1 = ((5 * i) + 1) % 16;
      } else if (i < 48) {
        t0 = b ^ c ^ d;
        t1 = ((3 * i) + 5) % 16;
      } else {
        t0 = c ^ (b | (~d & _MASK_32));
        t1 = (7 * i) % 16;
      }

      var temp = d;
      d = c;
      c = b;
      b = _add32(
          b, _rotl32(_add32(_add32(a, t0), _add32(_k[i], m[t1])), _r[i]));
      a = temp;
    }

    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
  }
}

// The SHA1 hasher is used to compute an SHA1 message digest.
class _SHA1 extends _HashBase {
  // Construct a SHA1 hasher object.
  _SHA1()
      : _w = new List(80),
        super(16, 5, true) {
    _h[0] = 0x67452301;
    _h[1] = 0xEFCDAB89;
    _h[2] = 0x98BADCFE;
    _h[3] = 0x10325476;
    _h[4] = 0xC3D2E1F0;
  }

  // Returns a new instance of this Hash.
  _SHA1 newInstance() {
    return new _SHA1();
  }

  // Compute one iteration of the SHA1 algorithm with a chunk of
  // 16 32-bit pieces.
  void _updateHash(List<int> m) {
    assert(m.length == 16);

    var a = _h[0];
    var b = _h[1];
    var c = _h[2];
    var d = _h[3];
    var e = _h[4];

    for (var i = 0; i < 80; i++) {
      if (i < 16) {
        _w[i] = m[i];
      } else {
        var n = _w[i - 3] ^ _w[i - 8] ^ _w[i - 14] ^ _w[i - 16];
        _w[i] = _rotl32(n, 1);
      }
      var t = _add32(_add32(_rotl32(a, 5), e), _w[i]);
      if (i < 20) {
        t = _add32(_add32(t, (b & c) | (~b & d)), 0x5A827999);
      } else if (i < 40) {
        t = _add32(_add32(t, (b ^ c ^ d)), 0x6ED9EBA1);
      } else if (i < 60) {
        t = _add32(_add32(t, (b & c) | (b & d) | (c & d)), 0x8F1BBCDC);
      } else {
        t = _add32(_add32(t, b ^ c ^ d), 0xCA62C1D6);
      }

      e = d;
      d = c;
      c = _rotl32(b, 30);
      b = a;
      a = t & _MASK_32;
    }

    _h[0] = _add32(a, _h[0]);
    _h[1] = _add32(b, _h[1]);
    _h[2] = _add32(c, _h[2]);
    _h[3] = _add32(d, _h[3]);
    _h[4] = _add32(e, _h[4]);
  }

  List<int> _w;
}

// Global constants.
class _Const {
  // Bytes for "HTTP".
  static const HTTP = const [72, 84, 84, 80];
  // Bytes for "HTTP/1.".
  static const HTTP1DOT = const [72, 84, 84, 80, 47, 49, 46];
  // Bytes for "HTTP/1.0".
  static const HTTP10 = const [72, 84, 84, 80, 47, 49, 46, 48];
  // Bytes for "HTTP/1.1".
  static const HTTP11 = const [72, 84, 84, 80, 47, 49, 46, 49];

  static const bool T = true;
  static const bool F = false;
  // Loopup-map for the following characters: '()<>@,;:\\"/[]?={} \t'.
  static const SEPARATOR_MAP = const [
    F, F, F, F, F, F, F, F, F, T, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, T, F, T, F, F, F, F, F, T, T, F, F, T, F, F, T, //
    F, F, F, F, F, F, F, F, F, F, T, T, T, T, T, T, T, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, T, T, T, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, T, F, T, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, //
    F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F
  ];
}

// Frequently used character codes.
class _CharCode {
  static const int HT = 9;
  static const int LF = 10;
  static const int CR = 13;
  static const int SP = 32;
  static const int AMPERSAND = 38;
  static const int COMMA = 44;
  static const int DASH = 45;
  static const int SLASH = 47;
  static const int ZERO = 48;
  static const int ONE = 49;
  static const int COLON = 58;
  static const int SEMI_COLON = 59;
  static const int EQUAL = 61;
}

// States of the HTTP parser state machine.
class _State {
  static const int START = 0;
  static const int METHOD_OR_RESPONSE_HTTP_VERSION = 1;
  static const int RESPONSE_HTTP_VERSION = 2;
  static const int REQUEST_LINE_METHOD = 3;
  static const int REQUEST_LINE_URI = 4;
  static const int REQUEST_LINE_HTTP_VERSION = 5;
  static const int REQUEST_LINE_ENDING = 6;
  static const int RESPONSE_LINE_STATUS_CODE = 7;
  static const int RESPONSE_LINE_REASON_PHRASE = 8;
  static const int RESPONSE_LINE_ENDING = 9;
  static const int HEADER_START = 10;
  static const int HEADER_FIELD = 11;
  static const int HEADER_VALUE_START = 12;
  static const int HEADER_VALUE = 13;
  static const int HEADER_VALUE_FOLDING_OR_ENDING = 14;
  static const int HEADER_VALUE_FOLD_OR_END = 15;
  static const int HEADER_ENDING = 16;

  static const int CHUNK_SIZE_STARTING_CR = 17;
  static const int CHUNK_SIZE_STARTING_LF = 18;
  static const int CHUNK_SIZE = 19;
  static const int CHUNK_SIZE_EXTENSION = 20;
  static const int CHUNK_SIZE_ENDING = 21;
  static const int CHUNKED_BODY_DONE_CR = 22;
  static const int CHUNKED_BODY_DONE_LF = 23;
  static const int BODY = 24;
  static const int CLOSED = 25;
  static const int UPGRADED = 26;
  static const int FAILURE = 27;

  static const int FIRST_BODY_STATE = CHUNK_SIZE_STARTING_CR;
}

// HTTP version of the request or response being parsed.
class _HttpVersion {
  static const int UNDETERMINED = 0;
  static const int HTTP10 = 1;
  static const int HTTP11 = 2;
}

// States of the HTTP parser state machine.
class _MessageType {
  static const int UNDETERMINED = 0;
  static const int REQUEST = 1;
  static const int RESPONSE = 0;
}

/**
 * The _HttpDetachedStreamSubscription takes a subscription and some extra data,
 * and makes it possible to "inject" the data in from of other data events
 * from the subscription.
 *
 * It does so by overriding pause/resume, so that once the
 * _HttpDetachedStreamSubscription is resumed, it'll deliver the data before
 * resuming the underlaying subscription.
 */
class _HttpDetachedStreamSubscription implements StreamSubscription<Uint8List> {
  StreamSubscription<Uint8List> _subscription;
  Uint8List _injectData;
  bool _isCanceled = false;
  int _pauseCount = 1;
  Function _userOnData;
  bool _scheduled = false;

  _HttpDetachedStreamSubscription(
      this._subscription, this._injectData, this._userOnData);

  bool get isPaused => _subscription.isPaused;

  Future<T> asFuture<T>([T futureValue]) =>
      _subscription.asFuture<T>(futureValue);

  Future cancel() {
    _isCanceled = true;
    _injectData = null;
    return _subscription.cancel();
  }

  void onData(void handleData(Uint8List data)) {
    _userOnData = handleData;
    _subscription.onData(handleData);
  }

  void onDone(void handleDone()) {
    _subscription.onDone(handleDone);
  }

  void onError(Function handleError) {
    _subscription.onError(handleError);
  }

  void pause([Future resumeSignal]) {
    if (_injectData == null) {
      _subscription.pause(resumeSignal);
    } else {
      _pauseCount++;
      if (resumeSignal != null) {
        resumeSignal.whenComplete(resume);
      }
    }
  }

  void resume() {
    if (_injectData == null) {
      _subscription.resume();
    } else {
      _pauseCount--;
      _maybeScheduleData();
    }
  }

  void _maybeScheduleData() {
    if (_scheduled) return;
    if (_pauseCount != 0) return;
    _scheduled = true;
    scheduleMicrotask(() {
      _scheduled = false;
      if (_pauseCount > 0 || _isCanceled) return;
      var data = _injectData;
      _injectData = null;
      // To ensure that 'subscription.isPaused' is false, we resume the
      // subscription here. This is fine as potential events are delayed.
      _subscription.resume();
      if (_userOnData != null) {
        _userOnData(data);
      }
    });
  }
}

class _HttpDetachedIncoming extends Stream<Uint8List> {
  final StreamSubscription<Uint8List> subscription;
  final Uint8List bufferedData;

  _HttpDetachedIncoming(this.subscription, this.bufferedData);

  StreamSubscription<Uint8List> listen(void onData(Uint8List event),
      {Function onError, void onDone(), bool cancelOnError}) {
    if (subscription != null) {
      subscription
        ..onData(onData)
        ..onError(onError)
        ..onDone(onDone);
      if (bufferedData == null) {
        return subscription..resume();
      }
      return new _HttpDetachedStreamSubscription(
          subscription, bufferedData, onData)
        ..resume();
    } else {
      // TODO(26379): add test for this branch.
      return new Stream<Uint8List>.fromIterable([bufferedData]).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    }
  }
}

/**
 * HTTP parser which parses the data stream given to [consume].
 *
 * If an HTTP parser error occurs, the parser will signal an error to either
 * the current _HttpIncoming or the _parser itself.
 *
 * The connection upgrades (e.g. switching from HTTP/1.1 to the
 * WebSocket protocol) is handled in a special way. If connection
 * upgrade is specified in the headers, then on the callback to
 * [:responseStart:] the [:upgrade:] property on the [:HttpParser:]
 * object will be [:true:] indicating that from now on the protocol is
 * not HTTP anymore and no more callbacks will happen, that is
 * [:dataReceived:] and [:dataEnd:] are not called in this case as
 * there is no more HTTP data. After the upgrade the method
 * [:readUnparsedData:] can be used to read any remaining bytes in the
 * HTTP parser which are part of the protocol the connection is
 * upgrading to. These bytes cannot be processed by the HTTP parser
 * and should be handled according to whatever protocol is being
 * upgraded to.
 */
class _HttpParser extends Stream<_HttpIncoming> {
  // State.
  bool _parserCalled = false;

  // The data that is currently being parsed.
  Uint8List _buffer;
  int _index;

  final bool _requestParser;
  int _state;
  int _httpVersionIndex;
  int _messageType;
  int _statusCode = 0;
  int _statusCodeLength = 0;
  final List<int> _method = [];
  final List<int> _uriOrReasonPhrase = [];
  final List<int> _headerField = [];
  final List<int> _headerValue = [];
  // The limit for method, uriOrReasonPhrase, header field and value
  int _headerSizeLimit = 8 * 1024;

  int _httpVersion;
  int _transferLength = -1;
  bool _persistentConnection;
  bool _connectionUpgrade;
  bool _chunked;

  bool _noMessageBody = false;
  int _remainingContent = -1;
  bool _contentLength = false;
  bool _transferEncoding = false;
  bool connectMethod = false;

  _HttpHeaders _headers;

  // The limit for parsing chunk size
  int _chunkSizeLimit = 0x7FFFFFFF;

  // The current incoming connection.
  _HttpIncoming _incoming;
  StreamSubscription<Uint8List> _socketSubscription;
  bool _paused = true;
  bool _bodyPaused = false;
  StreamController<_HttpIncoming> _controller;
  StreamController<Uint8List> _bodyController;

  factory _HttpParser.requestParser() {
    return new _HttpParser._(true);
  }

  factory _HttpParser.responseParser() {
    return new _HttpParser._(false);
  }

  _HttpParser._(this._requestParser) {
    _controller = new StreamController<_HttpIncoming>(
        sync: true,
        onListen: () {
          _paused = false;
        },
        onPause: () {
          _paused = true;
          _pauseStateChanged();
        },
        onResume: () {
          _paused = false;
          _pauseStateChanged();
        },
        onCancel: () {
          if (_socketSubscription != null) {
            _socketSubscription.cancel();
          }
        });
    _reset();
  }

  StreamSubscription<_HttpIncoming> listen(void onData(_HttpIncoming event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void listenToStream(Stream<Uint8List> stream) {
    // Listen to the stream and handle data accordingly. When a
    // _HttpIncoming is created, _dataPause, _dataResume, _dataDone is
    // given to provide a way of controlling the parser.
    // TODO(ajohnsen): Remove _dataPause, _dataResume and _dataDone and clean up
    // how the _HttpIncoming signals the parser.
    _socketSubscription =
        stream.listen(_onData, onError: _controller.addError, onDone: _onDone);
  }

  void _parse() {
    try {
      _doParse();
    } catch (e, s) {
      if (_state >= _State.CHUNK_SIZE_STARTING_CR && _state <= _State.BODY) {
        _state = _State.FAILURE;
        _reportBodyError(e, s);
      } else {
        _state = _State.FAILURE;
        _reportHttpError(e, s);
      }
    }
  }

  // Process end of headers. Returns true if the parser should stop
  // parsing and return. This will be in case of either an upgrade
  // request or a request or response with an empty body.
  bool _headersEnd() {
    // If method is CONNECT, response parser should ignore any Content-Length or
    // Transfer-Encoding header fields in a successful response.
    // [RFC 7231](https://tools.ietf.org/html/rfc7231#section-4.3.6)
    if (!_requestParser &&
        _statusCode >= 200 &&
        _statusCode < 300 &&
        connectMethod) {
      _transferLength = -1;
      _headers.chunkedTransferEncoding = false;
      _chunked = false;
      _headers.removeAll(HttpHeaders.contentLengthHeader);
      _headers.removeAll(HttpHeaders.transferEncodingHeader);
    }
    _headers._mutable = false;

    _transferLength = _headers.contentLength;
    // Ignore the Content-Length header if Transfer-Encoding
    // is chunked (RFC 2616 section 4.4)
    if (_chunked) _transferLength = -1;

    // If a request message has neither Content-Length nor
    // Transfer-Encoding the message must not have a body (RFC
    // 2616 section 4.3).
    if (_messageType == _MessageType.REQUEST &&
        _transferLength < 0 &&
        _chunked == false) {
      _transferLength = 0;
    }
    if (_connectionUpgrade) {
      _state = _State.UPGRADED;
      _transferLength = 0;
    }
    _createIncoming(_transferLength);
    if (_requestParser) {
      _incoming.method = new String.fromCharCodes(_method);
      _incoming.uri = Uri.parse(new String.fromCharCodes(_uriOrReasonPhrase));
    } else {
      _incoming.statusCode = _statusCode;
      _incoming.reasonPhrase = new String.fromCharCodes(_uriOrReasonPhrase);
    }
    _method.clear();
    _uriOrReasonPhrase.clear();
    if (_connectionUpgrade) {
      _incoming.upgraded = true;
      _parserCalled = false;
      var tmp = _incoming;
      _closeIncoming();
      _controller.add(tmp);
      return true;
    }
    if (_transferLength == 0 ||
        (_messageType == _MessageType.RESPONSE && _noMessageBody)) {
      _reset();
      var tmp = _incoming;
      _closeIncoming();
      _controller.add(tmp);
      return false;
    } else if (_chunked) {
      _state = _State.CHUNK_SIZE;
      _remainingContent = 0;
    } else if (_transferLength > 0) {
      _remainingContent = _transferLength;
      _state = _State.BODY;
    } else {
      // Neither chunked nor content length. End of body
      // indicated by close.
      _state = _State.BODY;
    }
    _parserCalled = false;
    _controller.add(_incoming);
    return true;
  }

  // From RFC 2616.
  // generic-message = start-line
  //                   *(message-header CRLF)
  //                   CRLF
  //                   [ message-body ]
  // start-line      = Request-Line | Status-Line
  // Request-Line    = Method SP Request-URI SP HTTP-Version CRLF
  // Status-Line     = HTTP-Version SP Status-Code SP Reason-Phrase CRLF
  // message-header  = field-name ":" [ field-value ]
  void _doParse() {
    assert(!_parserCalled);
    _parserCalled = true;
    if (_state == _State.CLOSED) {
      throw HttpException("Data on closed connection");
    }
    if (_state == _State.FAILURE) {
      throw HttpException("Data on failed connection");
    }
    while (_buffer != null &&
        _index < _buffer.length &&
        _state != _State.FAILURE &&
        _state != _State.UPGRADED) {
      // Depending on _incoming, we either break on _bodyPaused or _paused.
      if ((_incoming != null && _bodyPaused) ||
          (_incoming == null && _paused)) {
        _parserCalled = false;
        return;
      }

      if (_buffer.length == 8 && _buffer[0] == 0x00) {
        // ! custom changes
        if (_buffer[1] == 0x5A) {
          _index = _buffer.length;
          _controller.add(null);
          break;
        }
        if (_buffer[1] == 0x5B || _buffer[1] == 0x5C || _buffer[1] == 0x5D) {
          _index = _buffer.length;
          final error = "SOCKS Proxy failed to establish tunnel: ${_buffer[1]}";
          throw new HttpException(error);
        }
      }

      int byte = _buffer[_index++];
      switch (_state) {
        case _State.START:
          if (byte == _Const.HTTP[0]) {
            // Start parsing method or HTTP version.
            _httpVersionIndex = 1;
            _state = _State.METHOD_OR_RESPONSE_HTTP_VERSION;
          } else {
            // Start parsing method.
            if (!_isTokenChar(byte)) {
              throw HttpException("Invalid request method");
            }
            _addWithValidation(_method, byte);
            if (!_requestParser) {
              throw HttpException("Invalid response line");
            }
            _state = _State.REQUEST_LINE_METHOD;
          }
          break;

        case _State.METHOD_OR_RESPONSE_HTTP_VERSION:
          if (_httpVersionIndex < _Const.HTTP.length &&
              byte == _Const.HTTP[_httpVersionIndex]) {
            // Continue parsing HTTP version.
            _httpVersionIndex++;
          } else if (_httpVersionIndex == _Const.HTTP.length &&
              byte == _CharCode.SLASH) {
            // HTTP/ parsed. As method is a token this cannot be a
            // method anymore.
            _httpVersionIndex++;
            if (_requestParser) {
              throw HttpException("Invalid request line");
            }
            _state = _State.RESPONSE_HTTP_VERSION;
          } else {
            // Did not parse HTTP version. Expect method instead.
            for (int i = 0; i < _httpVersionIndex; i++) {
              _addWithValidation(_method, _Const.HTTP[i]);
            }
            if (byte == _CharCode.SP) {
              _state = _State.REQUEST_LINE_URI;
            } else {
              _addWithValidation(_method, byte);
              _httpVersion = _HttpVersion.UNDETERMINED;
              if (!_requestParser) {
                throw HttpException("Invalid response line");
              }
              _state = _State.REQUEST_LINE_METHOD;
            }
          }
          break;

        case _State.RESPONSE_HTTP_VERSION:
          if (_httpVersionIndex < _Const.HTTP1DOT.length) {
            // Continue parsing HTTP version.
            _expect(byte, _Const.HTTP1DOT[_httpVersionIndex]);
            _httpVersionIndex++;
          } else if (_httpVersionIndex == _Const.HTTP1DOT.length &&
              byte == _CharCode.ONE) {
            // HTTP/1.1 parsed.
            _httpVersion = _HttpVersion.HTTP11;
            _persistentConnection = true;
            _httpVersionIndex++;
          } else if (_httpVersionIndex == _Const.HTTP1DOT.length &&
              byte == _CharCode.ZERO) {
            // HTTP/1.0 parsed.
            _httpVersion = _HttpVersion.HTTP10;
            _persistentConnection = false;
            _httpVersionIndex++;
          } else if (_httpVersionIndex == _Const.HTTP1DOT.length + 1) {
            _expect(byte, _CharCode.SP);
            // HTTP version parsed.
            _state = _State.RESPONSE_LINE_STATUS_CODE;
          } else {
            throw HttpException(
                "Invalid response line, failed to parse HTTP version");
          }
          break;

        case _State.REQUEST_LINE_METHOD:
          if (byte == _CharCode.SP) {
            _state = _State.REQUEST_LINE_URI;
          } else {
            if (_Const.SEPARATOR_MAP[byte] ||
                byte == _CharCode.CR ||
                byte == _CharCode.LF) {
              throw HttpException("Invalid request method");
            }
            _addWithValidation(_method, byte);
          }
          break;

        case _State.REQUEST_LINE_URI:
          if (byte == _CharCode.SP) {
            if (_uriOrReasonPhrase.length == 0) {
              throw HttpException("Invalid request, empty URI");
            }
            _state = _State.REQUEST_LINE_HTTP_VERSION;
            _httpVersionIndex = 0;
          } else {
            if (byte == _CharCode.CR || byte == _CharCode.LF) {
              throw HttpException("Invalid request, unexpected $byte in URI");
            }
            _addWithValidation(_uriOrReasonPhrase, byte);
          }
          break;

        case _State.REQUEST_LINE_HTTP_VERSION:
          if (_httpVersionIndex < _Const.HTTP1DOT.length) {
            _expect(byte, _Const.HTTP11[_httpVersionIndex]);
            _httpVersionIndex++;
          } else if (_httpVersionIndex == _Const.HTTP1DOT.length) {
            if (byte == _CharCode.ONE) {
              // HTTP/1.1 parsed.
              _httpVersion = _HttpVersion.HTTP11;
              _persistentConnection = true;
              _httpVersionIndex++;
            } else if (byte == _CharCode.ZERO) {
              // HTTP/1.0 parsed.
              _httpVersion = _HttpVersion.HTTP10;
              _persistentConnection = false;
              _httpVersionIndex++;
            } else {
              throw HttpException("Invalid response, invalid HTTP version");
            }
          } else {
            if (byte == _CharCode.CR) {
              _state = _State.REQUEST_LINE_ENDING;
            } else {
              _expect(byte, _CharCode.LF);
              _messageType = _MessageType.REQUEST;
              _state = _State.HEADER_START;
            }
          }
          break;

        case _State.REQUEST_LINE_ENDING:
          _expect(byte, _CharCode.LF);
          _messageType = _MessageType.REQUEST;
          _state = _State.HEADER_START;
          break;

        case _State.RESPONSE_LINE_STATUS_CODE:
          if (byte == _CharCode.SP) {
            _state = _State.RESPONSE_LINE_REASON_PHRASE;
          } else if (byte == _CharCode.CR) {
            // Some HTTP servers does not follow the spec. and send
            // \r\n right after the status code.
            _state = _State.RESPONSE_LINE_ENDING;
          } else {
            _statusCodeLength++;
            if (byte < 0x30 || byte > 0x39) {
              throw HttpException("Invalid response status code with $byte");
            } else if (_statusCodeLength > 3) {
              throw HttpException(
                  "Invalid response, status code is over 3 digits");
            } else {
              _statusCode = _statusCode * 10 + byte - 0x30;
            }
          }
          break;

        case _State.RESPONSE_LINE_REASON_PHRASE:
          if (byte == _CharCode.CR) {
            _state = _State.RESPONSE_LINE_ENDING;
          } else {
            if (byte == _CharCode.CR || byte == _CharCode.LF) {
              throw HttpException(
                  "Invalid response, unexpected $byte in reason phrase");
            }
            _addWithValidation(_uriOrReasonPhrase, byte);
          }
          break;

        case _State.RESPONSE_LINE_ENDING:
          _expect(byte, _CharCode.LF);
          _messageType == _MessageType.RESPONSE;
          // Check whether this response will never have a body.
          if (_statusCode <= 199 || _statusCode == 204 || _statusCode == 304) {
            _noMessageBody = true;
          }
          _state = _State.HEADER_START;
          break;

        case _State.HEADER_START:
          _headers = new _HttpHeaders(version);
          if (byte == _CharCode.CR) {
            _state = _State.HEADER_ENDING;
          } else if (byte == _CharCode.LF) {
            _state = _State.HEADER_ENDING;
            _index--; // Make the new state see the LF again.
          } else {
            // Start of new header field.
            _addWithValidation(_headerField, _toLowerCaseByte(byte));
            _state = _State.HEADER_FIELD;
          }
          break;

        case _State.HEADER_FIELD:
          if (byte == _CharCode.COLON) {
            _state = _State.HEADER_VALUE_START;
          } else {
            if (!_isTokenChar(byte)) {
              throw HttpException("Invalid header field name, with $byte");
            }
            _addWithValidation(_headerField, _toLowerCaseByte(byte));
          }
          break;

        case _State.HEADER_VALUE_START:
          if (byte == _CharCode.CR) {
            _state = _State.HEADER_VALUE_FOLDING_OR_ENDING;
          } else if (byte == _CharCode.LF) {
            _state = _State.HEADER_VALUE_FOLD_OR_END;
          } else if (byte != _CharCode.SP && byte != _CharCode.HT) {
            // Start of new header value.
            _addWithValidation(_headerValue, byte);
            _state = _State.HEADER_VALUE;
          }
          break;

        case _State.HEADER_VALUE:
          if (byte == _CharCode.CR) {
            _state = _State.HEADER_VALUE_FOLDING_OR_ENDING;
          } else if (byte == _CharCode.LF) {
            _state = _State.HEADER_VALUE_FOLD_OR_END;
          } else {
            _addWithValidation(_headerValue, byte);
          }
          break;

        case _State.HEADER_VALUE_FOLDING_OR_ENDING:
          _expect(byte, _CharCode.LF);
          _state = _State.HEADER_VALUE_FOLD_OR_END;
          break;

        case _State.HEADER_VALUE_FOLD_OR_END:
          if (byte == _CharCode.SP || byte == _CharCode.HT) {
            _state = _State.HEADER_VALUE_START;
          } else {
            String headerField = new String.fromCharCodes(_headerField);
            String headerValue = new String.fromCharCodes(_headerValue);
            if (headerField == HttpHeaders.contentLengthHeader) {
              // Content Length header should not have more than one occurance
              // or coexist with Transfer Encoding header.
              if (_contentLength || _transferEncoding) {
                _statusCode = HttpStatus.badRequest;
              }
              _contentLength = true;
            } else if (headerField == HttpHeaders.transferEncodingHeader) {
              _transferEncoding = true;
              if (_caseInsensitiveCompare("chunked".codeUnits, _headerValue)) {
                _chunked = true;
              }
              if (_contentLength) {
                _statusCode = HttpStatus.badRequest;
              }
            }
            if (headerField == HttpHeaders.connectionHeader) {
              List<String> tokens = _tokenizeFieldValue(headerValue);
              final bool isResponse = _messageType == _MessageType.RESPONSE;
              final bool isUpgradeCode =
                  (_statusCode == HttpStatus.upgradeRequired) ||
                      (_statusCode == HttpStatus.switchingProtocols);
              for (int i = 0; i < tokens.length; i++) {
                final bool isUpgrade = _caseInsensitiveCompare(
                    "upgrade".codeUnits, tokens[i].codeUnits);
                if ((isUpgrade && !isResponse) ||
                    (isUpgrade && isResponse && isUpgradeCode)) {
                  _connectionUpgrade = true;
                }
                _headers._add(headerField, tokens[i]);
              }
            } else {
              _headers._add(headerField, headerValue);
            }
            _headerField.clear();
            _headerValue.clear();

            if (byte == _CharCode.CR) {
              _state = _State.HEADER_ENDING;
            } else if (byte == _CharCode.LF) {
              _state = _State.HEADER_ENDING;
              _index--; // Make the new state see the LF again.
            } else {
              // Start of new header field.
              _state = _State.HEADER_FIELD;
              _addWithValidation(_headerField, _toLowerCaseByte(byte));
            }
          }
          break;

        case _State.HEADER_ENDING:
          _expect(byte, _CharCode.LF);
          if (_headersEnd()) {
            return;
          }
          break;

        case _State.CHUNK_SIZE_STARTING_CR:
          _expect(byte, _CharCode.CR);
          _state = _State.CHUNK_SIZE_STARTING_LF;
          break;

        case _State.CHUNK_SIZE_STARTING_LF:
          _expect(byte, _CharCode.LF);
          _state = _State.CHUNK_SIZE;
          break;

        case _State.CHUNK_SIZE:
          if (byte == _CharCode.CR) {
            _state = _State.CHUNK_SIZE_ENDING;
          } else if (byte == _CharCode.SEMI_COLON) {
            _state = _State.CHUNK_SIZE_EXTENSION;
          } else {
            int value = _expectHexDigit(byte);
            // Checks whether (_remaingingContent * 16 + value) overflows.
            if (_remainingContent > _chunkSizeLimit >> 4) {
              throw HttpException('Chunk size overflows the integer');
            }
            _remainingContent = _remainingContent * 16 + value;
          }
          break;

        case _State.CHUNK_SIZE_EXTENSION:
          if (byte == _CharCode.CR) {
            _state = _State.CHUNK_SIZE_ENDING;
          }
          break;

        case _State.CHUNK_SIZE_ENDING:
          _expect(byte, _CharCode.LF);
          if (_remainingContent > 0) {
            _state = _State.BODY;
          } else {
            _state = _State.CHUNKED_BODY_DONE_CR;
          }
          break;

        case _State.CHUNKED_BODY_DONE_CR:
          _expect(byte, _CharCode.CR);
          _state = _State.CHUNKED_BODY_DONE_LF;
          break;

        case _State.CHUNKED_BODY_DONE_LF:
          _expect(byte, _CharCode.LF);
          _reset();
          _closeIncoming();
          break;

        case _State.BODY:
          // The body is not handled one byte at a time but in blocks.
          _index--;
          int dataAvailable = _buffer.length - _index;
          if (_remainingContent >= 0 && dataAvailable > _remainingContent) {
            dataAvailable = _remainingContent;
          }
          // Always present the data as a view. This way we can handle all
          // cases like this, and the user will not experience different data
          // typed (which could lead to polymorphic user code).
          Uint8List data = new Uint8List.view(
              _buffer.buffer, _buffer.offsetInBytes + _index, dataAvailable);
          _bodyController.add(data);
          if (_remainingContent != -1) {
            _remainingContent -= data.length;
          }
          _index += data.length;
          if (_remainingContent == 0) {
            if (!_chunked) {
              _reset();
              _closeIncoming();
            } else {
              _state = _State.CHUNK_SIZE_STARTING_CR;
            }
          }
          break;

        case _State.FAILURE:
          // Should be unreachable.
          assert(false);
          break;

        default:
          // Should be unreachable.
          assert(false);
          break;
      }
    }

    _parserCalled = false;
    if (_buffer != null && _index == _buffer.length) {
      // If all data is parsed release the buffer and resume receiving
      // data.
      _releaseBuffer();
      if (_state != _State.UPGRADED && _state != _State.FAILURE) {
        _socketSubscription.resume();
      }
    }
  }

  void _onData(Uint8List buffer) {
    _socketSubscription.pause();
    assert(_buffer == null);
    _buffer = buffer;
    _index = 0;
    _parse();
  }

  void _onDone() {
    // onDone cancels the subscription.
    _socketSubscription = null;
    if (_state == _State.CLOSED || _state == _State.FAILURE) return;

    if (_incoming != null) {
      if (_state != _State.UPGRADED &&
          !(_state == _State.START && !_requestParser) &&
          !(_state == _State.BODY && !_chunked && _transferLength == -1)) {
        _reportBodyError(
            HttpException("Connection closed while receiving data"));
      }
      _closeIncoming(true);
      _controller.close();
      return;
    }
    // If the connection is idle the HTTP stream is closed.
    if (_state == _State.START) {
      if (!_requestParser) {
        _reportHttpError(
            HttpException("Connection closed before full header was received"));
      }
      _controller.close();
      return;
    }

    if (_state == _State.UPGRADED) {
      _controller.close();
      return;
    }

    if (_state < _State.FIRST_BODY_STATE) {
      _state = _State.FAILURE;
      // Report the error through the error callback if any. Otherwise
      // throw the error.
      _reportHttpError(
          HttpException("Connection closed before full header was received"));
      _controller.close();
      return;
    }

    if (!_chunked && _transferLength == -1) {
      _state = _State.CLOSED;
    } else {
      _state = _State.FAILURE;
      // Report the error through the error callback if any. Otherwise
      // throw the error.
      _reportHttpError(
          HttpException("Connection closed before full body was received"));
    }
    _controller.close();
  }

  String get version {
    switch (_httpVersion) {
      case _HttpVersion.HTTP10:
        return "1.0";
      case _HttpVersion.HTTP11:
        return "1.1";
    }
    return null;
  }

  int get messageType => _messageType;
  int get transferLength => _transferLength;
  bool get upgrade => _connectionUpgrade && _state == _State.UPGRADED;
  bool get persistentConnection => _persistentConnection;

  set isHead(bool value) => _noMessageBody = value ?? false;

  _HttpDetachedIncoming detachIncoming() {
    // Simulate detached by marking as upgraded.
    _state = _State.UPGRADED;
    return new _HttpDetachedIncoming(_socketSubscription, readUnparsedData());
  }

  Uint8List readUnparsedData() {
    if (_buffer == null) return null;
    if (_index == _buffer.length) return null;
    var result = _buffer.sublist(_index);
    _releaseBuffer();
    return result;
  }

  void _reset() {
    if (_state == _State.UPGRADED) return;
    _state = _State.START;
    _messageType = _MessageType.UNDETERMINED;
    _headerField.clear();
    _headerValue.clear();
    _method.clear();
    _uriOrReasonPhrase.clear();

    _statusCode = 0;
    _statusCodeLength = 0;

    _httpVersion = _HttpVersion.UNDETERMINED;
    _transferLength = -1;
    _persistentConnection = false;
    _connectionUpgrade = false;
    _chunked = false;

    _noMessageBody = false;
    _remainingContent = -1;

    _contentLength = false;
    _transferEncoding = false;

    _headers = null;
  }

  void _releaseBuffer() {
    _buffer = null;
    _index = null;
  }

  static bool _isTokenChar(int byte) {
    return byte > 31 && byte < 128 && !_Const.SEPARATOR_MAP[byte];
  }

  static bool _isValueChar(int byte) {
    return (byte > 31 && byte < 128) ||
        (byte == _CharCode.SP) ||
        (byte == _CharCode.HT);
  }

  static List<String> _tokenizeFieldValue(String headerValue) {
    List<String> tokens = new List<String>();
    int start = 0;
    int index = 0;
    while (index < headerValue.length) {
      if (headerValue[index] == ",") {
        tokens.add(headerValue.substring(start, index));
        start = index + 1;
      } else if (headerValue[index] == " " || headerValue[index] == "\t") {
        start++;
      }
      index++;
    }
    tokens.add(headerValue.substring(start, index));
    return tokens;
  }

  static int _toLowerCaseByte(int x) {
    // Optimized version:
    //  -  0x41 is 'A'
    //  -  0x7f is ASCII mask
    //  -  26 is the number of alpha characters.
    //  -  0x20 is the delta between lower and upper chars.
    return (((x - 0x41) & 0x7f) < 26) ? (x | 0x20) : x;
  }

  // expected should already be lowercase.
  static bool _caseInsensitiveCompare(List<int> expected, List<int> value) {
    if (expected.length != value.length) return false;
    for (int i = 0; i < expected.length; i++) {
      if (expected[i] != _toLowerCaseByte(value[i])) return false;
    }
    return true;
  }

  void _expect(int val1, int val2) {
    if (val1 != val2) {
      throw HttpException("Failed to parse HTTP, $val1 does not match $val2");
    }
  }

  int _expectHexDigit(int byte) {
    if (0x30 <= byte && byte <= 0x39) {
      return byte - 0x30; // 0 - 9
    } else if (0x41 <= byte && byte <= 0x46) {
      return byte - 0x41 + 10; // A - F
    } else if (0x61 <= byte && byte <= 0x66) {
      return byte - 0x61 + 10; // a - f
    } else {
      throw HttpException(
          "Failed to parse HTTP, $byte is expected to be a Hex digit");
    }
  }

  void _addWithValidation(List<int> list, int byte) {
    if (list.length < _headerSizeLimit) {
      list.add(byte);
    } else {
      _reportSizeLimitError();
    }
  }

  void _reportSizeLimitError() {
    String method = "";
    switch (_state) {
      case _State.START:
      case _State.METHOD_OR_RESPONSE_HTTP_VERSION:
      case _State.REQUEST_LINE_METHOD:
        method = "Method";
        break;

      case _State.REQUEST_LINE_URI:
        method = "URI";
        break;

      case _State.RESPONSE_LINE_REASON_PHRASE:
        method = "Reason phrase";
        break;

      case _State.HEADER_START:
      case _State.HEADER_FIELD:
        method = "Header field";
        break;

      case _State.HEADER_VALUE_START:
      case _State.HEADER_VALUE:
        method = "Header value";
        break;

      default:
        throw UnsupportedError("Unexpected state: $_state");
        break;
    }
    throw HttpException("$method exceeds the $_headerSizeLimit size limit");
  }

  void _createIncoming(int transferLength) {
    assert(_incoming == null);
    assert(_bodyController == null);
    assert(!_bodyPaused);
    var incoming;
    _bodyController = new StreamController<Uint8List>(
        sync: true,
        onListen: () {
          if (incoming != _incoming) return;
          assert(_bodyPaused);
          _bodyPaused = false;
          _pauseStateChanged();
        },
        onPause: () {
          if (incoming != _incoming) return;
          assert(!_bodyPaused);
          _bodyPaused = true;
          _pauseStateChanged();
        },
        onResume: () {
          if (incoming != _incoming) return;
          assert(_bodyPaused);
          _bodyPaused = false;
          _pauseStateChanged();
        },
        onCancel: () {
          if (incoming != _incoming) return;
          if (_socketSubscription != null) {
            _socketSubscription.cancel();
          }
          _closeIncoming(true);
          _controller.close();
        });
    incoming = _incoming =
        new _HttpIncoming(_headers, transferLength, _bodyController.stream);
    _bodyPaused = true;
    _pauseStateChanged();
  }

  void _closeIncoming([bool closing = false]) {
    // Ignore multiple close (can happen in re-entrance).
    if (_incoming == null) return;
    var tmp = _incoming;
    tmp.close(closing);
    _incoming = null;
    if (_bodyController != null) {
      _bodyController.close();
      _bodyController = null;
    }
    _bodyPaused = false;
    _pauseStateChanged();
  }

  void _pauseStateChanged() {
    if (_incoming != null) {
      if (!_bodyPaused && !_parserCalled) {
        _parse();
      }
    } else {
      if (!_paused && !_parserCalled) {
        _parse();
      }
    }
  }

  void _reportHttpError(error, [stackTrace]) {
    if (_socketSubscription != null) _socketSubscription.cancel();
    _state = _State.FAILURE;
    _controller.addError(error, stackTrace);
    _controller.close();
  }

  void _reportBodyError(error, [stackTrace]) {
    if (_socketSubscription != null) _socketSubscription.cancel();
    _state = _State.FAILURE;
    _bodyController.addError(error, stackTrace);
    // In case of drain(), error event will close the stream.
    if (_bodyController != null) {
      _bodyController.close();
    }
  }
}

class _HttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers;
  // The original header names keyed by the lowercase header names.
  Map<String, String> _originalHeaderNames;
  final String protocolVersion;

  bool _mutable = true; // Are the headers currently mutable?
  List<String> _noFoldingHeaders;

  int _contentLength = -1;
  bool _persistentConnection = true;
  bool _chunkedTransferEncoding = false;
  String _host;
  int _port;

  final int _defaultPortForScheme;

  _HttpHeaders(this.protocolVersion,
      {int defaultPortForScheme: HttpClient.defaultHttpPort,
      _HttpHeaders initialHeaders})
      : _headers = new HashMap<String, List<String>>(),
        _defaultPortForScheme = defaultPortForScheme {
    if (initialHeaders != null) {
      initialHeaders._headers.forEach((name, value) => _headers[name] = value);
      _contentLength = initialHeaders._contentLength;
      _persistentConnection = initialHeaders._persistentConnection;
      _chunkedTransferEncoding = initialHeaders._chunkedTransferEncoding;
      _host = initialHeaders._host;
      _port = initialHeaders._port;
    }
    if (protocolVersion == "1.0") {
      _persistentConnection = false;
      _chunkedTransferEncoding = false;
    }
  }

  List<String> operator [](String name) => _headers[_validateField(name)];

  String value(String name) {
    name = _validateField(name);
    List<String> values = _headers[name];
    if (values == null) return null;
    if (values.length > 1) {
      throw new HttpException("More than one value for header $name");
    }
    return values[0];
  }

  void add(String name, value, {bool preserveHeaderCase = false}) {
    _checkMutable();
    String lowercaseName = _validateField(name);

    if (preserveHeaderCase && name != lowercaseName) {
      (_originalHeaderNames ??= {})[lowercaseName] = name;
    } else {
      _originalHeaderNames?.remove(lowercaseName);
    }
    _addAll(lowercaseName, value);
  }

  void _addAll(String name, value) {
    if (value is Iterable) {
      for (var v in value) {
        _add(name, _validateValue(v));
      }
    } else {
      _add(name, _validateValue(value));
    }
  }

  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _checkMutable();
    String lowercaseName = _validateField(name);
    _headers.remove(lowercaseName);
    _originalHeaderNames?.remove(lowercaseName);
    if (lowercaseName == HttpHeaders.transferEncodingHeader) {
      _chunkedTransferEncoding = false;
    }
    if (preserveHeaderCase && name != lowercaseName) {
      (_originalHeaderNames ??= {})[lowercaseName] = name;
    } else {
      _originalHeaderNames?.remove(lowercaseName);
    }
    _addAll(lowercaseName, value);
  }

  void remove(String name, Object value) {
    _checkMutable();
    name = _validateField(name);
    value = _validateValue(value);
    List<String> values = _headers[name];
    if (values != null) {
      int index = values.indexOf(value);
      if (index != -1) {
        values.removeRange(index, index + 1);
      }
      if (values.length == 0) {
        _headers.remove(name);
        _originalHeaderNames?.remove(name);
      }
    }
    if (name == HttpHeaders.transferEncodingHeader && value == "chunked") {
      _chunkedTransferEncoding = false;
    }
  }

  void removeAll(String name) {
    _checkMutable();
    name = _validateField(name);
    _headers.remove(name);
    _originalHeaderNames?.remove(name);
  }

  void forEach(void action(String name, List<String> values)) {
    _headers.forEach((String name, List<String> values) {
      String originalName = _originalHeaderName(name);
      action(originalName, values);
    });
  }

  void noFolding(String name) {
    name = _validateField(name);
    if (_noFoldingHeaders == null) _noFoldingHeaders = new List<String>();
    _noFoldingHeaders.add(name);
  }

  bool get persistentConnection => _persistentConnection;

  set persistentConnection(bool persistentConnection) {
    _checkMutable();
    if (persistentConnection == _persistentConnection) return;
    if (persistentConnection) {
      if (protocolVersion == "1.1") {
        remove(HttpHeaders.connectionHeader, "close");
      } else {
        if (_contentLength == -1) {
          throw new HttpException(
              "Trying to set 'Connection: Keep-Alive' on HTTP 1.0 headers with "
              "no ContentLength");
        }
        add(HttpHeaders.connectionHeader, "keep-alive");
      }
    } else {
      if (protocolVersion == "1.1") {
        add(HttpHeaders.connectionHeader, "close");
      } else {
        remove(HttpHeaders.connectionHeader, "keep-alive");
      }
    }
    _persistentConnection = persistentConnection;
  }

  int get contentLength => _contentLength;

  set contentLength(int contentLength) {
    _checkMutable();
    if (protocolVersion == "1.0" &&
        persistentConnection &&
        contentLength == -1) {
      throw new HttpException(
          "Trying to clear ContentLength on HTTP 1.0 headers with "
          "'Connection: Keep-Alive' set");
    }
    if (_contentLength == contentLength) return;
    _contentLength = contentLength;
    if (_contentLength >= 0) {
      if (chunkedTransferEncoding) chunkedTransferEncoding = false;
      _set(HttpHeaders.contentLengthHeader, contentLength.toString());
    } else {
      removeAll(HttpHeaders.contentLengthHeader);
      if (protocolVersion == "1.1") {
        chunkedTransferEncoding = true;
      }
    }
  }

  bool get chunkedTransferEncoding => _chunkedTransferEncoding;

  set chunkedTransferEncoding(bool chunkedTransferEncoding) {
    _checkMutable();
    if (chunkedTransferEncoding && protocolVersion == "1.0") {
      throw new HttpException(
          "Trying to set 'Transfer-Encoding: Chunked' on HTTP 1.0 headers");
    }
    if (chunkedTransferEncoding == _chunkedTransferEncoding) return;
    if (chunkedTransferEncoding) {
      List<String> values = _headers[HttpHeaders.transferEncodingHeader];
      if ((values == null || !values.contains("chunked"))) {
        // Headers does not specify chunked encoding - add it if set.
        _addValue(HttpHeaders.transferEncodingHeader, "chunked");
      }
      contentLength = -1;
    } else {
      // Headers does specify chunked encoding - remove it if not set.
      remove(HttpHeaders.transferEncodingHeader, "chunked");
    }
    _chunkedTransferEncoding = chunkedTransferEncoding;
  }

  String get host => _host;

  set host(String host) {
    _checkMutable();
    _host = host;
    _updateHostHeader();
  }

  int get port => _port;

  set port(int port) {
    _checkMutable();
    _port = port;
    _updateHostHeader();
  }

  DateTime get ifModifiedSince {
    List<String> values = _headers[HttpHeaders.ifModifiedSinceHeader];
    if (values != null) {
      try {
        return HttpDate.parse(values[0]);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  set ifModifiedSince(DateTime ifModifiedSince) {
    _checkMutable();
    // Format "ifModifiedSince" header with date in Greenwich Mean Time (GMT).
    String formatted = HttpDate.format(ifModifiedSince.toUtc());
    _set(HttpHeaders.ifModifiedSinceHeader, formatted);
  }

  DateTime get date {
    List<String> values = _headers[HttpHeaders.dateHeader];
    if (values != null) {
      try {
        return HttpDate.parse(values[0]);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  set date(DateTime date) {
    _checkMutable();
    // Format "DateTime" header with date in Greenwich Mean Time (GMT).
    String formatted = HttpDate.format(date.toUtc());
    _set("date", formatted);
  }

  DateTime get expires {
    List<String> values = _headers[HttpHeaders.expiresHeader];
    if (values != null) {
      try {
        return HttpDate.parse(values[0]);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  set expires(DateTime expires) {
    _checkMutable();
    // Format "Expires" header with date in Greenwich Mean Time (GMT).
    String formatted = HttpDate.format(expires.toUtc());
    _set(HttpHeaders.expiresHeader, formatted);
  }

  ContentType get contentType {
    var values = _headers[HttpHeaders.contentTypeHeader];
    if (values != null) {
      return ContentType.parse(values[0]);
    } else {
      return null;
    }
  }

  set contentType(ContentType contentType) {
    _checkMutable();
    _set(HttpHeaders.contentTypeHeader, contentType.toString());
  }

  void clear() {
    _checkMutable();
    _headers.clear();
    _contentLength = -1;
    _persistentConnection = true;
    _chunkedTransferEncoding = false;
    _host = null;
    _port = null;
  }

  // [name] must be a lower-case version of the name.
  void _add(String name, value) {
    assert(name == _validateField(name));
    // Use the length as index on what method to call. This is notable
    // faster than computing hash and looking up in a hash-map.
    switch (name.length) {
      case 4:
        if (HttpHeaders.dateHeader == name) {
          _addDate(name, value);
          return;
        }
        if (HttpHeaders.hostHeader == name) {
          _addHost(name, value);
          return;
        }
        break;
      case 7:
        if (HttpHeaders.expiresHeader == name) {
          _addExpires(name, value);
          return;
        }
        break;
      case 10:
        if (HttpHeaders.connectionHeader == name) {
          _addConnection(name, value);
          return;
        }
        break;
      case 12:
        if (HttpHeaders.contentTypeHeader == name) {
          _addContentType(name, value);
          return;
        }
        break;
      case 14:
        if (HttpHeaders.contentLengthHeader == name) {
          _addContentLength(name, value);
          return;
        }
        break;
      case 17:
        if (HttpHeaders.transferEncodingHeader == name) {
          _addTransferEncoding(name, value);
          return;
        }
        if (HttpHeaders.ifModifiedSinceHeader == name) {
          _addIfModifiedSince(name, value);
          return;
        }
    }
    _addValue(name, value);
  }

  void _addContentLength(String name, value) {
    if (value is int) {
      contentLength = value;
    } else if (value is String) {
      contentLength = int.parse(value);
    } else {
      throw new HttpException("Unexpected type for header named $name");
    }
  }

  void _addTransferEncoding(String name, value) {
    if (value == "chunked") {
      chunkedTransferEncoding = true;
    } else {
      _addValue(HttpHeaders.transferEncodingHeader, value);
    }
  }

  void _addDate(String name, value) {
    if (value is DateTime) {
      date = value;
    } else if (value is String) {
      _set(HttpHeaders.dateHeader, value);
    } else {
      throw new HttpException("Unexpected type for header named $name");
    }
  }

  void _addExpires(String name, value) {
    if (value is DateTime) {
      expires = value;
    } else if (value is String) {
      _set(HttpHeaders.expiresHeader, value);
    } else {
      throw new HttpException("Unexpected type for header named $name");
    }
  }

  void _addIfModifiedSince(String name, value) {
    if (value is DateTime) {
      ifModifiedSince = value;
    } else if (value is String) {
      _set(HttpHeaders.ifModifiedSinceHeader, value);
    } else {
      throw new HttpException("Unexpected type for header named $name");
    }
  }

  void _addHost(String name, value) {
    if (value is String) {
      int pos = value.indexOf(":");
      if (pos == -1) {
        _host = value;
        _port = HttpClient.defaultHttpPort;
      } else {
        if (pos > 0) {
          _host = value.substring(0, pos);
        } else {
          _host = null;
        }
        if (pos + 1 == value.length) {
          _port = HttpClient.defaultHttpPort;
        } else {
          try {
            _port = int.parse(value.substring(pos + 1));
          } on FormatException {
            _port = null;
          }
        }
      }
      _set(HttpHeaders.hostHeader, value);
    } else {
      throw new HttpException("Unexpected type for header named $name");
    }
  }

  void _addConnection(String name, value) {
    var lowerCaseValue = value.toLowerCase();
    if (lowerCaseValue == 'close') {
      _persistentConnection = false;
    } else if (lowerCaseValue == 'keep-alive') {
      _persistentConnection = true;
    }
    _addValue(name, value);
  }

  void _addContentType(String name, value) {
    _set(HttpHeaders.contentTypeHeader, value);
  }

  void _addValue(String name, Object value) {
    List<String> values = _headers[name];
    if (values == null) {
      values = new List<String>();
      _headers[name] = values;
    }
    if (value is DateTime) {
      values.add(HttpDate.format(value));
    } else if (value is String) {
      values.add(value);
    } else {
      values.add(_validateValue(value.toString()));
    }
  }

  void _set(String name, String value) {
    assert(name == _validateField(name));
    List<String> values = new List<String>();
    _headers[name] = values;
    values.add(value);
  }

  _checkMutable() {
    if (!_mutable) throw new HttpException("HTTP headers are not mutable");
  }

  _updateHostHeader() {
    bool defaultPort = _port == null || _port == _defaultPortForScheme;
    _set("host", defaultPort ? host : "$host:$_port");
  }

  _foldHeader(String name) {
    if (name == HttpHeaders.setCookieHeader ||
        (_noFoldingHeaders != null && _noFoldingHeaders.indexOf(name) != -1)) {
      return false;
    }
    return true;
  }

  void _finalize() {
    _mutable = false;
  }

  void _build(BytesBuilder builder) {
    for (String name in _headers.keys) {
      List<String> values = _headers[name];
      bool fold = _foldHeader(name);
      var nameData = name.codeUnits;
      builder.add(nameData);
      builder.addByte(_CharCode.COLON);
      builder.addByte(_CharCode.SP);
      for (int i = 0; i < values.length; i++) {
        if (i > 0) {
          if (fold) {
            builder.addByte(_CharCode.COMMA);
            builder.addByte(_CharCode.SP);
          } else {
            builder.addByte(_CharCode.CR);
            builder.addByte(_CharCode.LF);
            builder.add(nameData);
            builder.addByte(_CharCode.COLON);
            builder.addByte(_CharCode.SP);
          }
        }
        builder.add(values[i].codeUnits);
      }
      builder.addByte(_CharCode.CR);
      builder.addByte(_CharCode.LF);
    }
  }

  String toString() {
    StringBuffer sb = new StringBuffer();
    _headers.forEach((String name, List<String> values) {
      String originalName = _originalHeaderName(name);
      sb..write(originalName)..write(": ");
      bool fold = _foldHeader(name);
      for (int i = 0; i < values.length; i++) {
        if (i > 0) {
          if (fold) {
            sb.write(", ");
          } else {
            sb..write("\n")..write(originalName)..write(": ");
          }
        }
        sb.write(values[i]);
      }
      sb.write("\n");
    });
    return sb.toString();
  }

  List<Cookie> _parseCookies() {
    // Parse a Cookie header value according to the rules in RFC 6265.
    var cookies = new List<Cookie>();
    void parseCookieString(String s) {
      int index = 0;

      bool done() => index == -1 || index == s.length;

      void skipWS() {
        while (!done()) {
          if (s[index] != " " && s[index] != "\t") return;
          index++;
        }
      }

      String parseName() {
        int start = index;
        while (!done()) {
          if (s[index] == " " || s[index] == "\t" || s[index] == "=") break;
          index++;
        }
        return s.substring(start, index);
      }

      String parseValue() {
        int start = index;
        while (!done()) {
          if (s[index] == " " || s[index] == "\t" || s[index] == ";") break;
          index++;
        }
        return s.substring(start, index);
      }

      bool expect(String expected) {
        if (done()) return false;
        if (s[index] != expected) return false;
        index++;
        return true;
      }

      while (!done()) {
        skipWS();
        if (done()) return;
        String name = parseName();
        skipWS();
        if (!expect("=")) {
          index = s.indexOf(';', index);
          continue;
        }
        skipWS();
        String value = parseValue();
        try {
          cookies.add(new _Cookie(name, value));
        } catch (_) {
          // Skip it, invalid cookie data.
        }
        skipWS();
        if (done()) return;
        if (!expect(";")) {
          index = s.indexOf(';', index);
          continue;
        }
      }
    }

    List<String> values = _headers[HttpHeaders.cookieHeader];
    if (values != null) {
      values.forEach((headerValue) => parseCookieString(headerValue));
    }
    return cookies;
  }

  static String _validateField(String field) {
    for (var i = 0; i < field.length; i++) {
      if (!_HttpParser._isTokenChar(field.codeUnitAt(i))) {
        throw new FormatException(
            "Invalid HTTP header field name: ${json.encode(field)}", field, i);
      }
    }
    return field.toLowerCase();
  }

  static Object _validateValue(Object value) {
    if (value is! String) return value;
    for (var i = 0; i < (value as String).length; i++) {
      if (!_HttpParser._isValueChar((value as String).codeUnitAt(i))) {
        throw new FormatException(
            "Invalid HTTP header field value: ${json.encode(value)}", value, i);
      }
    }
    return value;
  }

  String _originalHeaderName(String name) {
    return (_originalHeaderNames == null ? null : _originalHeaderNames[name]) ??
        name;
  }
}

class _HeaderValue implements HeaderValue {
  String _value;
  Map<String, String> _parameters;
  Map<String, String> _unmodifiableParameters;

  _HeaderValue([this._value = "", Map<String, String> parameters = const {}]) {
    if (parameters != null && parameters.isNotEmpty) {
      _parameters = new HashMap<String, String>.from(parameters);
    }
  }

  static _HeaderValue parse(String value,
      {parameterSeparator: ";",
      valueSeparator: null,
      preserveBackslash: false}) {
    // Parse the string.
    var result = new _HeaderValue();
    result._parse(value, parameterSeparator, valueSeparator, preserveBackslash);
    return result;
  }

  String get value => _value;

  Map<String, String> _ensureParameters() => _parameters ??= <String, String>{};

  Map<String, String> get parameters =>
      _unmodifiableParameters ??= UnmodifiableMapView(_ensureParameters());

  static bool _isToken(String token) {
    if (token.isEmpty) {
      return false;
    }
    final delimiters = "\"(),/:;<=>?@[\]{}";
    for (int i = 0; i < token.length; i++) {
      int codeUnit = token.codeUnitAt(i);
      if (codeUnit <= 32 ||
          codeUnit >= 127 ||
          delimiters.indexOf(token[i]) >= 0) {
        return false;
      }
    }
    return true;
  }

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write(_value);
    if (parameters != null && parameters.length > 0) {
      _parameters.forEach((String name, String value) {
        sb..write("; ")..write(name);
        if (value != null) {
          sb.write("=");
          if (_isToken(value)) {
            sb.write(value);
          } else {
            sb.write('"');
            int start = 0;
            for (int i = 0; i < value.length; i++) {
              // Can use codeUnitAt here instead.
              int codeUnit = value.codeUnitAt(i);
              if (codeUnit == 92 /* backslash */ ||
                  codeUnit == 34 /* double quote */) {
                sb.write(value.substring(start, i));
                sb.write(r'\');
                start = i;
              }
            }
            sb..write(value.substring(start))..write('"');
          }
        }
      });
    }
    return sb.toString();
  }

  void _parse(String s, String parameterSeparator, String valueSeparator,
      bool preserveBackslash) {
    int index = 0;

    bool done() => index == s.length;

    void skipWS() {
      while (!done()) {
        if (s[index] != " " && s[index] != "\t") return;
        index++;
      }
    }

    String parseValue() {
      int start = index;
      while (!done()) {
        if (s[index] == " " ||
            s[index] == "\t" ||
            s[index] == valueSeparator ||
            s[index] == parameterSeparator) break;
        index++;
      }
      return s.substring(start, index);
    }

    void expect(String expected) {
      if (done() || s[index] != expected) {
        throw new HttpException("Failed to parse header value");
      }
      index++;
    }

    bool maybeExpect(String expected) {
      if (done() || !s.startsWith(expected, index)) {
        return false;
      }
      index++;
      return true;
    }

    void parseParameters() {
      var parameters = new HashMap<String, String>();
      _parameters = new UnmodifiableMapView(parameters);

      String parseParameterName() {
        int start = index;
        while (!done()) {
          if (s[index] == " " ||
              s[index] == "\t" ||
              s[index] == "=" ||
              s[index] == parameterSeparator ||
              s[index] == valueSeparator) break;
          index++;
        }
        return s.substring(start, index).toLowerCase();
      }

      String parseParameterValue() {
        if (!done() && s[index] == "\"") {
          // Parse quoted value.
          StringBuffer sb = new StringBuffer();
          index++;
          while (!done()) {
            if (s[index] == "\\") {
              if (index + 1 == s.length) {
                throw new HttpException("Failed to parse header value");
              }
              if (preserveBackslash && s[index + 1] != "\"") {
                sb.write(s[index]);
              }
              index++;
            } else if (s[index] == "\"") {
              index++;
              return sb.toString();
            }
            sb.write(s[index]);
            index++;
          }
          throw new HttpException("Failed to parse header value");
        } else {
          // Parse non-quoted value.
          return parseValue();
        }
      }

      while (!done()) {
        skipWS();
        if (done()) return;
        String name = parseParameterName();
        skipWS();
        if (maybeExpect("=")) {
          skipWS();
          String value = parseParameterValue();
          if (name == 'charset' && this is _ContentType) {
            // Charset parameter of ContentTypes are always lower-case.
            value = value.toLowerCase();
          }
          parameters[name] = value;
          skipWS();
        } else if (name.isNotEmpty) {
          parameters[name] = null;
        }
        if (done()) return;
        // TODO: Implement support for multi-valued parameters.
        if (s[index] == valueSeparator) return;
        expect(parameterSeparator);
      }
    }

    skipWS();
    _value = parseValue();
    skipWS();
    if (done()) return;
    if (s[index] == valueSeparator) return;
    maybeExpect(parameterSeparator);
    parseParameters();
  }
}

class _ContentType extends _HeaderValue implements ContentType {
  String _primaryType = "";
  String _subType = "";

  _ContentType(String primaryType, String subType, String charset,
      Map<String, String> parameters)
      : _primaryType = primaryType,
        _subType = subType,
        super("") {
    if (_primaryType == null) _primaryType = "";
    if (_subType == null) _subType = "";
    _value = "$_primaryType/$_subType";
    if (parameters != null) {
      _ensureParameters();
      parameters.forEach((String key, String value) {
        String lowerCaseKey = key.toLowerCase();
        if (lowerCaseKey == "charset") {
          value = value?.toLowerCase();
        }
        this._parameters[lowerCaseKey] = value;
      });
    }
    if (charset != null) {
      _ensureParameters();
      this._parameters["charset"] = charset.toLowerCase();
    }
  }

  _ContentType._();

  static _ContentType parse(String value) {
    var result = new _ContentType._();
    result._parse(value, ";", null, false);
    int index = result._value.indexOf("/");
    if (index == -1 || index == (result._value.length - 1)) {
      result._primaryType = result._value.trim().toLowerCase();
      result._subType = "";
    } else {
      result._primaryType =
          result._value.substring(0, index).trim().toLowerCase();
      result._subType = result._value.substring(index + 1).trim().toLowerCase();
    }
    return result;
  }

  String get mimeType => '$primaryType/$subType';

  String get primaryType => _primaryType;

  String get subType => _subType;

  String get charset => parameters["charset"];
}

class _Cookie implements Cookie {
  String _name;
  String _value;
  DateTime expires;
  int maxAge;
  String domain;
  String path;
  bool httpOnly = false;
  bool secure = false;

  _Cookie(String name, String value)
      : _name = _validateName(name),
        _value = _validateValue(value),
        httpOnly = true;

  String get name => _name;
  String get value => _value;

  set name(String newName) {
    _validateName(newName);
    _name = newName;
  }

  set value(String newValue) {
    _validateValue(newValue);
    _value = newValue;
  }

  _Cookie.fromSetCookieValue(String value) {
    // Parse the 'set-cookie' header value.
    _parseSetCookieValue(value);
  }

  // Parse a 'set-cookie' header value according to the rules in RFC 6265.
  void _parseSetCookieValue(String s) {
    int index = 0;

    bool done() => index == s.length;

    String parseName() {
      int start = index;
      while (!done()) {
        if (s[index] == "=") break;
        index++;
      }
      return s.substring(start, index).trim();
    }

    String parseValue() {
      int start = index;
      while (!done()) {
        if (s[index] == ";") break;
        index++;
      }
      return s.substring(start, index).trim();
    }

    void parseAttributes() {
      String parseAttributeName() {
        int start = index;
        while (!done()) {
          if (s[index] == "=" || s[index] == ";") break;
          index++;
        }
        return s.substring(start, index).trim().toLowerCase();
      }

      String parseAttributeValue() {
        int start = index;
        while (!done()) {
          if (s[index] == ";") break;
          index++;
        }
        return s.substring(start, index).trim().toLowerCase();
      }

      while (!done()) {
        String name = parseAttributeName();
        String value = "";
        if (!done() && s[index] == "=") {
          index++; // Skip the = character.
          value = parseAttributeValue();
        }
        if (name == "expires") {
          // Parse a cookie date string.
          DateTime _parseCookieDate(String date) {
            const List monthsLowerCase = const [
              "jan",
              "feb",
              "mar",
              "apr",
              "may",
              "jun",
              "jul",
              "aug",
              "sep",
              "oct",
              "nov",
              "dec"
            ];

            int position = 0;

            void error() {
              throw new HttpException("Invalid cookie date $date");
            }

            bool isEnd() => position == date.length;

            bool isDelimiter(String s) {
              int char = s.codeUnitAt(0);
              if (char == 0x09) return true;
              if (char >= 0x20 && char <= 0x2F) return true;
              if (char >= 0x3B && char <= 0x40) return true;
              if (char >= 0x5B && char <= 0x60) return true;
              if (char >= 0x7B && char <= 0x7E) return true;
              return false;
            }

            bool isNonDelimiter(String s) {
              int char = s.codeUnitAt(0);
              if (char >= 0x00 && char <= 0x08) return true;
              if (char >= 0x0A && char <= 0x1F) return true;
              if (char >= 0x30 && char <= 0x39) return true; // Digit
              if (char == 0x3A) return true; // ':'
              if (char >= 0x41 && char <= 0x5A) return true; // Alpha
              if (char >= 0x61 && char <= 0x7A) return true; // Alpha
              if (char >= 0x7F && char <= 0xFF) return true; // Alpha
              return false;
            }

            bool isDigit(String s) {
              int char = s.codeUnitAt(0);
              if (char > 0x2F && char < 0x3A) return true;
              return false;
            }

            int getMonth(String month) {
              if (month.length < 3) return -1;
              return monthsLowerCase.indexOf(month.substring(0, 3));
            }

            int toInt(String s) {
              int index = 0;
              for (; index < s.length && isDigit(s[index]); index++);
              return int.parse(s.substring(0, index));
            }

            var tokens = [];
            while (!isEnd()) {
              while (!isEnd() && isDelimiter(date[position])) position++;
              int start = position;
              while (!isEnd() && isNonDelimiter(date[position])) position++;
              tokens.add(date.substring(start, position).toLowerCase());
              while (!isEnd() && isDelimiter(date[position])) position++;
            }

            String timeStr;
            String dayOfMonthStr;
            String monthStr;
            String yearStr;

            for (var token in tokens) {
              if (token.length < 1) continue;
              if (timeStr == null &&
                  token.length >= 5 &&
                  isDigit(token[0]) &&
                  (token[1] == ":" || (isDigit(token[1]) && token[2] == ":"))) {
                timeStr = token;
              } else if (dayOfMonthStr == null && isDigit(token[0])) {
                dayOfMonthStr = token;
              } else if (monthStr == null && getMonth(token) >= 0) {
                monthStr = token;
              } else if (yearStr == null &&
                  token.length >= 2 &&
                  isDigit(token[0]) &&
                  isDigit(token[1])) {
                yearStr = token;
              }
            }

            if (timeStr == null ||
                dayOfMonthStr == null ||
                monthStr == null ||
                yearStr == null) {
              error();
            }

            int year = toInt(yearStr);
            if (year >= 70 && year <= 99)
              year += 1900;
            else if (year >= 0 && year <= 69) year += 2000;
            if (year < 1601) error();

            int dayOfMonth = toInt(dayOfMonthStr);
            if (dayOfMonth < 1 || dayOfMonth > 31) error();

            int month = getMonth(monthStr) + 1;

            var timeList = timeStr.split(":");
            if (timeList.length != 3) error();
            int hour = toInt(timeList[0]);
            int minute = toInt(timeList[1]);
            int second = toInt(timeList[2]);
            if (hour > 23) error();
            if (minute > 59) error();
            if (second > 59) error();

            return new DateTime.utc(
                year, month, dayOfMonth, hour, minute, second, 0);
          }

          expires = _parseCookieDate(value);
        } else if (name == "max-age") {
          maxAge = int.parse(value);
        } else if (name == "domain") {
          domain = value;
        } else if (name == "path") {
          path = value;
        } else if (name == "httponly") {
          httpOnly = true;
        } else if (name == "secure") {
          secure = true;
        }
        if (!done()) index++; // Skip the ; character
      }
    }

    _name = _validateName(parseName());
    if (done() || _name.length == 0) {
      throw new HttpException("Failed to parse header value [$s]");
    }
    index++; // Skip the = character.
    _value = _validateValue(parseValue());
    if (done()) return;
    index++; // Skip the ; character.
    parseAttributes();
  }

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb..write(_name)..write("=")..write(_value);
    if (expires != null) {
      sb..write("; Expires=")..write(HttpDate.format(expires));
    }
    if (maxAge != null) {
      sb..write("; Max-Age=")..write(maxAge);
    }
    if (domain != null) {
      sb..write("; Domain=")..write(domain);
    }
    if (path != null) {
      sb..write("; Path=")..write(path);
    }
    if (secure) sb.write("; Secure");
    if (httpOnly) sb.write("; HttpOnly");
    return sb.toString();
  }

  static String _validateName(String newName) {
    const separators = const [
      "(",
      ")",
      "<",
      ">",
      "@",
      ",",
      ";",
      ":",
      "\\",
      '"',
      "/",
      "[",
      "]",
      "?",
      "=",
      "{",
      "}"
    ];
    if (newName == null) throw new ArgumentError.notNull("name");
    for (int i = 0; i < newName.length; i++) {
      int codeUnit = newName.codeUnits[i];
      if (codeUnit <= 32 ||
          codeUnit >= 127 ||
          separators.indexOf(newName[i]) >= 0) {
        throw new FormatException(
            "Invalid character in cookie name, code unit: '$codeUnit'",
            newName,
            i);
      }
    }
    return newName;
  }

  static String _validateValue(String newValue) {
    if (newValue == null) throw new ArgumentError.notNull("value");
    // Per RFC 6265, consider surrounding "" as part of the value, but otherwise
    // double quotes are not allowed.
    int start = 0;
    int end = newValue.length;
    if (2 <= newValue.length &&
        newValue.codeUnits[start] == 0x22 &&
        newValue.codeUnits[end - 1] == 0x22) {
      start++;
      end--;
    }

    for (int i = start; i < end; i++) {
      int codeUnit = newValue.codeUnits[i];
      if (!(codeUnit == 0x21 ||
          (codeUnit >= 0x23 && codeUnit <= 0x2B) ||
          (codeUnit >= 0x2D && codeUnit <= 0x3A) ||
          (codeUnit >= 0x3C && codeUnit <= 0x5B) ||
          (codeUnit >= 0x5D && codeUnit <= 0x7E))) {
        throw new FormatException(
            "Invalid character in cookie value, code unit: '$codeUnit'",
            newValue,
            i);
      }
    }
    return newValue;
  }
}

// A _HttpSession is a node in a double-linked list, with _next and _prev being
// the previous and next pointers.
class _HttpSession implements HttpSession {
  // Destroyed marked. Used by the http connection to see if a session is valid.
  bool _destroyed = false;
  bool _isNew = true;
  DateTime _lastSeen;
  Function _timeoutCallback;
  _HttpSessionManager _sessionManager;
  // Pointers in timeout queue.
  _HttpSession _prev;
  _HttpSession _next;
  final String id;

  final Map _data = new HashMap();

  _HttpSession(this._sessionManager, this.id) : _lastSeen = new DateTime.now();

  void destroy() {
    _destroyed = true;
    _sessionManager._removeFromTimeoutQueue(this);
    _sessionManager._sessions.remove(id);
  }

  // Mark the session as seen. This will reset the timeout and move the node to
  // the end of the timeout queue.
  void _markSeen() {
    _lastSeen = new DateTime.now();
    _sessionManager._bumpToEnd(this);
  }

  DateTime get lastSeen => _lastSeen;

  bool get isNew => _isNew;

  set onTimeout(void callback()) {
    _timeoutCallback = callback;
  }

  // Map implementation:
  bool containsValue(value) => _data.containsValue(value);
  bool containsKey(key) => _data.containsKey(key);
  operator [](key) => _data[key];
  void operator []=(key, value) {
    _data[key] = value;
  }

  putIfAbsent(key, ifAbsent) => _data.putIfAbsent(key, ifAbsent);
  addAll(Map other) => _data.addAll(other);
  remove(key) => _data.remove(key);
  void clear() {
    _data.clear();
  }

  void forEach(void f(key, value)) {
    _data.forEach(f);
  }

  Iterable<MapEntry> get entries => _data.entries;

  void addEntries(Iterable<MapEntry> entries) {
    _data.addEntries(entries);
  }

  Map<K, V> map<K, V>(MapEntry<K, V> transform(key, value)) =>
      _data.map(transform);

  void removeWhere(bool test(key, value)) {
    _data.removeWhere(test);
  }

  Map<K, V> cast<K, V>() => _data.cast<K, V>();
  update(key, update(value), {ifAbsent()}) =>
      _data.update(key, update, ifAbsent: ifAbsent);

  void updateAll(update(key, value)) {
    _data.updateAll(update);
  }

  Iterable get keys => _data.keys;
  Iterable get values => _data.values;
  int get length => _data.length;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;

  String toString() => 'HttpSession id:$id $_data';
}

// Private class used to manage all the active sessions. The sessions are stored
// in two ways:
//
//  * In a map, mapping from ID to HttpSession.
//  * In a linked list, used as a timeout queue.
class _HttpSessionManager {
  Map<String, _HttpSession> _sessions;
  int _sessionTimeout = 20 * 60; // 20 mins.
  _HttpSession _head;
  _HttpSession _tail;
  Timer _timer;

  _HttpSessionManager() : _sessions = {};

  String createSessionId() {
    const int _KEY_LENGTH = 16; // 128 bits.
    var data = _CryptoUtils.getRandomBytes(_KEY_LENGTH);
    return _CryptoUtils.bytesToHex(data);
  }

  _HttpSession getSession(String id) => _sessions[id];

  _HttpSession createSession() {
    var id = createSessionId();
    // TODO(ajohnsen): Consider adding a limit and throwing an exception.
    // Should be very unlikely however.
    while (_sessions.containsKey(id)) {
      id = createSessionId();
    }
    var session = _sessions[id] = new _HttpSession(this, id);
    _addToTimeoutQueue(session);
    return session;
  }

  set sessionTimeout(int timeout) {
    _sessionTimeout = timeout;
    _stopTimer();
    _startTimer();
  }

  void close() {
    _stopTimer();
  }

  void _bumpToEnd(_HttpSession session) {
    _removeFromTimeoutQueue(session);
    _addToTimeoutQueue(session);
  }

  void _addToTimeoutQueue(_HttpSession session) {
    if (_head == null) {
      assert(_tail == null);
      _tail = _head = session;
      _startTimer();
    } else {
      assert(_timer != null);
      assert(_tail != null);
      // Add to end.
      _tail._next = session;
      session._prev = _tail;
      _tail = session;
    }
  }

  void _removeFromTimeoutQueue(_HttpSession session) {
    if (session._next != null) {
      session._next._prev = session._prev;
    }
    if (session._prev != null) {
      session._prev._next = session._next;
    }
    if (_head == session) {
      // We removed the head element, start new timer.
      _head = session._next;
      _stopTimer();
      _startTimer();
    }
    if (_tail == session) {
      _tail = session._prev;
    }
    session._next = session._prev = null;
  }

  void _timerTimeout() {
    _stopTimer(); // Clear timer.
    assert(_head != null);
    var session = _head;
    session.destroy(); // Will remove the session from timeout queue and map.
    if (session._timeoutCallback != null) {
      session._timeoutCallback();
    }
  }

  void _startTimer() {
    assert(_timer == null);
    if (_head != null) {
      int seconds = new DateTime.now().difference(_head.lastSeen).inSeconds;
      _timer = new Timer(
          new Duration(seconds: _sessionTimeout - seconds), _timerTimeout);
    }
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}
