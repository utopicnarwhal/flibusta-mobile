import 'package:equatable/equatable.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utopic_tor_onion_proxy/utopic_tor_onion_proxy.dart';

part 'tor_proxy_event.dart';
part 'tor_proxy_state.dart';

class TorProxyBloc extends Bloc<TorProxyEvent, TorProxyState> {
  static final TorProxyBloc _torProxyBlocSingleton = TorProxyBloc._internal();

  factory TorProxyBloc() {
    return _torProxyBlocSingleton;
  }
  TorProxyBloc._internal() : super(UnTorProxyState());

  Future<void> stopTorProxy() async {
    if (state is UnTorProxyState) {
      return;
    }
    _torProxyBlocSingleton.add(StopTorProxyEvent());
  }

  void startTorProxy() {
    if (state is StartingTorProxyState || state is InTorProxyState) {
      return;
    }
    _torProxyBlocSingleton.add(StartTorProxyEvent());
  }

  @override
  Stream<TorProxyState> mapEventToState(
    TorProxyEvent event,
  ) async* {
    try {
      yield StartingTorProxyState();
      yield await event.applyAsync(currentState: state, bloc: this);
    } catch (e) {
      print(e);
      yield ErrorTorProxyState(
        error: DsError(userMessage: 'Необработанная ошибка в mapEventToState'),
      );
    }
  }
}
