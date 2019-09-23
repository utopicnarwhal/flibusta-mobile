import 'package:flibusta/blocs/proxy_list/proxy_list_bloc.dart';
import 'package:flibusta/pages/proxy_settings/components/get_new_proxy_tile.dart';
import 'package:flibusta/pages/proxy_settings/components/proxy_radio_list_tile.dart';
import 'package:flutter/material.dart';

class ProxySettingsPage extends StatefulWidget {
  static const routeName = '/ProxySettings';
  @override
  createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ProxyListBloc _proxyListBloc;

  @override
  void initState() {
    super.initState();
    _proxyListBloc = ProxyListBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Настройки Proxy'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              child: Text(
                'Использование прокси-сервера может помочь, если Флибуста заблокирована Вашим интернет-провайдером.',
                style: Theme.of(context).textTheme.body1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                'Соединения:',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              elevation: 8.0,
              child: StreamBuilder(
                stream: _proxyListBloc.actualProxyStream,
                builder: (BuildContext context,
                    AsyncSnapshot<String> actualProxySnapshot) {
                  if (!actualProxySnapshot.hasData ||
                      !(actualProxySnapshot.data is String)) {
                    return Container();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ProxyRadioListTile(
                        title: 'Без прокси',
                        value: '',
                        groupValue: actualProxySnapshot.data,
                        onChanged: _proxyListBloc.setActualProxy,
                        cancelToken: _proxyListBloc.cancelToken,
                      ),
                      Divider(
                        height: 1,
                      ),
                      StreamBuilder(
                        stream: _proxyListBloc.proxyListStream,
                        builder:
                            (context, AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.data == null || snapshot.data.isEmpty) {
                            return Container();
                          }

                          return Column(
                            children: ListTile.divideTiles(
                              context: context,
                              tiles: [
                                for (var proxyElement in snapshot.data)
                                  ProxyRadioListTile(
                                    title: proxyElement,
                                    value: proxyElement,
                                    groupValue: actualProxySnapshot.data,
                                    onChanged: _proxyListBloc.setActualProxy,
                                    onDelete:
                                        _proxyListBloc.removeFromProxyList,
                                    cancelToken: _proxyListBloc.cancelToken,
                                  ),
                              ],
                            ).toList()
                              ..add(Divider(height: 1)),
                          );
                        },
                      ),
                      GetNewProxyTile(
                        callback: _proxyListBloc.addToProxyList,
                      ),
                      Divider(
                        height: 1,
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
                            _proxyListBloc.addToProxyList(userProxy);
                            _proxyListBloc.setActualProxy(userProxy);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 14.0),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _proxyListBloc.dispose();
    super.dispose();
  }
}
