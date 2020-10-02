import 'package:equatable/equatable.dart';
import 'package:flibusta/model/connectionCheckResult.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class ProxyInfo extends Equatable {
  final String name;
  final String hostPort;
  final bool isDeletable;
  final BehaviorSubject<ConnectionCheckResult> connectionCheckResultController =
      BehaviorSubject<ConnectionCheckResult>();

  ProxyInfo(
    this.hostPort, {
    this.name,
    this.isDeletable = false,
  }) {
    ProxyHttpClient().connectionCheck(hostPort).then((connectionCheckResult) {
      connectionCheckResultController.add(connectionCheckResult);
    });
  }

  Future<void> checkConnection() async {
    if (connectionCheckResultController.value == null) return;
    connectionCheckResultController.add(null);
    connectionCheckResultController
        .add(await ProxyHttpClient().connectionCheck(hostPort));
  }

  Future<dynamic> close() {
    return connectionCheckResultController.close();
  }

  @override
  List<Object> get props => [hostPort, isDeletable];
}

class ProxyListBloc {
  var _actualProxyController = BehaviorSubject<String>.seeded('');
  //output
  Stream<String> get actualProxyStream => _actualProxyController.stream;
  //input
  Sink<String> get _actualProxySink => _actualProxyController.sink;

  var _proxyListController = BehaviorSubject<List<ProxyInfo>>.seeded([]);
  //output
  Stream<List<ProxyInfo>> get proxyListStream => _proxyListController.stream;
  //input
  Sink<List<ProxyInfo>> get _proxyListSink => _proxyListController.sink;

  ProxyListBloc() {
    LocalStorage().getProxies().then((proxyList) {
      List<ProxyInfo> initialProxyList = [
        ProxyInfo(
          '',
          name: 'Без прокси',
        ),
      ];
      initialProxyList.addAll(
        proxyList.map((proxyHostPort) {
          return ProxyInfo(
            proxyHostPort,
            isDeletable: true,
          );
        }).toList(),
      );
      _proxyListController.add(initialProxyList);
    });

    LocalStorage().getActualProxy().then((actualProxy) {
      _actualProxyController.add(actualProxy);
    });
  }

  void setActualProxy(String proxy) {
    LocalStorage().setActualProxy(proxy);
    ProxyHttpClient().setProxy(proxy);
    _actualProxySink.add(proxy);
  }

  void checkProxiesConnection() {
    _proxyListController.value.forEach((proxyInfo) {
      proxyInfo.checkConnection();
    });
  }

  void addToProxyList(String proxy) {
    LocalStorage().addProxy(proxy);
    List<ProxyInfo> newProxyList = [
      ..._proxyListController.value,
      ProxyInfo(proxy, isDeletable: true),
    ];
    _proxyListSink.add(newProxyList);
  }

  void removeFromProxyList(String proxy) async {
    var currentProxyList = _proxyListController.value;
    var proxyToDelete = currentProxyList.firstWhere(
        (proxyInfo) => proxyInfo.hostPort == proxy && proxyInfo.isDeletable);

    if (proxyToDelete == null) return;

    await LocalStorage().deleteProxy(proxy);
    if (proxy == await LocalStorage().getActualProxy()) {
      await LocalStorage().setActualProxy('');
    }
    proxyToDelete.close();
    _proxyListSink.add(currentProxyList..remove(proxyToDelete));
  }

  void dispose() {
    _actualProxyController.close();
    _proxyListController.value.forEach((proxyInfo) => proxyInfo.close());
    _proxyListController.close();
  }
}
