import 'package:dio/dio.dart';
import 'package:flibusta/model/connectionCheckResult.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:utopic_toast/utopic_toast.dart';

class ProxyRadioListTile extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final void Function(String) onChanged;
  final void Function(String) onDelete;
  final CancelToken cancelToken;
  final BehaviorSubject<ConnectionCheckResult> connectionCheckResultController;

  ProxyRadioListTile({
    Key key,
    @required this.title,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    @required this.connectionCheckResultController,
    this.onDelete,
    this.cancelToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: title));
        ToastManager().showToast('Прокси скопирован в буфер обмена');
      },
      child: RadioListTile(
        title: Text(title),
        subtitle: StreamBuilder<ConnectionCheckResult>(
          stream: connectionCheckResultController,
          builder: (context, connectionCheckResultSnapshot) {
            var subtitleText = '';
            var subtitleColor;
            if (connectionCheckResultSnapshot.hasData) {
              if (connectionCheckResultSnapshot.data.latency >= 0) {
                subtitleText =
                    'Доступно (пинг: ${connectionCheckResultSnapshot.data.latency.toString()}мс)';
                subtitleColor = Colors.green;
              } else {
                subtitleText =
                    'Ошибка. ${connectionCheckResultSnapshot.data.error}';
                subtitleColor = Colors.red;
              }
            } else {
              subtitleText = 'Проверка...';
              subtitleColor = Colors.grey[400];
            }

            return Text(
              subtitleText,
              style: TextStyle(color: subtitleColor),
            );
          },
        ),
        groupValue: groupValue,
        value: value,
        onChanged: onChanged,
        secondary: onDelete != null
            ? IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Удалить прокси',
                onPressed: () => onDelete(value),
              )
            : null,
      ),
    );
  }
}
