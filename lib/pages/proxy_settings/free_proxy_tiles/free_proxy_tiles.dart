import 'package:flibusta_app/services/http_client_service.dart';
import 'package:flibusta_app/services/local_store_service.dart';
import 'package:flutter/material.dart';

class FreeProxyTiles extends StatefulWidget {
  @override
  createState() => FreeProxyTilesState();
}

class FreeProxyTilesState extends State<FreeProxyTiles> {
  var useFreeProxy = false;
  var freeProxyRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)]),
      child: Column(
        children: <Widget>[
          FutureBuilder(future: LocalStore().getUseFreeProxy(),
            builder: (context, snapshot) {
              useFreeProxy = snapshot.data ?? false;
              return Container(
                color: Colors.white,
                child: SwitchListTile(
                  title: Text('Использовать бесплатный прокси', style: TextStyle(fontSize: 15.0),),
                  subtitle: Row(
                    children: <Widget>[
                      Text('с сайта', style: TextStyle(fontSize: 15.0),),
                      Text(' ip-adress.com/proxy-list', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                    ]
                  ),
                  value: useFreeProxy,
                  onChanged: (useFreeProxy) async {
                    setState(() {
                      this.useFreeProxy = useFreeProxy;
                    });
                    LocalStore().setUseFreeProxy(useFreeProxy);
                    if (useFreeProxy) {
                      ProxyHttpClient().setProxy(await LocalStore().getActualFreeProxy());
                    } else {
                      ProxyHttpClient().setProxy(""); // TODO перенаправление на список прокси
                    }
                  },
                ),
              );
            }
          ),
          FutureBuilder(future: LocalStore().getActualFreeProxy(),
            builder: (context, snapshot) {
              return ListTile(
                title: Text(snapshot.data != null && snapshot.data != "" ? snapshot.data : "Не найдено. Обновите."),
                subtitle: snapshot.data != "" && useFreeProxy ? FutureBuilder(future: ProxyHttpClient().connectionCheck(snapshot.data),
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
                trailing: freeProxyRefreshing ? CircularProgressIndicator() : 
                  IconButton(
                    disabledColor: Colors.grey,
                    icon: Icon(Icons.refresh, size: 32.0,),
                    onPressed: useFreeProxy ? () async {
                      setState(() {
                        freeProxyRefreshing = true;
                      });
                      var newFreeProxy = await ProxyHttpClient().getWorkingProxyHost();
                      await LocalStore().setActualFreeProxy(newFreeProxy);
                      ProxyHttpClient().setProxy(newFreeProxy);
                      if (this.mounted) {
                        setState(() {
                          freeProxyRefreshing = false;
                        });
                        freeProxyRefreshing = false;
                      }
                    } : null
                  )
              );
            }
          ),
        ]
      ),
    );
  }
}