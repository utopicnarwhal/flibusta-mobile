import 'package:flibusta/ds_controls/ui/buttons/raised_button.dart';
import 'package:flutter/material.dart';

class AddCustomProxyDialog {
  Future<String> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController proxyHostController =
            TextEditingController();
        return SimpleDialog(
          title: Text('Добавить свой HTTP-прокси'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: proxyHostController,
                autofocus: true,
                onEditingComplete: () {
                  Navigator.pop(
                    context,
                    proxyHostController.text,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DsRaisedButton(
                  child: Text('Добавить'),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      proxyHostController.text,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
