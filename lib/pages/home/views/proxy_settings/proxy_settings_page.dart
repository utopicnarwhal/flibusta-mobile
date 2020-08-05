import 'dart:async';

import 'package:flibusta/blocs/proxy_list/proxy_list_bloc.dart';
import 'package:flibusta/blocs/tor_proxy/tor_proxy_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/buttons/raised_button.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/get_new_proxy_tile.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/proxy_radio_list_tile.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/tor_onion_proxy_card.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/server_status_checker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProxySettingsPage extends StatefulWidget {
  static const routeName = '/ProxySettings';

  final StreamController<int> selectedNavItemController;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ProxySettingsPage({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  ProxyListBloc _proxyListBloc;

  @override
  void initState() {
    super.initState();
    _proxyListBloc = ProxyListBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            addSemanticIndexes: false,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 42),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Прокси',
                      style: Theme.of(context).textTheme.headline4.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyText2.color,
                          ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      tooltip: 'Проверить прокси повторно',
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              ListFadeInSlideStagger(
                index: 0,
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ServerStatusChecker(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TorOnionProxyCard(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Использование прокси-сервера может помочь, если Флибуста заблокирована Вашим интернет-провайдером.',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 16),
              Text(
                'Прокси-сервера создателя приложения будут отключены 21 сентября 2020 года.',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Colors.red),
              ),
              SizedBox(height: 16),
              Text(
                'Соединения:',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              BlocBuilder<TorProxyBloc, TorProxyState>(
                cubit: TorProxyBloc(),
                builder: (context, torProxyState) {
                  if (torProxyState is InTorProxyState) {
                    return Text(
                        'Выбор прокси-серверов отключен, пока работает Tor Onion Proxy.');
                  }
                  return ListFadeInSlideStagger(
                    index: 1,
                    child: Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kCardBorderRadius),
                        child: Material(
                          type: MaterialType.card,
                          borderRadius:
                              BorderRadius.circular(kCardBorderRadius),
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
                                children: [
                                  ProxyRadioListTile(
                                    title: 'Без прокси',
                                    value: '',
                                    groupValue: actualProxySnapshot.data,
                                    onChanged: _proxyListBloc.setActualProxy,
                                    cancelToken: _proxyListBloc.cancelToken,
                                  ),
                                  Divider(),
                                  ProxyRadioListTile(
                                    title: 'Прокси создателя приложения 1',
                                    value:
                                        'flibustauser:ilovebooks@35.217.29.210:1194',
                                    groupValue: actualProxySnapshot.data,
                                    onChanged: _proxyListBloc.setActualProxy,
                                    cancelToken: _proxyListBloc.cancelToken,
                                  ),
                                  Divider(),
                                  ProxyRadioListTile(
                                    title: 'Прокси создателя приложения 2',
                                    value:
                                        'flibustauser:ilovebooks@35.228.73.110:3128',
                                    groupValue: actualProxySnapshot.data,
                                    onChanged: _proxyListBloc.setActualProxy,
                                    cancelToken: _proxyListBloc.cancelToken,
                                  ),
                                  Divider(),
                                  StreamBuilder(
                                    stream: _proxyListBloc.proxyListStream,
                                    builder: (context,
                                        AsyncSnapshot<List<String>> snapshot) {
                                      if (snapshot.data == null ||
                                          snapshot.data.isEmpty) {
                                        return Container();
                                      }

                                      return Column(
                                        children: ListTile.divideTiles(
                                          context: context,
                                          tiles: [
                                            for (var proxyElement
                                                in snapshot.data)
                                              ProxyRadioListTile(
                                                title: proxyElement,
                                                value: proxyElement,
                                                groupValue:
                                                    actualProxySnapshot.data,
                                                onChanged: _proxyListBloc
                                                    .setActualProxy,
                                                onDelete: (proxyHost) {
                                                  _proxyListBloc
                                                      .removeFromProxyList(
                                                          proxyHost);
                                                  if (actualProxySnapshot
                                                          .data ==
                                                      proxyHost) {
                                                    _proxyListBloc
                                                        .setActualProxy('');
                                                  }
                                                },
                                                cancelToken:
                                                    _proxyListBloc.cancelToken,
                                              ),
                                          ],
                                        ).toList()
                                          ..add(Divider()),
                                      );
                                    },
                                  ),
                                  GetNewProxyTile(
                                    callback: _proxyListBloc.addToProxyList,
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.add,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                    title: Text('Добавить свой HTTP-прокси'),
                                    onTap: () async {
                                      var userProxy = await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          final TextEditingController
                                              proxyHostController =
                                              TextEditingController();
                                          return SimpleDialog(
                                            title: Text(
                                                'Добавить свой HTTP-прокси'),
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(16),
                                                child: TextField(
                                                  controller:
                                                      proxyHostController,
                                                  autofocus: true,
                                                  onEditingComplete: () {
                                                    Navigator.pop(
                                                      context,
                                                      proxyHostController.text,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16),
                                                  child: DsRaisedButton(
                                                    child: Text('Добавить'),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                        context,
                                                        proxyHostController
                                                            .text,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (userProxy != null &&
                                          userProxy.isNotEmpty) {
                                        _proxyListBloc
                                            .addToProxyList(userProxy);
                                        _proxyListBloc
                                            .setActualProxy(userProxy);
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 14.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        key: Key('HomeBottomNavBar'),
        index: 2,
        selectedNavItemController: widget.selectedNavItemController,
      ),
    );
  }

  @override
  void dispose() {
    _proxyListBloc.dispose();
    super.dispose();
  }
}
