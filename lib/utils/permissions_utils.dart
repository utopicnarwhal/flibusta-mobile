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
  static _MessageMap _mapPermissionToMessage(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность работы с камерой',
          noAccess: 'Нет доступа к камере',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к камере?',
          fail: 'Доступ к камере не предоставлен',
        );
      case Permission.storage:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность работы с памятью',
          noAccess: 'Нет доступа к памяти',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к памяти?',
          fail: 'Доступ к памяти не предоставлен',
        );
      case Permission.photos:
        return _MessageMap(
          disabled:
              'На вашем устройстве отключена возможность работы с галереей',
          noAccess: 'Нет доступа к галерее',
          toSettings:
              'Перейти в настройки, чтобы предоставить доступ к галерее?',
          fail: 'Доступ к галарее не предоставлен',
        );
      case Permission.notification:
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
      BuildContext context, Permission permission) async {
    var permissionStatus = await permission.request();

    final messageMap = _mapPermissionToMessage(permission);
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
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.undetermined:
        var permissionNames = await permission.request();

        if (permissionNames == PermissionStatus.granted) {
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
          await openAppSettings();
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
