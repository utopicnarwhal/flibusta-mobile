import 'package:flibusta/services/http_client.dart';
import 'package:flutter/material.dart';

class GetNewProxyTile extends StatefulWidget {
  final void Function(String) _callback;

  GetNewProxyTile({
    Key key,
    void Function(String) callback,
  })  : this._callback = callback,
        super(key: key);

  _GetNewProxyTileState createState() => _GetNewProxyTileState(_callback);
}

class _GetNewProxyTileState extends State<GetNewProxyTile> {
  final void Function(String) _callback;

  _GetNewProxyTileState(this._callback);

  var requestingProxies = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !requestingProxies,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: requestingProxies
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              )
            : Icon(
                Icons.add,
                color: Theme.of(context).accentColor,
              ),
      ),
      title: Text('Добавить прокси с сайта http://pubproxy.com'),
      onTap: () async {
        setState(() {
          requestingProxies = true;
        });
        var newProxies = await ProxyHttpClient().getNewProxies();
        newProxies.forEach(_callback);
        if (mounted) {
          setState(() {
            requestingProxies = false;
          });
        }
      },
    );
  }
}
