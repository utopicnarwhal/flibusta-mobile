import 'package:utopic_toast/utopic_toast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class _MessageMap {
  final String disabled;
  final String noAccess;
  final String toSettings;
  final String fail;

  _MessageMap({this.disabled, this.noAccess, this.toSettings, this.fail});

  bool get isAnyEmpty {
    return disabled?.isEmpty != false ||
        noAccess?.isEmpty != false ||
        toSettings?.isEmpty != false ||
        fail?.isEmpty != false;
  }
}

class PermissionsUtils {
  static _MessageMap _mapPermissionGroupToMessage(
      PermissionGroup permissionGroup) {
    switch (permissionGroup) {
      case PermissionGroup.camera:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность работы с камерой',
          noAccess: 'Нет доступа к камере',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к камере?',
          fail: 'Доступ к камере не предоставлен',
        );
      case PermissionGroup.storage:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность работы с памятью',
          noAccess: 'Нет доступа к памяти',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к памяти?',
          fail: 'Доступ к памяти не предоставлен',
        );
      case PermissionGroup.photos:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность работы с галереей',
          noAccess: 'Нет доступа к галерее',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к галерее?',
          fail: 'Доступ к галарее не предоставлен',
        );
      case PermissionGroup.notification:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность отправки уведомлений',
          noAccess: 'Нет доступа к отправке уведомлений',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к отправке уведомлений?',
          fail: 'Доступ к отправке уведомлений не предоставлен',
        );
      default:
    }
    return null;
  }

  static Future<bool> requestAccess(
      BuildContext context, PermissionGroup permissionGroup) async {
    var permissionStatus =
        await PermissionHandler().checkPermissionStatus(permissionGroup);

    final messageMap = _mapPermissionGroupToMessage(permissionGroup);
    if (messageMap.isAnyEmpty) {
      print('Нужно указать сообщения для данного разрешения');
      return false;
    }

    switch (permissionStatus) {
      case PermissionStatus.restricted:
        ToastManager().showToast(
          messageMap.disabled,
          type: ToastType.error,
        );
        break;
      case PermissionStatus.granted:
        return true;
        break;
      case PermissionStatus.denied:
      case PermissionStatus.neverAskAgain:
      case PermissionStatus.unknown:
        var permissionNames =
            await PermissionHandler().requestPermissions([permissionGroup]);

        if (permissionNames[permissionGroup] == PermissionStatus.granted) {
          return true;
        }

        bool result;
        if (context != null) {
          result = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                title: Text(messageMap.noAccess),
                content: Text(messageMap.toSettings),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Нет'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FlatButton(
                    child: Text('Да'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );
        }
        if (result == true) {
          await PermissionHandler().openAppSettings();
          return false;
        }

        ToastManager().showToast(
          messageMap.fail,
          type: ToastType.error,
        );
        break;
    }
    return false;
  }
}