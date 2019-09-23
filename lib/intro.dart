import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class IntroPage extends StatefulWidget {
  static const routeName = "/Intro";
  @override
  createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  final pages = [
    PageViewModel(
      pageColor: const Color(0xFF03A9F4),
      title: Container(),
      mainImage: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            'Добро пожаловать!',
            style: TextStyle(
              fontSize: 30.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(45.0, 45.0, 45.0, 34.0),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.beenhere,
              size: 100.0,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: Container(),
      bubble: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Icon(
          FontAwesomeIcons.solidHeart,
          color: Colors.red,
          size: 20.0,
        ),
      ),
      bubbleBackgroundColor: Colors.white,
    ),
    PageViewModel(
      pageColor: const Color(0xFF8BC34A),
      bubble: Icon(
        FontAwesomeIcons.handshake,
        size: 20.0,
        color: Colors.black,
      ),
      bubbleBackgroundColor: Colors.white,
      title: Text(
        'Отказ от ответственности',
        style: TextStyle(
          fontSize: 26.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      mainImage: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'ПРОДОЛЖАЯ ПОЛЬЗОВАТЬСЯ ДАННЫМ ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ, ВЫ СОГЛАШАЕТЕСЬ С ТЕМ, ЧТО ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ ГАРАНТИИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ НАРУШЕНИЙ, НО НЕ ОГРАНИЧИВАЯСЬ ИМИ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО КАКИМ-ЛИБО ИСКАМ, ЗА УЩЕРБ ИЛИ ПО ИНЫМ ТРЕБОВАНИЯМ, В ТОМ ЧИСЛЕ, ПРИ ДЕЙСТВИИ КОНТРАКТА, ДЕЛИКТЕ ИЛИ ИНОЙ СИТУАЦИИ, ВОЗНИКШИМ ИЗ-ЗА ИСПОЛЬЗОВАНИЯ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫХ ДЕЙСТВИЙ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Text(''),
    ),
    PageViewModel(
      pageColor: Colors.deepPurple,
      bubble: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Icon(
          FontAwesomeIcons.projectDiagram,
          color: Colors.lightBlue,
          size: 18.0,
        ),
      ),
      title: Text(
        'Прокси',
        style: TextStyle(
          fontSize: 32.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      bubbleBackgroundColor: Colors.white,
      mainImage: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  """
Если Ваш интернет-провайдер заблокировал интернет-ресурс 'flibusta.is', то Вы можете воспользоваться сервисом PubProxy API на странице 'Настройки прокси' c ограничением 50 запросов в день. Добавляйте прокси-сервера, пока не найдёте оптимальный для Вас вариант. Чем меньше пинг - тем лучше!
                  """,
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Text(''),
    ),
    PageViewModel(
      pageColor: Colors.cyan,
      bubble: Padding(
        padding: const EdgeInsets.only(bottom: 1.0, left: 1.0),
        child: Icon(
          FontAwesomeIcons.question,
          color: Colors.teal,
          size: 18.0,
        ),
      ),
      title: Text(
        'ЧаВо',
        style: TextStyle(
          fontSize: 32.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      bubbleBackgroundColor: Colors.white,
      mainImage: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  """
1. Почему ничего не работает?
Проверьте, что выбранный прокси-сервер работает и попробуйте ещё раз.
2. Куда сохраняются книги?
В настройках указан стандартный путь для сохранения, но его можно поменять.
                      """,
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Text(''),
    ),
    PageViewModel(
      pageColor: Colors.deepOrange.shade400,
      bubble: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Icon(
          FontAwesomeIcons.donate,
          color: Colors.pink,
          size: 18.0,
        ),
      ),
      title: Text(
        'Поддержка',
        style: TextStyle(
          fontSize: 32.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      bubbleBackgroundColor: Colors.white,
      mainImage: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  """
Данное приложение было, есть и будет бесплатным и в нём никогда не появится реклама. Если Вам вдруг захотелось поддержать разработчика отзывом, помощью в разработке или деньгами, то все ссылки находятся во вкладке 'О приложении'.

Приятного пользования тестовой версией!
                      """,
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Text(''),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroViewsFlutter(
      pages,
      doneText: Text('Готово'),
      nextText: Text('Далее'),
      showSkipButton: false,
      showNextButton: true,
      showBackButton: true,
      backText: Text('Назад'),
      columnMainAxisAlignment: MainAxisAlignment.center,
      onTapDoneButton: () async {
        await LocalStorage().setIntroCompleted();
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      },
      pageButtonTextStyles: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    );
  }
}
