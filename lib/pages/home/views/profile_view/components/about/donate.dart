import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';

class DonatePage extends StatelessWidget {
  static const String routeName = '/Donate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DsAppBar(title: Text('Поддержать разработчика')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, packageInfo) {
          return ListView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            addSemanticIndexes: false,
            padding: EdgeInsets.symmetric(vertical: 20),
            children: [
              Divider(),
              Material(
                type: MaterialType.card,
                borderRadius: BorderRadius.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text('Сбербанк'),
                      subtitle: Text('4276 3801 2889 9718'),
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: '4276380128899718'),
                        );
                        ToastUtils.showToast(
                          'Номер карты скопирован в буфер обмена',
                        );
                      },
                      trailing: Icon(
                        FontAwesomeIcons.clipboard,
                        size: 30.0,
                      ),
                    ),
                    Divider(indent: 70),
                    ListTile(
                      title: Text('Рокетбанк'),
                      subtitle: Text('5321 3045 5409 9306'),
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: '5321304554099306'),
                        );
                        ToastUtils.showToast(
                          'Номер карты скопирован в буфер обмена',
                        );
                      },
                      trailing: Icon(
                        FontAwesomeIcons.clipboard,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
