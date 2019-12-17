library directory_picker;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'directory_list.dart';

class DirectoryPicker {
  /// Opens a dialog to allow user to pick a directory.
  ///
  /// If [message] is non null then it is rendered when user denies to give
  /// external storage permission. A default message will be used if [message]
  /// is not specified. [rootDirectory] is the initial directory whose
  /// sub directories are shown for picking
  ///
  /// If [allowFolderCreation] is true then user will be allowed to create
  /// new folders directly from the picker. Make sure that you add write
  /// permission to manifest if you want to support folder creationa
  static Future<Directory> pick(
      {bool allowFolderCreation = false,
      @required BuildContext context,
      bool barrierDismissible = true,
      Color backgroundColor,
      @required Directory rootDirectory,
      String message,
      ShapeBorder shape}) async {
    assert(context != null, 'A non null context is required');

    if (Platform.isAndroid) {
      Directory directory = await showDialog<Directory>(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (BuildContext context) {
            return DirectoryPickerData(
                allowFolderCreation: allowFolderCreation,
                backgroundColor: backgroundColor,
                child: _DirectoryPickerDialog(),
                message: message,
                rootDirectory: rootDirectory,
                shape: shape);
          });

      return directory;
    } else {
      throw UnsupportedError('DirectoryPicker is only supported on android!');
    }
  }
}

class DirectoryPickerData extends InheritedWidget {
  final bool allowFolderCreation;
  final Color backgroundColor;
  final String message;
  final Directory rootDirectory;
  final ShapeBorder shape;

  DirectoryPickerData(
      {Widget child,
      this.allowFolderCreation,
      this.backgroundColor,
      this.message,
      this.rootDirectory,
      this.shape})
      : super(child: child);

  static DirectoryPickerData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DirectoryPickerData>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

class _DirectoryPickerDialog extends StatefulWidget {
  @override
  _DirectoryPickerDialogState createState() => _DirectoryPickerDialogState();
}

class _DirectoryPickerDialogState extends State<_DirectoryPickerDialog>
    with WidgetsBindingObserver {
  static final double spacing = 8;
  static final PermissionGroup requiredPermission = PermissionGroup.storage;

  bool canPrompt = true;
  bool checkingForPermission = false;
  PermissionStatus status;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero).then((_) => _requestPermission());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _getPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// If silent is true then below function will not try to request permission
  /// if permission is not granter
  Future<void> _getPermissionStatus() async {
    PermissionStatus updatedStatus =
        await PermissionHandler().checkPermissionStatus(requiredPermission);
    final updatedCanPrompt = await PermissionHandler()
      .shouldShowRequestPermissionRationale(requiredPermission);

    setState(() {
      canPrompt = updatedCanPrompt;
      status = updatedStatus;
    });
  }

  Future<void> _requestPermission() async {
    if (canPrompt) {
      final updatedStatusMap =
          await PermissionHandler().requestPermissions([requiredPermission]);
      final updatedCanPrompt = await PermissionHandler()
          .shouldShowRequestPermissionRationale(requiredPermission);

      setState(() {
        status = updatedStatusMap[requiredPermission];
        canPrompt = updatedCanPrompt;
      });
    } else {
      await PermissionHandler().openAppSettings();
    }
  }

  Widget _buildBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (status == null) {
      return Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Column(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: spacing),
              Text('Проверка разрешений', textAlign: TextAlign.center)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
          ));
    } else if (status == PermissionStatus.granted) {
      return DirectoryList();
    } else if (status == PermissionStatus.disabled) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Text(
            'Доступ к памяти устройства отключен',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Column(
            children: <Widget>[
              Text(message, textAlign: TextAlign.center),
              SizedBox(height: spacing),
              RaisedButton(
                  child: Text('Разрешение предоставлено'),
                  color: theme.primaryColor,
                  onPressed: _requestPermission)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: data.backgroundColor,
      child: _buildBody(context),
      shape: data.shape,
    );
  }

  DirectoryPickerData get data => DirectoryPickerData.of(context);

  String get message {
    if (data.message == null) {
      return 'Приложению необходим доступ к памяти телефона для загрузки книг';
    } else {
      return data.message;
    }
  }
}