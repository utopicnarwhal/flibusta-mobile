import 'package:flibusta/pages/proxy_settings/components/proxy_radio_list_tile.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';

class ProxySettingsPage extends StatefulWidget {
  static const routeName = '/ProxySettings';
  @override
  createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool requestingProxies = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).dividerColor,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Настройки Proxy'),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: FutureBuilder(
            future: LocalStorage().getActualProxy(),
            builder: (BuildContext context,
                AsyncSnapshot<String> actualProxySnapshot) {
              if (!actualProxySnapshot.hasData ||
                  !(actualProxySnapshot.data is String)) {
                return Container();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'Подключения:',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ProxyRadioListTile(
                    title: 'Без прокси',
                    value: '',
                    groupValue: actualProxySnapshot.data,
                    onChanged: (proxy) async {
                      await LocalStorage().setActualProxy(proxy);
                      ProxyHttpClient().setProxy(proxy);
                      setState(() {});
                    },
                  ),
                  FutureBuilder(
                    future: LocalStorage().getProxies(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data.length > 0) {
                        return Column(
                          children: List<Widget>.generate(
                            snapshot.data.length,
                            (int index) => ProxyRadioListTile(
                                  title: snapshot.data[index],
                                  value: snapshot.data[index],
                                  groupValue: actualProxySnapshot.data,
                                  onChanged: (proxy) async {
                                    await LocalStorage().setActualProxy(proxy);
                                    ProxyHttpClient().setProxy(proxy);
                                    setState(() {});
                                  },
                                  onDelete: () async {
                                    await LocalStorage()
                                        .deleteProxy(snapshot.data[index]);
                                    setState(() {});
                                  },
                                ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  ListTile(
                    enabled: !requestingProxies,
                    leading: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: requestingProxies
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : Icon(
                              Icons.add,
                              color: Theme.of(context).accentColor,
                            ),
                    ),
                    title: Text('Добавить прокси с сайта http://pubproxy.com'),
                    onTap: () async {
                      setState(() {
                        requestingProxies = true;
                      });
                      var newProxies = await ProxyHttpClient().getNewProxies();
                      if (newProxies != null && newProxies.isNotEmpty) {
                        setState(() {
                          newProxies.forEach((proxy) {
                            LocalStorage().addProxy(proxy);
                          });
                        });
                      } else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Ошибка при получении прокси'),
                        ));
                      }
                      await Future.delayed(Duration(seconds: 3));
                      if (mounted) {
                        setState(() {
                          requestingProxies = false;
                        });
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  ListTile(
                    enabled: true,
                    leading: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    title: Text('Добавить свой прокси'),
                    onTap: () async {
                      var userProxy = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          final TextEditingController proxyHostController =
                              TextEditingController();
                          return SimpleDialog(
                            title: Text('Добавить свой прокси'),
                            children: <Widget>[
                              TextField(
                                controller: proxyHostController,
                                autofocus: true,
                                onEditingComplete: () {
                                  Navigator.pop(
                                    context,
                                    proxyHostController.text,
                                  );
                                },
                              )
                            ],
                          );
                        },
                      );
                      if (userProxy != null && userProxy.isNotEmpty) {
                        setState(() {
                          LocalStorage().addProxy(userProxy);
                          LocalStorage().setActualProxy(userProxy);
                          ProxyHttpClient().setProxy(userProxy);
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
