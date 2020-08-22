import 'dart:io';

import 'package:flibusta/blocs/tor_proxy/tor_proxy_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/svg_icon.dart';
import 'package:flibusta/pages/home/views/proxy_settings/pages/tor_onion_proxy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:utopic_toast/utopic_toast.dart';

class TorOnionProxyCard extends StatefulWidget {
  @override
  _TorOnionProxyCardState createState() => _TorOnionProxyCardState();
}

class _TorOnionProxyCardState extends State<TorOnionProxyCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Material(
        type: MaterialType.card,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(kCardBorderRadius),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(
                  assetPath: 'assets/img/tor_logo.svg',
                  size: 38,
                  color: kTorColor,
                ),
              ],
            ),
            title: Text('Onion Proxy'),
            subtitle: BlocBuilder<TorProxyBloc, TorProxyState>(
              cubit: TorProxyBloc(),
              builder: (context, torProxyState) {
                Widget stateWidget = Text('Неизвестно');

                if (torProxyState is UnTorProxyState) {
                  stateWidget = Text('Выключен');
                } else if (torProxyState is InTorProxyState) {
                  stateWidget = Text(
                    'Включен',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  );
                } else if (torProxyState is StartingTorProxyState) {
                  stateWidget = Text('Запускается');
                } else if (torProxyState is ErrorTorProxyState) {
                  stateWidget = Text(
                    'Ошибка',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  );
                }

                return stateWidget;
              },
            ),
            trailing: kIconArrowForward,
          ),
          onTap: () {
            if (Platform.isAndroid) {
              Navigator.of(context).pushNamed(TorOnionProxyPage.routeName);
              return;
            }
            ToastManager().showToast(
              'Данная функция доступна только на Android',
            );
          },
        ),
      ),
    );
  }
}
