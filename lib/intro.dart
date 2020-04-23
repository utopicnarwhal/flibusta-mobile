import 'package:flare_flutter/flare_actor.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
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
        styleTitle: Theme.of(context).textTheme.display1,
        centerWidget: Center(
          child: FlibustaLogo(
            sideHeight: MediaQuery.of(context).size.width / 2,
          ),
        ),
        styleDescription: Theme.of(context).textTheme.body1,
        backgroundColor: Colors.transparent,
      ),
      Slide(
        title: 'Отказ от ответственности',
        maxLineTitle: 3,
        styleTitle: Theme.of(context).textTheme.display1,
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
        styleTitle: Theme.of(context).textTheme.display1,
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
        styleDescription: Theme.of(context).textTheme.body1,
        backgroundColor: Colors.transparent,
      ),
      Slide(
        title: 'Укажите адрес сайта, к которому хотите подключиться',
        styleTitle: Theme.of(context).textTheme.headline,
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
  bool loading = false;

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
        if (!loading)
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
                helperText: 'Как пример: flibusta.is',
                hintText: 'Вы знаете, что сюда вписать'),
            onEditingComplete: _onSubmit,
          ),
        if (!loading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text('Открыть сайт'),
              onPressed: _onSubmit,
            ),
          ),
        if (loading) DsCircularProgressIndicator(),
      ],
    );
  }

  _onSubmit() async {
    final value = _urlController.text.replaceAll(' ', '');

    if (value != null && !await canLaunch('https://$value')) {
      ToastManager().showToast('Извините, но этот путь нельзя открыть');
      return;
    }

    if (!mounted) return;
    setState(() {
      loading = true;
    });

    if (value == 'flibusta.is') {
      ProxyHttpClient().setHostAddress(value);
      LocalStorage().setHostAddress(value);
      LocalStorage().setIntroCompleted();
      Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      return;
    }
    launch(
      'https://$value',
      forceWebView: true,
    );

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _urlController?.dispose();
    super.dispose();
  }
}
