import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  static Future loadingDialog(BuildContext context, String title) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
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

  static Future<void> simpleAlert(BuildContext context, String title) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'ОК',
              ),
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
    bool barrierDismissible = true,
    String confirmString = 'ДА',
    String rejectString = 'НЕТ',
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          contentPadding: EdgeInsets.only(
            top: 16,
          ),
          content: builder != null ? builder(context) : null,
          actions: [
            FlatButton(
              child: Text(rejectString),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(confirmString),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
