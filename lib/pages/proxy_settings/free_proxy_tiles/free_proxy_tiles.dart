import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flutter/material.dart';

class FreeProxyTiles extends StatefulWidget {
  final Function(bool) getUseFreeProxyChangeCallBack;

  FreeProxyTiles({Key key, this.getUseFreeProxyChangeCallBack}): super(key: key);

  @override
  createState() => FreeProxyTilesState();
}

class FreeProxyTilesState extends State<FreeProxyTiles> {
  var _useFreeProxy = false;
  var _freeProxyRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
      child: Column(
        children: <Widget>[
          FutureBuilder(future: LocalStore().getUseFreeProxy(),
            builder: (context, snapshot) {
              _useFreeProxy = snapshot.data ?? false;
              return Container(
                color: Theme.of(context).cardColor,
                child: SwitchListTile(
                  title: Text('Использовать бесплатный прокси', style: TextStyle(fontSize: 15.0),),
                  subtitle: Wrap(
                    children: <Widget>[
                      Text('с сайта', style: TextStyle(fontSize: 15.0),),
                      Text(' api.getproxylist.com', 
                        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      Text('(30 запросов в день)', style: TextStyle(fontSize: 15.0),),
                    ]
                  ),
                  value: _useFreeProxy,
                  onChanged: (useFreeProxy) async {
                    await LocalStore().setUseFreeProxy(useFreeProxy);
                    
                    if (useFreeProxy) {
                      ProxyHttpClient().setProxy(await LocalStore().getActualFreeProxy());
                    } else {
                      ProxyHttpClient().setProxy(await LocalStore().getActualCustomProxy());
                    }

                    setState(() {
                      _useFreeProxy = useFreeProxy;
                    });

                    widget.getUseFreeProxyChangeCallBack(_useFreeProxy);
                  },
                ),
              );
            }
          ),
          FutureBuilder(future: LocalStore().getActualFreeProxy(),
            builder: (context, snapshot) {
              return ListTile(
                title: Text(snapshot.data != null && snapshot.data != "" ? snapshot.data : "Не найдено. Обновите."),
                subtitle: snapshot.data != "" && _useFreeProxy ? FutureBuilder(future: ProxyHttpClient().connectionCheck(snapshot.data),
                  builder: (context, snapshot) {
                    var subtitleText = "";
                    var subtitleColor;
                    if (snapshot.data != null && snapshot.connectionState != ConnectionState.waiting) {
                      if (snapshot.data >= 0) {
                        subtitleText = "доступно (пинг: " + snapshot.data.toString() + "мс)";
                        subtitleColor = Colors.green;
                      } else {
                        subtitleText = "недоступно";
                        subtitleColor = Colors.red;
                      }
                    } else {
                      subtitleText = "проверка...";
                      subtitleColor = Colors.grey[400];
                    }
                    return Text(subtitleText, style: TextStyle(color: subtitleColor));
                  },
                ) : Container(),
                trailing: _freeProxyRefreshing ? CircularProgressIndicator() : 
                  IconButton(
                    disabledColor: Colors.grey,
                    tooltip: "Запросить новый прокси",
                    icon: Icon(Icons.refresh, size: 32.0,),
                    onPressed: _useFreeProxy ? () async {
                      setState(() {
                        _freeProxyRefreshing = true;
                      });
                      var newFreeProxy = await ProxyHttpClient().getNewProxy();
                      if (mounted && _freeProxyRefreshing) {
                        await LocalStore().setActualFreeProxy(newFreeProxy);
                      }
                      if (mounted && _freeProxyRefreshing) {
                        ProxyHttpClient().setProxy(newFreeProxy);
                      }
                      if (this.mounted && _freeProxyRefreshing) {
                        setState(() {
                          _freeProxyRefreshing = false;
                        });
                      }
                    } : null
                  ),
              );
            }
          ),
        ]
      ),
    );
  }
}