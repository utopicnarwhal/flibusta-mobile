import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class DownloadEdcFileButton extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String leadId;
  final String fileName;
  final int docFolderType;
  final int edcType;

  const DownloadEdcFileButton({
    Key key,
    @required this.scaffoldKey,
    @required this.leadId,
    @required this.fileName,
    @required this.docFolderType,
    @required this.edcType,
  }) : super(key: key);

  @override
  _DownloadEdcFileButtonState createState() => _DownloadEdcFileButtonState();
}

class _DownloadEdcFileButtonState extends State<DownloadEdcFileButton> {
  double downloadProgress;

  @override
  Widget build(BuildContext context) {
    if (downloadProgress == null) {
      return IconButton(
        tooltip: 'Скачать',
        icon: Icon(EvaIcons.download),
        onPressed: () {},
        // onPressed: () => DocumentsService.downloadEdcFile(
        //   scaffoldKey: widget.scaffoldKey,
        //   leadId: widget.leadId,
        //   fileName: widget.fileName,
        //   docFolderType: widget.docFolderType,
        //   edcType: widget.edcType,
        //   onDownloadProgress: (downloadProgress) {
        //     if (mounted) {
        //       setState(() => this.downloadProgress = downloadProgress);
        //     }
        //   },
        // ),
      );
    }
    return DsCircularProgressIndicator(
      value: downloadProgress == -1 ? null : downloadProgress,
    );
  }
}
