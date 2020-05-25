import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/dialog_utils.dart';
import 'package:utopic_toast/utopic_toast.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroPage extends StatelessWidget {
  static const routeName = '/Intro';

  @override
  Widget build(BuildContext context) {
    final List<Slide> slides = [
      Slide(
        title: 'Добро пожаловать!',
        maxLineTitle: 3,
        styleTitle: Theme.of(context).textTheme.headline4,
        centerWidget: Center(
          child: FlibustaLogo(
            sideHeight: MediaQuery.of(context).size.width / 2,
          ),
        ),
        styleDescription: Theme.of(context).textTheme.bodyText2,
        backgroundColor: Colors.transparent,
      ),
      Slide(
        title: 'Отказ от ответственности',
        maxLineTitle: 3,
        styleTitle: Theme.of(context).textTheme.headline4,
        widgetDescription: Text(
          'ПРОДОЛЖАЯ ПОЛЬЗОВАТЬСЯ ДАННЫМ ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ, ВЫ СОГЛАШАЕТЕСЬ С ТЕМ, '
          'ЧТО ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, '
          'ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ ГАРАНТИИ ТОВАРНОЙ ПРИГОДНОСТИ, '
          'СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ НАРУШЕНИЙ, НО НЕ ОГРАНИЧИВАЯСЬ ИМИ. '
          'НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО КАКИМ-ЛИБО ИСКАМ, '
          'ЗА УЩЕРБ ИЛИ ПО ИНЫМ ТРЕБОВАНИЯМ, В ТОМ ЧИСЛЕ, ПРИ ДЕЙСТВИИ КОНТРАКТА, ДЕЛИКТЕ ИЛИ ИНОЙ СИТУАЦИИ, '
          'ВОЗНИКШИМ ИЗ-ЗА ИСПОЛЬЗОВАНИЯ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫХ ДЕЙСТВИЙ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.',
          textAlign: TextAlign.justify,
        ),
        centerWidget: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: AspectRatio(
            aspectRatio: 375 / 150,
            child: FlareActor(
              'assets/animations/floating_document.flr',
              fit: BoxFit.fitWidth,
              animation: 'Animations',
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      Slide(
        title: 'Поддержка',
        styleTitle: Theme.of(context).textTheme.headline4,
        centerWidget: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 150),
          child: AspectRatio(
            aspectRatio: 1,
            child: FlareActor(
              'assets/animations/like.flr',
              fit: BoxFit.fitWidth,
              animation: 'Animations',
            ),
          ),
        ),
        description: """
Данное приложение было, есть и будет бесплатным, и в нём никогда не появится реклама. Если Вам вдруг захотелось поддержать разработчика отзывом, помощью в разработке или деньгами, то все ссылки находятся во вкладке 'О приложении'.

Приятного пользования приложением!
              """,
        styleDescription: Theme.of(context).textTheme.bodyText2,
        backgroundColor: Colors.transparent,
      ),
      Slide(
        title: 'Укажите адрес сайта, к которому хотите подключиться',
        styleTitle: Theme.of(context).textTheme.headline5,
        maxLineTitle: 4,
        centerWidget: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: AspectRatio(
            aspectRatio: 1.2 / 1,
            child: FlareActor(
              'assets/animations/roskomnadzor.flr',
              fit: BoxFit.fitWidth,
              animation: 'Animations',
            ),
          ),
        ),
        widgetDescription: _OpenSiteBlock(),
        backgroundColor: Colors.transparent,
      ),
    ];

    return IntroSlider(
      backgroundColorAllSlides: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).cardColor
          : Theme.of(context).scaffoldBackgroundColor,
      slides: slides,
      styleNameDoneBtn: Theme.of(context).textTheme.button,
      styleNamePrevBtn: Theme.of(context).textTheme.button,
      styleNameSkipBtn: Theme.of(context).textTheme.button,
      nameNextBtn: 'Далее',
      namePrevBtn: 'Назад',
      nameDoneBtn: '',
      isShowSkipBtn: false,
      isShowPrevBtn: true,
      isShowDoneBtn: true,
      typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,
    );
  }
}

class _OpenSiteBlock extends StatefulWidget {
  @override
  _OpenSiteBlockState createState() => _OpenSiteBlockState();
}

class _OpenSiteBlockState extends State<_OpenSiteBlock> {
  TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Чтобы это приложение не было заблокировано на Play Market, Вам необходимо самим ввести сайт, которой хотите открыть. '
          'Это приложение теперь, как любой бразуер, '
          'просто получает HTML страницу, по указанному адресу, обрабатывает её и отображает. Отправить запрос на блокировку этого приложения '
          'так же бессмысленно, как отправить запрос на блокировку Google Chrome или Opera browser.',
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
              helperText: 'Как пример: flibusta.is',
              hintText: 'Вы знаете, что сюда вписать'),
          onEditingComplete: _onSubmit,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text('Открыть сайт'),
            onPressed: _onSubmit,
          ),
        ),
      ],
    );
  }

  _onSubmit() async {
    final value = _urlController.text.replaceAll(' ', '');

    if (value != null && !await canLaunch('https://$value')) {
      ToastManager().showToast('Извините, но этот путь нельзя открыть');
      return;
    }

    if (value == 'flibusta.appspot.com') {
      DialogUtils.simpleAlert(
        context,
        'Предупреждение',
        content: Text(
          'Не рекомендую использовать данный сайт, так как он содержит некорректную верстку и перенаправляет на рекламу',
        ),
      );
      return;
    }

    if (value == 'flibusta.is') {
      ProxyHttpClient().setHostAddress(value);
      LocalStorage().setHostAddress(value);
      LocalStorage().setIntroCompleted();
      var turnProxyOn = await DialogUtils.confirmationDialog(
        context,
        'Включить прокси создателя приложения?',
        builder: (context) {
          return Text(
            'Вам необходимо включить прокси, если flibusta.is заблокирован в вашей стране. Но оно не работает на мобильном интернете Yota. Если вы знаете, как сделать так, чтобы оно работало, напишите мне на почту gigok@bk.ru',
          );
        },
        builderPadding: true,
        barrierDismissible: false,
      );
      if (turnProxyOn == true) {
        LocalStorage()
            .setActualProxy('flibustauser:ilovebooks@35.217.29.210:1194');
        ProxyHttpClient()
            .setProxy('flibustauser:ilovebooks@35.217.29.210:1194');
      }
      Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      return;
    }
    launch(
      'https://$value',
      forceWebView: true,
    );
  }

  @override
  void dispose() {
    _urlController?.dispose();
    super.dispose();
  }
}
