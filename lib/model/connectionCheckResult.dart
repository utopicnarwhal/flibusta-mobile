import 'package:flibusta/model/extension_methods/dio_error_extension.dart';

class ConnectionCheckResult {
  int ping;
  DsError error;

  ConnectionCheckResult({
    this.ping,
    this.error,
  });
}
