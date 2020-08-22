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

              var status = serverStatusResultSnapshot.data?.status;

              if (!serverStatusResultSnapshot.hasData) {
                siteStatusIcon = SizedBox(
                  height: 32,
                  width: 32,
                  child: DsCircularProgressIndicator(),
                );
              } else if (status != null && status['isDown'] == false) {
                siteStatusIcon = Icon(
                  FontAwesomeIcons.check,
                  color: Colors.green,
                  size: 32,
                );
              } else if (status != null && status['isDown'] == true) {
                siteStatusIcon = Icon(
                  FontAwesomeIcons.ban,
                  color: Colors.red,
                  size: 32,
                );
              } else if (serverStatusResultSnapshot.data?.error != null) {
                siteStatusIcon = Icon(
                  FontAwesomeIcons.question,
                  color: Theme.of(context).disabledColor,
                  size: 32,
                );
              }

              return ListTile(
                title: Text('Состояние сайта:'),
                subtitle: Text(
                  status != null
                      ? status['statusText']
                      : (serverStatusResultSnapshot.data?.error != null
                          ? 'Неизвестно'
                          : 'Проверка...'),
                ),
                leading: siteStatusIcon,
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
