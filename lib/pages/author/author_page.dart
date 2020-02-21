// import 'package:dio/dio.dart';
// import 'package:flibusta/ds_controls/ui/app_bar.dart';
// import 'package:flibusta/model/authorInfo.dart';
// import 'package:flibusta/services/http_client_service.dart';
// import 'package:flibusta/utils/html_parsers.dart';
// import 'package:flibusta/utils/toast_utils.dart';
// import 'package:flutter/material.dart';

// class AuthorPage extends StatefulWidget {
//   static const routeName = "/AuthorPage";

//   final int authorId;

//   const AuthorPage({Key key, this.authorId}) : super(key: key);
//   @override
//   _AuthorPageState createState() => _AuthorPageState();
// }

// class _AuthorPageState extends State<AuthorPage> {
//   Dio _dio = ProxyHttpClient().getDio();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   AuthorInfo authorInfo;

//   @override
//   void initState() {
//     super.initState();

//     getAuthorInfo(widget.authorId).then((response) {
//       setState(() {
//         authorInfo = response;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: DsAppBar(
//         title: Text(authorInfo.name ?? 'Загрузка...'),
//       ),
//       body: GridCards(
//         scaffoldKey: _scaffoldKey,
//         data: authorInfo.books,
//       ),
//     );
//   }

//   Future<AuthorInfo> getAuthorInfo(int authorId) async {
//     authorInfo = AuthorInfo(id: authorId);
//     try {
//       Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(),
//           "/a/" + authorId.toString());
//       var response = await _dio.getUri(url);

//       authorInfo = parseHtmlFromAuthorInfo(response.data, authorId);
//     } catch (e) {
//       ToastUtils.showToast(
//         'Не удалось получить данные об авторе',
//         action: SnackBarAction(
//           label: "Попробовать ещё раз",
//           onPressed: () {
//             getAuthorInfo(widget.authorId).then((response) {
//               setState(() {
//                 authorInfo = response;
//               });
//             });
//           },
//         ),
//       );
//       print(e);
//     }

//     return authorInfo;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
