import 'package:flibusta/services/http_client_service.dart';
import 'package:flutter/material.dart';

class ProxyRadioListTile extends StatefulWidget {
  final String _title;
  final String _value;
  final String _groupValue;
  final void Function(String) _onChanged;

  ProxyRadioListTile({
    Key key,
    @required String title,
    @required String value,
    @required String groupValue,
    @required void Function(String) onChanged,
  })  : _title = title,
        _value = value,
        _groupValue = groupValue,
        _onChanged = onChanged,
        super(key: key);

  _ProxyRadioListTileState createState() =>
      _ProxyRadioListTileState(_title, _value, _groupValue, _onChanged);
}

class _ProxyRadioListTileState extends State<ProxyRadioListTile> {
  final String _title;
  final String _value;
  final String _groupValue;
  final void Function(String) _onChanged;
  
  _ProxyRadioListTileState(this._title, this._value, this._groupValue, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      title: Text(_title),
      subtitle: FutureBuilder(
        future: ProxyHttpClient().connectionCheck(_value),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          var subtitleText = "";
          var subtitleColor;
          if (snapshot.data != null &&
              snapshot.connectionState != ConnectionState.waiting) {
            if (snapshot.data >= 0) {
              subtitleText = "доступно (пинг: ${snapshot.data.toString()}мс)";
              subtitleColor = Colors.green;
            } else {
              subtitleText = "ошибка";
              subtitleColor = Colors.red;
            }
          } else {
            subtitleText = "проверка...";
            subtitleColor = Colors.grey[400];
          }
          return Text(subtitleText, style: TextStyle(color: subtitleColor));
        },
      ),
      groupValue: _groupValue,
      value: _value,
      onChanged: _onChanged,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
