import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPage extends StatefulWidget {
  static const routeName = '/Intro';
  @override
  createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final pages = [
      PageViewModel(
        title: 'Добро пожаловать!',
        image: Center(
          child: FlibustaLogo(
            sideHeight: MediaQuery.of(context).size.width / 2,
          ),
        ),
        bodyWidget: Container(),
      ),
      PageViewModel(
        title: 'Отказ от ответственности',
        bodyWidget: Text(
          'ПРОДОЛЖАЯ ПОЛЬЗОВАТЬСЯ ДАННЫМ ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ, ВЫ СОГЛАШАЕТЕСЬ С ТЕМ, ЧТО ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ ГАРАНТИИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ НАРУШЕНИЙ, НО НЕ ОГРАНИЧИВАЯСЬ ИМИ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО КАКИМ-ЛИБО ИСКАМ, ЗА УЩЕРБ ИЛИ ПО ИНЫМ ТРЕБОВАНИЯМ, В ТОМ ЧИСЛЕ, ПРИ ДЕЙСТВИИ КОНТРАКТА, ДЕЛИКТЕ ИЛИ ИНОЙ СИТУАЦИИ, ВОЗНИКШИМ ИЗ-ЗА ИСПОЛЬЗОВАНИЯ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫХ ДЕЙСТВИЙ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.',
          textAlign: TextAlign.justify,
        ),
        image: Container(
          width: MediaQuery.of(context).size.width / 4,
          height: MediaQuery.of(context).size.width / 4,
          child: FlareActor(
            'assets/animations/agreement.flr',
            animation: 'Animations',
          ),
        ),
      ),
      PageViewModel(
        title: 'ЧаВо',
        bodyWidget: Container(
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
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
      PageViewModel(
        title: 'Поддержка',
        bodyWidget: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Text(
            """
Данное приложение было, есть и будет бесплатным, и в нём никогда не появится реклама. Если Вам вдруг захотелось поддержать разработчика отзывом, помощью в разработке или деньгами, то все ссылки находятся во вкладке 'О приложении'.

Приятного пользования тестовой версией!
              """,
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    ];

    return IntroductionScreen(
      pages: pages,
      done: const Text('Готово', style: TextStyle(fontWeight: FontWeight.w600)),
      next: Text('Далее'),
      showSkipButton: false,
      showNextButton: true,
      onDone: () async {
        await LocalStorage().setIntroCompleted();
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      },
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).accentColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 6.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      curve: Curves.easeInOut,
    );
  }
}
