import 'package:flibusta_app/pages/proxy_settings/free_proxy_tiles/free_proxy_tiles.dart';
import 'package:flibusta_app/services/local_store_service.dart';
import 'package:flutter/material.dart';

class ProxySettings extends StatefulWidget {
  @override
  createState() => ProxySettingsState();
}

class ProxySettingsState extends State<ProxySettings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        centerTitle: false,
        title: Text("Настройки Proxy"),
      ),
      body: ListView(
        children: <Widget> [
          FreeProxyTiles(),
          // Container(
          //   color: Colors.transparent, 
          //   height: 60.0,
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Text("Вы также можете указать свой Proxy сервер, при необходимости", style: TextStyle(color: Colors.blueGrey, fontSize: 16)),
          //   )
          // ),
          // Container(
          //   decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)]),
          //   child: Column(
          //     children: <Widget>[
          //       ListTile(
          //         leading: Icon(Icons.add, color: Colors.black,),
          //         title: Text("Добавить прокси"),
          //         onTap: () async {
          //           var userProxy = await showDialog<String>(
          //             context: context,
          //             builder: (BuildContext context) {
          //               final TextEditingController proxyHostController = TextEditingController();
          //               return SimpleDialog(
          //                 title: Text("Добавить прокси"),
          //                 children: <Widget>[
          //                   TextField(
          //                     controller: proxyHostController,
          //                     autofocus: true,
          //                     onEditingComplete: () {
          //                       Navigator.pop(context, proxyHostController.text);
          //                     },
          //                   )
          //                 ],
          //               );
          //             }
          //           );
          //           if (userProxy != null && userProxy.isNotEmpty) {
          //             LocalStore().addUserProxy(userProxy);
          //           }
          //         },
          //       ),
          //       Divider(height: 1,),
          //       FutureBuilder(
          //         future: LocalStore().getUserProxies(),
          //         builder: (context, snapshot) {
          //           return snapshot.data != null && snapshot.data.length > 0 ?
          //           Column(
          //             children:
          //               List<Widget>.generate(
          //                 snapshot.data.length,
          //                 (int index) =>
          //                 ListTile(
          //                   title: Text(snapshot.data[index]),
          //                   trailing: IconButton(
          //                     icon: Icon(Icons.close, color: Colors.black),
          //                     onPressed: () {
          //                       setState(() async {
          //                         await LocalStore().deleteUserProxy(snapshot.data[index]);      
          //                       });
          //                     },
          //                   ),
          //                 )
          //               )
          //           ) : Container();
          //         },
          //       )
          //     ],
          //   ),
          // ),
        ]
      ),
    );
  }
}