import 'package:flibusta/pages/proxy_settings/free_proxy_tiles/free_proxy_tiles.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_store_service.dart';
import 'package:flutter/material.dart';

class ProxySettings extends StatefulWidget {
  @override
  createState() => ProxySettingsState();
}

class ProxySettingsState extends State<ProxySettings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _customProxy;
  bool _cachedGetUseFreeProxy;

  @override
  void initState() {
    super.initState();

    _customProxy = "";
    LocalStore().getUseFreeProxy().then((value) {
      setState(() {
        _cachedGetUseFreeProxy = value;
      });
    });
    LocalStore().getActualCustomProxy().then((value) {
      setState(() {
        _customProxy = value;
      });
    });
  }

  void changeGetUseFreeProxy(bool value) {
    if (_cachedGetUseFreeProxy != value) {
      setState(() {
        _cachedGetUseFreeProxy = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        centerTitle: false,
        title: Text("Настройки Proxy"),
      ),
      body: ListView(
        children: <Widget> [
          FreeProxyTiles(getUseFreeProxyChangeCallBack: (value) {
            changeGetUseFreeProxy(value);
          }),
          Container(
            color: Colors.transparent, 
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Вы также можете указать свой Proxy сервер, при необходимости", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            )
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Text("Подключения:", style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.w600),),
                ),
                RadioListTile(
                  title: Text("Без прокси"),
                  groupValue: _customProxy,
                  value: "",
                  onChanged: _cachedGetUseFreeProxy ?? true ? null : ((proxy) {
                    setState(() {
                      _customProxy = proxy;
                      LocalStore().setActualCustomProxy(_customProxy);
                      ProxyHttpClient().setProxy(_customProxy);
                    });
                  }),
                ),
                Divider(height: 1,),
                FutureBuilder(
                  future: LocalStore().getUserProxies(),
                  builder: (context, snapshot) {
                    return snapshot.data != null && snapshot.data.length > 0 ?
                    Column(
                      children:
                        List<Widget>.generate(
                          snapshot.data.length,
                          (int index) =>
                          RadioListTile(
                            groupValue: _customProxy,
                            value: snapshot.data[index],
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(snapshot.data[index]),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black),
                                  onPressed: () async {
                                    await LocalStore().deleteUserProxy(snapshot.data[index]);  
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            onChanged: _cachedGetUseFreeProxy ?? true ? null : (proxy) {
                              setState(() {
                                _customProxy = proxy;
                                LocalStore().setActualCustomProxy(_customProxy);
                                ProxyHttpClient().setProxy(_customProxy);
                              });
                            },
                          )
                        )
                    ) : Container();
                  },
                ),
                Divider(height: 1,),
                ListTile(
                  leading: Icon(Icons.add, color: Colors.black,),
                  title: Text("Добавить прокси"),
                  onTap: _cachedGetUseFreeProxy ?? true ? null : () async {
                    var userProxy = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        final TextEditingController proxyHostController = TextEditingController();
                        return SimpleDialog(
                          title: Text("Добавить прокси"),
                          children: <Widget>[
                            TextField(
                              controller: proxyHostController,
                              autofocus: true,
                              onEditingComplete: () {
                                Navigator.pop(context, proxyHostController.text);
                              },
                            )
                          ],
                        );
                      }
                    );
                    if (userProxy != null && userProxy.isNotEmpty) {
                      setState(() {
                        _customProxy = userProxy;
                        LocalStore().setActualCustomProxy(_customProxy);
                        ProxyHttpClient().setProxy(_customProxy);
                      });
                      LocalStore().addUserProxy(userProxy);
                    }
                  },
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}