import 'package:flibusta/blocs/tor_proxy/tor_proxy_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/svg_icon.dart';
import 'package:flibusta/pages/home/views/proxy_settings/pages/tor_onion_proxy_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TorOnionProxyCard extends StatefulWidget {
  @override
  _TorOnionProxyCardState createState() => _TorOnionProxyCardState();
}

class _TorOnionProxyCardState extends State<TorOnionProxyCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        child: Banner(
          message: 'Тест',
          location: BannerLocation.topEnd,
          color: Color(0xFF7D4698),
          child: Material(
            type: MaterialType.card,
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(
                            assetPath: 'assets/img/tor_logo.svg',
                            size: 38,
                            color: Color(0xFF7D4698),
                          ),
                        ],
                      ),
                      title: Text('Onion Proxy'),
                    ),
                    BlocBuilder<TorProxyBloc, TorProxyState>(
                      cubit: TorProxyBloc(),
                      builder: (context, torProxyState) {
                        var stateString = 'Неизвестно';

                        if (torProxyState is UnTorProxyState) {
                          stateString = 'Выключен';
                        } else if (torProxyState is InTorProxyState) {
                          stateString = 'Включен';
                        } else if (torProxyState is StartingTorProxyState) {
                          stateString = 'Запускается';
                        } else if (torProxyState is ErrorTorProxyState) {
                          stateString = 'Ошибка';
                        }

                        return ListTile(
                          trailing: kIconArrowForward,
                          title: Text('Состояние:'),
                          subtitle: Text(stateString),
                        );
                      },
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed(TorOnionProxyPage.routeName);
              },
            ),
          ),
        ),
      ),
    );
  }
}
