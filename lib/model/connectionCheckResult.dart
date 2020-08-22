import 'package:flibusta/model/extension_methods/dio_error_extension.dart';

class ConnectionCheckResult {
  int latency;
  DsError error;

  ConnectionCheckResult({
    this.latency,
    this.error,
  });
}
