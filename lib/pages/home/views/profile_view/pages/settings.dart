import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/components/directory_picker/directory_picker.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/dynamic_theme_mode.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/model/enums/sortBooksByEnum.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flibusta/utils/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/Settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController hostController;

  @override
  void initState() {
    super.initState();
    hostController = TextEditingController();
  }

  @override
  void dispose() {
    hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Divider(),
      FutureBuilder<ThemeMode>(
        future: DynamicThemeMode.of(context).loadThemeMode(),
        builder: (context, themeModeSnapshot) {
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(EvaIcons.colorPaletteOutline, size: 26.0),
              ],
            ),
            title: Text('Тема'),
            subtitle: Text(
              _themeModeToString(themeModeSnapshot.data),
            ),
            trailing: kIconArrowForward,
            onTap: () async {
              if (Platform.isIOS) {
                await showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      actions: ThemeMode.values.map((themeMode) {
                        return CupertinoActionSheetAction(
                          onPressed: () {
                            DynamicThemeMode.of(context)
                                .setThemeMode(themeMode);
                            Navigator.of(context).pop();
                          },
                          child: Text(_themeModeToString(themeMode)),
                        );
                      }).toList(),
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Отмена'),
                      ),
                    );
                  },
                );
              } else {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text('Выбрать тему'),
                      children: [
                        ...ThemeMode.values.map((themeMode) {
                          return RadioListTile(
                            onChanged: (newThemeMode) {
                              DynamicThemeMode.of(context)
                                  .setThemeMode(newThemeMode);
                              Navigator.of(context).pop();
                            },
                            groupValue: themeModeSnapshot.data,
                            value: themeMode,
                            title: Text(_themeModeToString(themeMode)),
                          );
                        }).toList(),
                        ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Отмена'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
      Divider(indent: 72),
      FutureBuilder<Directory>(
        future: LocalStorage().getBooksDirectory(),
        builder: (context, saveBooksDir) {
          var hasData =
              saveBooksDir.hasData && saveBooksDir.data?.path?.isEmpty == false;
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.folder, size: 30.0),
              ],
            ),
            title: Text('Папка для загрузки книг'),
            isThreeLine: true,
            subtitle: Text(
              hasData ? (saveBooksDir.data.path) : '',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
            onTap:
                hasData ? () => _openSaveBooksDirectoryPicker(context) : null,
          );
        },
      ),
      Divider(indent: 72),
      FutureBuilder<String>(
        future: LocalStorage().getHostAddress(),
        builder: (context, hostAddressSnapshot) {
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.server, size: 26.0),
              ],
            ),
            title: Text('Адрес сайта'),
            subtitle: Text(
              hostAddressSnapshot.data ?? '',
            ),
            trailing: kIconArrowForward,
            onTap: () async {
              var result = await showDialog<String>(
                context: context,
                builder: (context) {
                  hostController.text = hostAddressSnapshot.data ?? '';

                  return SimpleDialog(
                    title: Text('Адрес сайта'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: hostController,
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Отмена'),
                          ),
                          FlatButton(
                            child: Text('Применить'),
                            onPressed: () async {
                              var value = hostController.text;
                              if (value == null) {
                                return;
                              }
                              if (!await canLaunch('https://$value')) {
                                DialogUtils.simpleAlert(context,
                                    'Извините, но этот путь нельзя открыть');
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
                              Navigator.of(context).pop(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );

              if (result == null || result == hostAddressSnapshot.data) {
                return;
              }
              await LocalStorage().setHostAddress(result);
              setState(() {});
            },
          );
        },
      ),
      Divider(indent: 72),
      FutureBuilder<String>(
        future: LocalStorage().getPreferredBookExt(),
        builder: (context, preferredBookExtSnapshot) {
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.fileDownload, size: 26.0),
              ],
            ),
            title: Text('Предпочитаемый формат книги'),
            subtitle: Text(
              preferredBookExtSnapshot.data ?? 'Спрашивать меня при скачивании',
            ),
            trailing: kIconArrowForward,
            onTap: () async {
              var result = await showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(
                        'Выберите предпочитаемый формат книги для скачивания'),
                    children: [
                      ...[
                        'fb2',
                        'epub',
                        'mobi',
                        'Спрашивать меня при скачивании'
                      ].map((fileExtension) {
                        String value;
                        if (fileExtension != 'Спрашивать меня при скачивании') {
                          value = fileExtension;
                        }
                        return RadioListTile<String>(
                          onChanged: (_) {
                            Navigator.of(context).pop(fileExtension);
                          },
                          groupValue: preferredBookExtSnapshot.data,
                          value: value,
                          title: Text(fileExtension),
                        );
                      }).toList(),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Отмена'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
              if (result == null) {
                return;
              }
              if (result == 'Спрашивать меня при скачивании') {
                result = null;
              }
              await LocalStorage().setPreferredBookExt(result);
              setState(() {});
            },
          );
        },
      ),
      Divider(indent: 72),
      FutureBuilder<SortBooksBy>(
        future: LocalStorage().getPreferredAuthorBookSort(),
        builder: (context, preferredSortBooksBySnapshot) {
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.sort, size: 26.0),
              ],
            ),
            title: Text('Сортировка книг автора по'),
            subtitle: Text(
              sortBooksByToString(preferredSortBooksBySnapshot.data),
            ),
            trailing: kIconArrowForward,
            onTap: () async {
              var result = await showDialog<SortBooksBy>(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text(
                      'Выберите предпочитаемую сортировку книг автора',
                    ),
                    children: [
                      ...SortBooksBy.values.map((sortBooksBy) {
                        SortBooksBy value;
                        if (sortBooksBy != null) {
                          value = sortBooksBy;
                        }
                        return RadioListTile<SortBooksBy>(
                          onChanged: (_) {
                            Navigator.of(context).pop(sortBooksBy);
                          },
                          groupValue: preferredSortBooksBySnapshot.data,
                          value: value,
                          title: Text(sortBooksByToString(sortBooksBy)),
                        );
                      }).toList(),
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Отмена'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
              if (result == null) {
                return;
              }
              await LocalStorage().setPreferredAuthorBookSort(result);
              setState(() {});
            },
          );
        },
      ),
      Divider(indent: 72),
      ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(FontAwesomeIcons.trash, size: 24.0),
          ],
        ),
        title: Text('Очистить историю поиска'),
        onTap: () {
          LocalStorage().setPreviousBookSearches([]);
        },
      ),
      Divider(indent: 72),
      ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(FontAwesomeIcons.trash, size: 24.0),
          ],
        ),
        title: Text('Очистить список скачанных книг'),
        onTap: () {
          LocalStorage().clearDownloadedBook();
        },
      ),
      Divider(),
    ];

    return Scaffold(
      key: scaffoldKey,
      appBar: DsAppBar(title: Text('Настройки')),
      body: SafeArea(
        child: ListView.builder(
          physics: kBouncingAlwaysScrollableScrollPhysics,
          addSemanticIndexes: false,
          padding: EdgeInsets.only(top: 20.0),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return Material(
              type: MaterialType.card,
              borderRadius: BorderRadius.zero,
              child: children[index],
            );
          },
        ),
      ),
    );
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return 'Темная';
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.system:
        return 'По умолчанию';
      default:
        return '';
    }
  }

  void _openSaveBooksDirectoryPicker(BuildContext context) async {
    var currentSaveBooksDir = await LocalStorage().getBooksDirectory();

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
      rootDirectory: currentSaveBooksDir,
    );

    if (newDirectory != null) {
      await LocalStorage().setBooksDirectory(newDirectory);
      setState(() {});
    }
  }
}
