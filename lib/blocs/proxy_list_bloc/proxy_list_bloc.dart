import 'package:bloc_pattern/bloc_pattern.dart';
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

  setActualProxy(String proxy){
    _actualProxySink.add(proxy);
    LocalStorage().setActualProxy(proxy);
    ProxyHttpClient().setProxy(proxy);
  }

  setProxyList(List<String> proxyList) {
    _proxyListSink.add(proxyList);
    LocalStorage().addProxy(proxy);
  }

  @override
  void dispose() {
    _actualProxyController.close();
    _proxyListController.close();
  }
}