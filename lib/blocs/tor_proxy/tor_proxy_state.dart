part of 'tor_proxy_bloc.dart';

@immutable
abstract class TorProxyState extends Equatable {
  final List inProps;

  TorProxyState({
    this.inProps = const [],
  });

  @override
  List<Object> get props => inProps;
}

class StartingTorProxyState extends TorProxyState {}

class UnTorProxyState extends TorProxyState {}

class InTorProxyState extends TorProxyState {
  final int port;

  InTorProxyState({
    @required this.port,
  });
}

class ErrorTorProxyState extends TorProxyState {
  final DsError error;

  ErrorTorProxyState({
    this.error,
  });
}
