import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flibusta/components/directory_picker/directory_picker.dart';
import 'package:flibusta/pages/help/help_page.dart';
import 'package:flibusta/pages/home/components/home_bottom_nav_bar.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = "/Settings";

  final StreamController<int> selectedNavItemController;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SettingsPage({
    Key key,
    @required this.scaffoldKey,
    @required this.selectedNavItemController,
  }) : super(key: key);

  @override
  createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Text("Настройки"),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: Column(
              children: [
                ThemeSwitcher(),
                FutureBuilder<Directory>(
                  future: LocalStorage().getBooksDirectory(),
                  builder: (context, saveBooksDir) {
                    var hasData = saveBooksDir.hasData &&
                        saveBooksDir.data?.path?.isEmpty == false;
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
                      onTap: hasData
                          ? () => _openSaveBooksDirectoryPicker(context)
                          : null,
                    );
                  },
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, packageInfo) {
                    return ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.info, size: 26.0),
                        ],
                      ),
                      title: Text('О приложении'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                      subtitle: Text(
                        'Версия: ' + (packageInfo?.data?.version ?? ''),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(Help.routeName);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNavBar(
        key: Key('HomeBottomNavBar'),
        index: 4,
        onTap: (index) {
          widget.selectedNavItemController.add(index);
        },
      ),
    );
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

class ThemeSwitcher extends StatefulWidget {
  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        "Ночной режим",
      ),
      secondary: Icon(FontAwesomeIcons.solidMoon),
      value: DynamicTheme.of(context).brightness == Brightness.dark,
      onChanged: (value) {
        DynamicTheme.of(context)
            .setBrightness(value ? Brightness.dark : Brightness.light);
      },
    );
  }
}
