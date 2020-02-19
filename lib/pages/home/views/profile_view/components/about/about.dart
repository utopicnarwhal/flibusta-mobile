import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/pages/home/views/profile_view/components/about/donate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                    FlibustaLogo(isIconLike: true),
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
                        'Данилов Сергей (@utopicnarwhal)\ngigok@bk.ru',
                      ),
                      onTap: () async {
                        launch('mailto:gigok@bk.ru');
                      },
                    ),
                    Divider(indent: 70),
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_FourPDAIcon()],
                      ),
                      title: Text('Тема на 4PDA'),
                      trailing: kIconArrowForward,
                      subtitle: Text('github.com/utopicnarwhal/FlibustaApp'),
                      onTap: () async {
                        await launch(
                            'https://github.com/utopicnarwhal/FlibustaApp');
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
                      subtitle: Text('github.com/utopicnarwhal/FlibustaApp'),
                      onTap: () async {
                        await launch(
                            'https://github.com/utopicnarwhal/FlibustaApp');
                      },
                    ),
                    Divider(indent: 70),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.piggyBank, size: 30.0),
                      title: Text('Поддержать разработчика'),
                      trailing: kIconArrowForward,
                      onTap: () {
                        Navigator.of(context).pushNamed(DonatePage.routeName);
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

class _FourPDAIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = Theme.of(context).iconTheme;

    final double iconOpacity =
        iconTheme.opacity ?? IconTheme.of(context).color.opacity;
    Color iconColor = iconTheme.color;
    if (iconOpacity != null && iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity * 0.7);

    return SvgPicture.asset(
      'assets/img/4pda_logo.svg',
      color: iconColor,
      height: 30,
      width: 30,
    );
  }
}
