import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final bool showIcon;
  final String errorMessage;
  final bool showTextToCheckInternet;
  final void Function() onTryAgain;

  const ErrorScreen({
    Key key,
    this.errorMessage,
    this.showIcon = true,
    this.showTextToCheckInternet = true,
    this.onTryAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showIcon)
          Icon(
            EvaIcons.alertCircleOutline,
            color: kSecondaryColor(context),
            size: MediaQuery.of(context).size.width / 3,
          ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        if (showTextToCheckInternet)
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Пожалуйста, проверьте свое подключение к${'\u00A0'}интернету и работоспособность прокси.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption.copyWith(
                    fontSize: 15,
                  ),
            ),
          ),
        if (onTryAgain != null)
          DsOutlineButton(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(12),
            child: Text('Повторить'),
            onPressed: onTryAgain,
          ),
      ],
    );
  }
}
