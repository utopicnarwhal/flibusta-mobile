import 'dart:io';

import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  static Future loadingDialog(BuildContext context, String title) async {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title ?? ''),
            content: CupertinoActivityIndicator(),
          );
        },
      );
    }
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          title: Text(title ?? ''),
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: DsCircularProgressIndicator(),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> simpleAlert(
    BuildContext context,
    String title, {
    Widget content,
    String confirmText = 'Ок',
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title ?? ''),
            content: content,
            actions: [
              CupertinoDialogAction(
                child: Text(confirmText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title ?? '',
            style: TextStyle(
              fontSize: 16.0,
              color: kSecondaryColor(context),
            ),
          ),
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text(
                confirmText.toUpperCase(),
              ),
              textColor: kSecondaryColor(context),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> confirmationDialog(
    BuildContext context,
    String title, {
    Function(BuildContext context) builder,
    bool builderPadding = false,
    bool barrierDismissible = true,
    bool isDestructive = false,
    String confirmString = 'Да',
    String rejectString = 'Нет',
  }) async {
    if (Platform.isIOS) {
      return await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: builder != null ? builder(context) : null,
            actions: [
              CupertinoDialogAction(
                child: Text(rejectString),
                isDestructiveAction: false,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: Text(confirmString),
                isDestructiveAction: isDestructive,
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
    }
    return await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              color: kSecondaryColor(context),
            ),
          ),
          contentPadding: builderPadding
              ? EdgeInsets.only(
                  top: 16,
                  left: 24,
                  right: 24,
                )
              : EdgeInsets.only(
                  top: 16,
                ),
          content: builder != null ? builder(context) : null,
          actions: [
            FlatButton(
              child: Text(rejectString.toUpperCase()),
              textColor: kSecondaryColor(context),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(confirmString.toUpperCase()),
              textColor: kSecondaryColor(context),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  // static Future<Map<String, String>> chooseFilesFromStorage(
  //   BuildContext context, {
  //   bool multiple = true,
  // }) async {
  //   var fileExplorerFunc = (BuildContext context) async {
  //     var storageAccess = await PermissionsUtils.requestAccess(
  //       context,
  //       PermissionGroup.storage,
  //     );

  //     if (storageAccess != true) {
  //       Navigator.of(context).pop<Map<String, String>>(null);
  //       return;
  //     }

  //     Map<String, String> filePaths;
  //     if (multiple) {
  //       filePaths = await FilePicker.getMultiFilePath(type: FileType.any);
  //     } else {
  //       var filePath = await FilePicker.getFilePath(type: FileType.any);

  //       if (filePath != null) {
  //         var fileName = filePath?.split('/')?.last;
  //         filePaths = {fileName: filePath};
  //       }
  //     }
  //     Navigator.of(context).pop<Map<String, String>>(filePaths);
  //   };

  //   var galleyFunc = (BuildContext context) async {
  //     var photosAccess = false;
  //     if (Platform.isIOS) {
  //       photosAccess = await PermissionsUtils.requestAccess(
  //         context,
  //         PermissionGroup.photos,
  //       );
  //     } else {
  //       photosAccess = await PermissionsUtils.requestAccess(
  //         context,
  //         PermissionGroup.storage,
  //       );
  //     }

  //     if (photosAccess != true) {
  //       Navigator.of(context).pop<Map<String, String>>(null);
  //       return;
  //     }

  //     Map<String, String> filePaths;
  //     var file = await ImagePicker.pickImage(source: ImageSource.gallery);
  //     if (file?.path == null) {
  //       Navigator.of(context).pop<Map<String, String>>(null);
  //       return;
  //     }

  //     var fileName = file.path?.split('/')?.last;
  //     filePaths = {fileName: file.path};
  //     Navigator.of(context).pop<Map<String, String>>(filePaths);
  //   };

  //   var takeAPhotoFunc = (BuildContext context) async {
  //     var cameraAccess = await PermissionsUtils.requestAccess(
  //       context,
  //       PermissionGroup.camera,
  //     );

  //     if (cameraAccess != true) {
  //       Navigator.of(context).pop<Map<String, String>>(null);
  //       return;
  //     }

  //     if (Platform.isIOS) {
  //       showDialog(
  //         // workaround to this issue: https://github.com/flutter/flutter/issues/32896
  //         context: context,
  //         useRootNavigator: true,
  //         barrierDismissible: false,
  //         builder: (BuildContext context) {
  //           return Container();
  //         },
  //       );
  //     }
  //     var image = await ImagePicker.pickImage(source: ImageSource.camera);
  //     if (Platform.isIOS) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }

  //     if (image?.path == null) {
  //       Navigator.of(context).pop<Map<String, String>>(null);
  //       return;
  //     }
  //     Navigator.of(context).pop<Map<String, String>>(
  //       {'Фото_с_камеры.jpg': image.path},
  //     );
  //   };

  //   if (Platform.isIOS) {
  //     final iosInfo = await DeviceInfoPlugin().iosInfo;
  //     final systemVersionNumbers = iosInfo.systemVersion?.split('.');
  //     final systemVersionFirstNumber = systemVersionNumbers?.isEmpty == false
  //         ? int.tryParse(systemVersionNumbers.first)
  //         : null;

  //     return await showCupertinoModalPopup<Map<String, String>>(
  //       context: context,
  //       builder: (context) {
  //         return CupertinoActionSheet(
  //           actions: <Widget>[
  //             CupertinoActionSheetAction(
  //               onPressed: () => takeAPhotoFunc(context),
  //               child: Text('Камера'),
  //             ),
  //             CupertinoActionSheetAction(
  //               onPressed: () => galleyFunc(context),
  //               child: Text('Фото'),
  //             ),
  //             if (systemVersionFirstNumber != null &&
  //                 systemVersionFirstNumber >= 11)
  //               CupertinoActionSheetAction(
  //                 onPressed: () => fileExplorerFunc(context),
  //                 child: Text('Файл'),
  //               ),
  //           ],
  //           cancelButton: CupertinoActionSheetAction(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Отмена'),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //   return await showDialog<Map<String, String>>(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         title: Text('Загрузить из:'),
  //         children: <Widget>[
  //           ListTile(
  //             leading: Icon(EvaIcons.camera),
  //             title: Text('Сделать фото'),
  //             onTap: () => takeAPhotoFunc(context),
  //           ),
  //           ListTile(
  //             leading: Icon(FontAwesomeIcons.fileImage),
  //             title: Text('Выбрать из галереи'),
  //             onTap: () => galleyFunc(context),
  //           ),
  //           ListTile(
  //             leading: Icon(FontAwesomeIcons.solidFolderOpen),
  //             title: Text('Выбрать через проводник'),
  //             onTap: () => fileExplorerFunc(context),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
