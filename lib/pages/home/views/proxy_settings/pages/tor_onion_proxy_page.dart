import 'package:flibusta/blocs/tor_proxy/tor_proxy_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TorOnionProxyPage extends StatefulWidget {
  static const routeName = '/TorOnionProxy';

  @override
  _TorOnionProxyPageState createState() => _TorOnionProxyPageState();
}

class _TorOnionProxyPageState extends State<TorOnionProxyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DsAppBar(
        title: Text('Tor Onion Proxy'),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            addSemanticIndexes: false,
            padding: EdgeInsets.fromLTRB(0, 16, 0, 42),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Tor Onion Proxy позволяет использовать Onion версию сайта, с которой сняты ограничения на авторские права.',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Данная функция является экспериментальной, если найдете ошибку, то пишите мне на почту gigok@bk.ru',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              SizedBox(height: 16),
              BlocBuilder<TorProxyBloc, TorProxyState>(
                cubit: TorProxyBloc(),
                builder: (context, torProxyState) {
                  if (torProxyState is UnTorProxyState) {
                    return Center(
                      child: DsOutlineButton(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Запустить'),
                        onPressed: () {
                          TorProxyBloc().startTorProxy();
                        },
                      ),
                    );
                  } else if (torProxyState is InTorProxyState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Запущен на порту: ${torProxyState.port}'),
                        DsOutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Выключить'),
                          onPressed: () {
                            TorProxyBloc().stopTorProxy();
                          },
                        ),
                      ],
                    );
                  } else if (torProxyState is StartingTorProxyState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DsCircularProgressIndicator(),
                        DsOutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Остановить'),
                          onPressed: () {
                            TorProxyBloc().stopTorProxy();
                          },
                        ),
                      ],
                    );
                  } else if (torProxyState is ErrorTorProxyState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Произошла ошибка: ${torProxyState.error}'),
                        DsOutlineButton(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Проверить'),
                          onPressed: () async {
                            TorProxyBloc().stopTorProxy();
                          },
                        ),
                      ],
                    );
                  }
                  return SizedBox();
                },
              ),
              SizedBox(height: 16),
              Divider(),
              Material(
                type: MaterialType.card,
                borderRadius: BorderRadius.zero,
                child: CheckboxListTile(
                  value: true,
                  onChanged: null,
                  title: Text('Использовать Onion версию сайта'),
                  subtitle: Text(kFlibustaOnionUrl.replaceAll('http://', '')),
                ),
              ),
              Divider(),
              ClipRect(
                child: Banner(
                  location: BannerLocation.topEnd,
                  message: 'В работе',
                  child: Material(
                    type: MaterialType.card,
                    borderRadius: BorderRadius.zero,
                    child: ListTile(
                      title: Text('Автозапуск'),
                      subtitle: Text('Нет'),
                      trailing: kIconArrowForward,
                    ),
                  ),
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
