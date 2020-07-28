part of 'tor_proxy_bloc.dart';

@immutable
abstract class TorProxyEvent extends Equatable {
  final List inProps;

  TorProxyEvent([this.inProps = const []]);

  @override
  List<Object> get props => inProps;

  Future<TorProxyState> applyAsync(
      {TorProxyState currentState, TorProxyBloc bloc});
}

class StartTorProxyEvent extends TorProxyEvent {
  @override
  String toString() => 'StartTorProxyEvent';

  @override
  Future<TorProxyState> applyAsync(
      {TorProxyState currentState, TorProxyBloc bloc}) async {
    try {
      var port = await UtopicTorOnionProxy.startTor();

      return InTorProxyState(
        port: port,
      );
    } on PlatformException catch (e) {
      return ErrorTorProxyState(
        error: DsError(userMessage: e.message),
      );
    }
  }
}

class CheckRunningTorProxyEvent extends TorProxyEvent {
  @override
  String toString() => 'CheckRunningTorProxyEvent';

  @override
  Future<TorProxyState> applyAsync(
      {TorProxyState currentState, TorProxyBloc bloc}) async {
    try {
      if (await UtopicTorOnionProxy.isTorRunning()) {
        if (currentState is InTorProxyState && currentState.port == null) {
          await UtopicTorOnionProxy.stopTor();
          return UnTorProxyState();
        }
        return UnTorProxyState();
      }
      return ErrorTorProxyState(
        error: DsError(userMessage: 'Не удалось остановить Tor'),
      );
    } on PlatformException catch (e) {
      return ErrorTorProxyState(
        error: DsError(userMessage: e.message),
      );
    }
  }
}

class StopTorProxyEvent extends TorProxyEvent {
  @override
  String toString() => 'StopTorProxyEvent';

  @override
  Future<TorProxyState> applyAsync(
      {TorProxyState currentState, TorProxyBloc bloc}) async {
    try {
      if (await UtopicTorOnionProxy.stopTor()) {
        return UnTorProxyState();
      }
      return ErrorTorProxyState(
        error: DsError(userMessage: 'Не удалось остановить Tor'),
      );
    } on PlatformException catch (e) {
      return ErrorTorProxyState(
        error: DsError(userMessage: e.message),
      );
    }
  }
}
