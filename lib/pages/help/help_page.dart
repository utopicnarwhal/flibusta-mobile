import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatefulWidget {
  static const routeName = "/Help";

  @override
  createState() => HelpState();
}

class HelpState extends State<Help> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Text("О приложении"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.envelopeOpenText,
                          size: 30.0,
                        ),
                      ],
                    ),
                    title: Text('Разработчик'),
                    subtitle: Text(
                      'Данилов Сергей (@utopicnarwhal)\ngigok@bk.ru',
                    ),
                    isThreeLine: true,
                    onTap: () async {
                      launch('mailto:gigok@bk.ru');
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    trailing: SvgPicture.asset(
                      'assets/img/4pda_logo.svg',
                      color: Colors.grey,
                      height: 30,
                      width: 30,
                    ),
                    title: Text('Тема на 4PDA'),
                    subtitle: Text(
                      'http://4pda.ru/forum/',
                    ),
                    onTap: () async {
                      if (await canLaunch(
                          'http://4pda.ru/forum/index.php?showtopic=964348')) {
                        launch(
                            'http://4pda.ru/forum/index.php?showtopic=964348');
                      }
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.github,
                          size: 30.0,
                        ),
                      ],
                    ),
                    title: Text('Репозиторий Github'),
                    subtitle: Text('github.com/utopicnarwhal/FlibustaApp'),
                    onTap: () async {
                      await launch(
                          'https://github.com/utopicnarwhal/FlibustaApp');
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                'Поддержать разработчика приложения:',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              elevation: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Сбербанк'),
                    subtitle: Text('4276 3801 2889 9718'),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: '4276380128899718'));
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Номер карты скопирован в буфер обмена'),
                      ));
                    },
                    trailing: Icon(
                      FontAwesomeIcons.clipboard,
                      size: 30.0,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    title: Text('Рокетбанк'),
                    subtitle: Text('5321 3045 5409 9306'),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: '5321304554099306'));
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text('Номер карты скопирован в буфер обмена'),
                      ));
                    },
                    trailing: Icon(
                      FontAwesomeIcons.clipboard,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.0),
          ],
        ),
      ),
    );
  }
}
