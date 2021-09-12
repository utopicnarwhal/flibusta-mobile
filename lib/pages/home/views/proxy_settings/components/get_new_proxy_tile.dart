import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/services/http_client/http_client.dart';
import 'package:flutter/material.dart';

class GetNewProxyTile extends StatefulWidget {
  final void Function(String) callback;
  final bool enabled;

  GetNewProxyTile({
    Key key,
    this.callback,
    this.enabled = true,
  }) : super(key: key);

  _GetNewProxyTileState createState() => _GetNewProxyTileState();
}

class _GetNewProxyTileState extends State<GetNewProxyTile> {
  _GetNewProxyTileState();

  var requestingProxies = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: !requestingProxies && widget.enabled,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: requestingProxies
            ? SizedBox(
                width: 20,
                height: 20,
                child: DsCircularProgressIndicator(),
              )
            : Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.secondary,
              ),
      ),
      title: Text('Добавить прокси с сайта http://pubproxy.com'),
      onTap: () async {
        if (!mounted) return;
        setState(() {
          requestingProxies = true;
        });
        var newProxies = await ProxyHttpClient().getNewProxies();
        newProxies.forEach(widget.callback);

        if (!mounted) return;
        setState(() {
          requestingProxies = false;
        });
      },
    );
  }
}
