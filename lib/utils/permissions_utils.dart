import 'package:flibusta/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtils {
  static Future<bool> storageAccess({
    BuildContext context,
  }) async {
    var permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    switch (permissionStatus) {
      case PermissionStatus.restricted:
        ToastUtils.showToast(
          'На вашем устройстве отключена возможность работы с памятью',
          type: ToastType.error,
        );
        break;
      case PermissionStatus.granted:
        return true;
        break;
      case PermissionStatus.denied:
      case PermissionStatus.neverAskAgain:
      case PermissionStatus.unknown:
        var permissionNames = await PermissionHandler()
            .requestPermissions([PermissionGroup.storage]);

        if (permissionNames[PermissionGroup.storage] ==
            PermissionStatus.granted) {
          return true;
        }

        bool result;
        if (context != null) {
          result = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return AlertDialog(
                title: Text('Нет доступа к памяти'),
                content: Text(
                    'Перейти в настройки, чтобы предоставить доступ к памяти?'),
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

        ToastUtils.showToast(
          'Не удалось сохранить файл, так как доступ к памяти не предоставлен',
          type: ToastType.error,
        );
        break;
    }
    return false;
  }
}
