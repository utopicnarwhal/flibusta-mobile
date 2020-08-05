import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/ds_controls/ui/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const String routeName = '/About';
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: DsAppBar(title: Text('О приложении')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, packageInfo) {
          return ListView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            addSemanticIndexes: false,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                child: Column(
                  children: [
                    Wrap(
                      runSpacing: 20,
                      spacing: 20,
                      children: <Widget>[
                        FlibustaLogo(isIconLike: true),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Material(
                            elevation: 8,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  Image.asset('assets/img/utopic_narwhal.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Версия ' + (packageInfo?.data?.version ?? ''),
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Divider(),
              Material(
                type: MaterialType.card,
                borderRadius: BorderRadius.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.envelopeOpenText,
                            size: 30.0,
                          ),
                        ],
                      ),
                      title: Text('Разработчик'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [kIconArrowForward],
                      ),
                      isThreeLine: true,
                      subtitle: Text(
                        'Данилов Сергей\ngigok@bk.ru',
                      ),
                      onTap: () async {
                        launch('mailto:gigok@bk.ru');
                      },
                    ),
                    Divider(indent: 70),
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.github,
                            size: 34.0,
                          ),
                        ],
                      ),
                      title: Text('Репозиторий Github'),
                      trailing: kIconArrowForward,
                      subtitle:
                          Text('github.com/utopicnarwhal/flibusta-mobile'),
                      onTap: () async {
                        await launch(
                            'https://github.com/utopicnarwhal/flibusta-mobile');
                      },
                    ),
                    Divider(indent: 70),
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(assetPath: 'assets/img/4pda_logo.svg'),
                        ],
                      ),
                      title: Text('Тема на 4PDA'),
                      trailing: kIconArrowForward,
                      onTap: () async {
                        await launch(
                            'https://4pda.ru/forum/index.php?showtopic=964348');
                      },
                    ),
                    Divider(indent: 70),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.donate, size: 30.0),
                      title: Text('Поддержать разработчика'),
                      trailing: kIconArrowForward,
                      onTap: () {
                        launch(
                          'https://gist.github.com/utopicnarwhal/1acebc04aafc1de5c3dc404480e999ff',
                          forceSafariVC: false,
                          forceWebView: false,
                        );
                      },
                    ),
                    Divider(indent: 70),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.solidFileAlt, size: 30.0),
                      title: Text('Лицензии'),
                      trailing: kIconArrowForward,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (context) {
                            var licensePage = LicensePage(
                              applicationName: 'Флибуста',
                              applicationIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: FlibustaLogo(isIconLike: true),
                                  ),
                                ],
                              ),
                              applicationVersion:
                                  packageInfo?.data?.version ?? '',
                            );
                            if (Theme.of(context).brightness ==
                                Brightness.dark) {
                              return licensePage;
                            }
                            return Theme(
                              data: ThemeData(primaryColor: Colors.white),
                              child: licensePage,
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 120),
            ],
          );
        },
      ),
    );
  }
}
