import 'dart:io';

import 'package:flibusta/components/directory_picker/directory_picker.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/pages/home/home_page.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/dialog_utils.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:utopic_toast/utopic_toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroPage extends StatelessWidget {
  static const routeName = '/Intro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            child: SingleChildScrollView(
              physics: kBouncingAlwaysScrollableScrollPhysics,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: _OpenSiteBlock(),
              ),
            ),
          );
        },
      ),
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
        SizedBox(height: 100),
        FlibustaLogo(sideHeight: 140),
        SizedBox(height: 20),
        Text(
          'Чтобы приложение не заблокировали в Play Market, Вам необходимо самим ввести URL адрес в поле снизу. \n\nНапример: flibusta.is',
        ),
        SizedBox(height: 20),
        TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Адрес для подключения',
            ),
            onEditingComplete: _onSubmit,
          ),
          hideOnEmpty: true,
          hideOnError: true,
          hideOnLoading: true,
          hideSuggestionsOnKeyboardHide: true,
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(
              kCardBorderRadius,
            ),
          ),
          suggestionsCallback: (String text) {
            if (text.startsWith('f')) {
              return ['flibusta.is'];
            }
            return [];
          },
          itemBuilder: (context, text) {
            return ListTile(
              title: Text(text ?? ''),
            );
          },
          onSuggestionSelected: (text) => _urlController.text = text,
        ),
        SizedBox(height: 16),
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

      var downloadPath = await LocalStorage().getBooksDirectory();

      var chooseDownloadPath = await DialogUtils.confirmationDialog(
        context,
        'Папка для загрузки книг',
        builder: (context) {
          return Text(
            'Сейчас файлы будут загружаться в папку "${downloadPath.path}". Хотите ли указать свой путь? Вы всегда можете изменить этот путь в настройках.',
          );
        },
        builderPadding: true,
        barrierDismissible: false,
      );

      if (chooseDownloadPath == true) {
        await showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text('Учтите'),
              contentPadding: EdgeInsets.fromLTRB(20, 12, 20, 16),
              children: <Widget>[
                Text(
                  'В следующем окне с выбором папки будут отображаться ТОЛЬКО папки (без каких-либо файлов). \nА также, если у Вас Android 4.4 или ниже, то не стоит менять этот параметр.',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: FlatButton(
                    child: Text('Понятно'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        );

        Directory newDirectory = await DirectoryPicker.pick(
          allowFolderCreation: true,
          context: context,
          rootDirectory: downloadPath,
        );

        if (newDirectory != null) {
          await LocalStorage().setBooksDirectory(newDirectory);
        }
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
