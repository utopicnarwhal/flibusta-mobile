import 'dart:async';

import 'package:flibusta/blocs/proxy_list/proxy_list_bloc.dart';
import 'package:flibusta/blocs/tor_proxy/tor_proxy_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/decor/staggers.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/add_custom_proxy_dialog.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/get_new_proxy_tile.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/proxy_radio_list_tile.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/tor_onion_proxy_card.dart';
import 'package:flibusta/services/server_status_checker.dart';
import 'package:flutter/material.dart';
import 'package:flibusta/pages/home/views/proxy_settings/components/server_status_checker_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProxySettingsPage extends StatelessWidget {
  static const routeName = '/ProxySettings';

  final StreamController<int> selectedNavItemController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ProxyListBloc proxyListBloc;
  final ServerStatusChecker serverStatusChecker;

  const ProxySettingsPage({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
    @required this.proxyListBloc,
    @required this.serverStatusChecker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            addSemanticIndexes: false,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 42),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Прокси',
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyText2.color,
                      ),
                ),
              ),
              SizedBox(height: 8),
              ListFadeInSlideStagger(
                index: 0,
                child: ServerStatusCheckerCard(
                  serverStatusChecker: serverStatusChecker,
                ),
              ),
              SizedBox(height: 16),
              ListFadeInSlideStagger(
                index: 1,
                child: TorOnionProxyCard(),
              ),
              SizedBox(height: 16),
              Text(
                'Использование прокси-сервера может помочь, если Флибуста заблокирована Вашим интернет-провайдером.',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Соединения:',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    tooltip: 'Проверить прокси повторно',
                    onPressed: () {
                      proxyListBloc.checkProxiesConnection();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              BlocBuilder<TorProxyBloc, TorProxyState>(
                cubit: TorProxyBloc(),
                builder: (context, torProxyState) {
                  if (torProxyState is InTorProxyState) {
                    return Text(
                      'Выбор прокси-серверов отключен, пока работает Tor Onion Proxy.',
                    );
                  }
                  return ListFadeInSlideStagger(
                    index: 3,
                    child: Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kCardBorderRadius),
                        child: Material(
                          type: MaterialType.card,
                          borderRadius:
                              BorderRadius.circular(kCardBorderRadius),
                          child: Column(
                            children: [
                              StreamBuilder<String>(
                                stream: proxyListBloc.actualProxyStream,
                                builder: (context, actualProxySnapshot) {
                                  return StreamBuilder<List<ProxyInfo>>(
                                    stream: proxyListBloc.proxyListStream,
                                    builder: (context, proxyListSnapshot) {
                                      if (!actualProxySnapshot.hasData ||
                                          !proxyListSnapshot.hasData ||
                                          proxyListSnapshot.data.isEmpty) {
                                        return Container();
                                      }

                                      return ListView.separated(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        addSemanticIndexes: false,
                                        separatorBuilder: (context, index) {
                                          return Divider();
                                        },
                                        itemCount:
                                            proxyListSnapshot.data.length,
                                        itemBuilder: (context, index) {
                                          var proxyInfo =
                                              proxyListSnapshot.data[index];

                                          return ProxyRadioListTile(
                                            title: proxyInfo.name ??
                                                proxyInfo.hostPort,
                                            value: proxyInfo.hostPort,
                                            groupValue:
                                                actualProxySnapshot.data,
                                            onChanged:
                                                proxyListBloc.setActualProxy,
                                            connectionCheckResultController:
                                                proxyInfo
                                                    .connectionCheckResultController,
                                            onDelete: proxyInfo.isDeletable
                                                ? (proxyHost) {
                                                    proxyListBloc
                                                        .removeFromProxyList(
                                                            proxyHost);
                                                    if (actualProxySnapshot
                                                            .data ==
                                                        proxyHost) {
                                                      proxyListBloc
                                                          .setActualProxy('');
                                                    }
                                                  }
                                                : null,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              Divider(),
                              GetNewProxyTile(
                                callback: proxyListBloc.addToProxyList,
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
                                  var userProxy = await AddCustomProxyDialog()
                                      .show(context);
                                  if (userProxy != null &&
                                      userProxy.isNotEmpty) {
                                    proxyListBloc.addToProxyList(userProxy);
                                    proxyListBloc.setActualProxy(userProxy);
                                  }
                                },
                              ),
                            ],
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
        selectedNavItemController: selectedNavItemController,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     try {
      //       var nativeDirPath = await UtopicTorOnionProxy.nativeLibraryDir();
      //       var nativeDir = Directory(nativeDirPath);
      //       ToastManager().showToast('nativeDir = $nativeDirPath');
      //       if (nativeDir.listSync().isEmpty) {
      //         ToastManager().showToast('empty nativeDir');
      //       }
      //       nativeDir.list().forEach((element) {
      //         print(element.path);
      //         ToastManager().showToast(element.path);
      //       });
      //     } catch (e) {
      //       print(e.toString());
      //       ToastManager().showToast(e.toString());
      //     }
      //   },
      // ),
    );
  }
}
