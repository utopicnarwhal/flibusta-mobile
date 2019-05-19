import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:dio/dio.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProxyListBloc extends BlocBase {
  var _actualProxyController = BehaviorSubject<String>.seeded('');
  //output
  Stream<String> get actualProxyStream => _actualProxyController.stream;
  //input
  Sink<String> get _actualProxySink => _actualProxyController.sink;

  var _proxyListController = BehaviorSubject<List<String>>.seeded([]);
  //output
  Stream<List<String>> get proxyListStream => _proxyListController.stream;
  //input
  Sink<List<String>> get _proxyListSink => _proxyListController.sink;

  CancelToken cancelToken;

  ProxyListBloc() {
    cancelToken = CancelToken();
    LocalStorage().getProxies().then((proxyList) => _proxyListController.add(proxyList));
    LocalStorage().getActualProxy().then((actualProxy) => _actualProxyController.add(actualProxy));
  }

  setActualProxy(String proxy) {
    LocalStorage().setActualProxy(proxy);
    ProxyHttpClient().setProxy(proxy);
    _actualProxySink.add(proxy);
  }

  addToProxyList(String proxy) {
    LocalStorage().addProxy(proxy);
    var newProxyList = [..._proxyListController.value, proxy];
    _proxyListSink.add(newProxyList);
  }

  removeFromProxyList(String proxy) {
    LocalStorage().deleteProxy(proxy);
    _proxyListSink.add([..._proxyListController.value]..remove(proxy));
  }

  @override
  void dispose() {
    _actualProxyController.close();
    _proxyListController.close();
  }
}
