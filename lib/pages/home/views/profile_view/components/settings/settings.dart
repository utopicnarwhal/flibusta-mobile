import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/components/directory_picker/directory_picker.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/dynamic_theme_mode.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/Settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

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
      FutureBuilder<bool>(
        future: LocalStorage().getShowAdditionalBookInfo(),
        builder: (context, showAdditionalBookInfo) {
          return SwitchListTile(
            title: Text(
              "Показывать информацию о книге полностью",
            ),
            secondary: Icon(FontAwesomeIcons.bookOpen),
            value: showAdditionalBookInfo?.data ?? false,
            onChanged: (value) async {
              await LocalStorage().setShowAdditionalBookInfo(value);
              setState(() {});
            },
          );
        },
      ),
      Divider(),
    ];

    return Scaffold(
      key: scaffoldKey,
      appBar: DsAppBar(title: Text('Настройки')),
      body: SafeArea(
        child: ListView?.builder(
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