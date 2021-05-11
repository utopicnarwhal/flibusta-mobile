import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/services/server_status_checker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServerStatusCheckerCard extends StatelessWidget {
  final ServerStatusChecker serverStatusChecker;

  const ServerStatusCheckerCard({
    @required this.serverStatusChecker,
  });

  Widget build(BuildContext context) {
    return Card(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          StreamBuilder<ServerStatusResult>(
            stream: serverStatusChecker.serverStatusController,
            builder: (context, serverStatusResultSnapshot) {
              Widget siteStatusIcon = SizedBox();

              var statusResult = serverStatusResultSnapshot.data;

              if (!serverStatusResultSnapshot.hasData) {
                siteStatusIcon = SizedBox(
                  height: 32,
                  width: 32,
                  child: DsCircularProgressIndicator(),
                );
              } else if (statusResult.isDown == false) {
                siteStatusIcon = Icon(
                  FontAwesomeIcons.check,
                  color: Colors.green,
                  size: 34,
                );
              } else if (statusResult.isDown == true) {
                siteStatusIcon = Icon(
                  FontAwesomeIcons.ban,
                  color: Colors.red,
                  size: 34,
                );
              } else if (statusResult.isDown == null || statusResult.error != null) {
                siteStatusIcon = Icon(
                  FontAwesomeIcons.question,
                  color: Theme.of(context).disabledColor,
                  size: 34,
                );
              }

              return ListTile(
                title: Text('Состояние сайта:'),
                subtitle: Text(
                  statusResult != null
                      ? statusResult.statusText
                      : (serverStatusResultSnapshot.data?.error != null
                          ? 'Неизвестно'
                          : 'Проверка...'),
                ),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    siteStatusIcon,
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.redoAlt,
                  ),
                  tooltip: 'Обновить информацию',
                  color: Theme.of(context).iconTheme.color,
                  onPressed: serverStatusResultSnapshot.hasData
                      ? serverStatusChecker.check
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
