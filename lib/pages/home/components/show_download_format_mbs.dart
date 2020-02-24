import 'package:flibusta/ds_controls/ui/show_modal_bottom_sheet.dart';
import 'package:flibusta/model/bookCard.dart';
import 'package:flutter/material.dart';

Future<Map<String, String>> showDownloadFormatMBS(
  BuildContext context,
  BookCard bookCard,
) async {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  return await showDsModalBottomSheet<Map<String, String>>(
    title: 'В каком формате скачать?',
    context: context,
    builder: (BuildContext context) {
      return ListView.separated(
        addSemanticIndexes: false,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: bookCard.downloadFormats?.list?.length ?? 0,
        separatorBuilder: (context, index) {
          return Divider(indent: 16);
        },
        itemBuilder: (context, index) {
          var downloadFormat = bookCard.downloadFormats.list[index];

          return ListTile(
            leading: Icon(
              DownloadFormats.getIconDataForFormat(
                downloadFormat.keys.first,
              ),
              size: 28,
            ),
            title: Text(
              downloadFormat.keys.first,
              style: _biggerFont,
            ),
            onTap: () {
              Navigator.pop(context, downloadFormat);
            },
          );
        },
      );
    },
  );
}
