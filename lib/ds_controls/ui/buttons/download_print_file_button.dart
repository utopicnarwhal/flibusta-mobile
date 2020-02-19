import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class DownloadPrintFileButton extends StatefulWidget {
  final String label;
  final void Function(Function(double) onProgress) onDownload;

  const DownloadPrintFileButton({
    Key key,
    this.label,
    this.onDownload,
  }) : super(key: key);

  @override
  _DownloadPrintFileButtonState createState() =>
      _DownloadPrintFileButtonState();
}

class _DownloadPrintFileButtonState extends State<DownloadPrintFileButton> {
  double downloadProgress;

  @override
  Widget build(BuildContext context) {
    var isDisabled = widget.onDownload == null;

    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minHeight: 50),
      child: ListTile(
        enabled: !isDisabled,
        title: Text(
          widget.label,
        ),
        onTap: () {
          setState(() => downloadProgress = -1);
          widget.onDownload(onDownloadProgress);
        },
        trailing: downloadProgress == null
            ? Icon(
                EvaIcons.downloadOutline,
                color: isDisabled
                    ? kDisabledFieldTextColor(context)
                    : kSecondaryColor(context),
              )
            : SizedBox(
                width: 24,
                height: 24,
                child: DsCircularProgressIndicator(
                  value: downloadProgress == -1 ? null : downloadProgress,
                ),
              ),
      ),
    );
  }

  void onDownloadProgress(double progress) {
    if (mounted) {
      setState(() {
        downloadProgress = progress;
      });
    }
  }
}
