import 'package:flibusta/model/bookCard.dart';
import 'package:flutter/material.dart';

Future<Map<String, String>> showDownloadFormatMBS(GlobalKey<ScaffoldState> scaffoldKey, BookCard bookCard) async {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  return await showModalBottomSheet<Map<String, String>>(context: scaffoldKey.currentContext, builder: (BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: bookCard.downloadFormats.list.map((downloadFormat) {
        return Container(
          padding: EdgeInsets.all(0),
          child: FlatButton(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(DownloadFormats.getIconDataForFormat(downloadFormat.keys.first), size: 28,),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(downloadFormat.keys.first, style: _biggerFont,),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pop(context, downloadFormat);
            },
          )
        );
      }).toList(),
    );
  });
}