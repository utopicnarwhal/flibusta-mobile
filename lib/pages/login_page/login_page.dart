// import 'package:flibusta/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LoginPage extends StatefulWidget {
//   static const String routeName = '/login';
//   final String leadId;

//   LoginPage({this.leadId});

//   @override
//   LoginPageState createState() => LoginPageState();
// }

// class LoginPageState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   TextEditingController _loginTextController = TextEditingController();
//   final FocusNode _loginFocus = FocusNode();
//   TextEditingController _passwordTextController = TextEditingController();
//   final FocusNode _passwordFocus = FocusNode();

//   bool _isLogoCentered = true;

//   @override
//   void initState() {
//     super.initState();
//     AuthenticationBloc().initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLogoCentered) {
//       Future.microtask(() => setState(() => _isLogoCentered = false));
//     }

//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Theme.of(context).brightness == Brightness.light
//           ? Theme.of(context).cardColor
//           : null,
//       body: Scrollbar(
//         child: SingleChildScrollView(
//           physics: kBouncingAlwaysScrollableScrollPhysics,
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 20),
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height,
//               minWidth: MediaQuery.of(context).size.width,
//             ),
//             child: SafeArea(
//               child: BlocListener(
//                 bloc: AuthenticationBloc(),
//                 listener: _authBlocListener,
//                 child: BlocBuilder(
//                   bloc: AuthenticationBloc(),
//                   builder: (BuildContext context, AuthenticationState state) {
//                     var isAuthorizing = state is AuthorizingState ||
//                         state is AuthorizationSuccessState;

//                     return Container(
//                       alignment: Alignment.center,
//                       child: Container(
//                         constraints: BoxConstraints(maxWidth: 450),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: <Widget>[
//                             SizedBox(height: 40),
//                             Padding(
//                               padding: EdgeInsets.all(12.0),
//                               child: RosbankLogo(
//                                 sideHeight: 75,
//                                 isAnimated: false,
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.fromLTRB(12, 12, 12, 30),
//                               child: Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: <Widget>[
//                                   ListSlideInStagger(
//                                     index: 0,
//                                     duration:
//                                         kSplashsceenToLoginTransitionDuration,
//                                     child: Text(
//                                       'Добро пожаловать!',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .headline
//                                           .copyWith(
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 28,
//                                           ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                   SizedBox(height: 40),
//                                   ListSlideInStagger(
//                                     index: 5,
//                                     duration:
//                                         kSplashsceenToLoginTransitionDuration,
//                                     child: DcTextField(
//                                       focusNode: _loginFocus,
//                                       isDisabled: isAuthorizing,
//                                       customTextEditingController:
//                                           _loginTextController,
//                                       initValue: '',
//                                       labelText: 'Email',
//                                       onSave: (_) {},
//                                       isRequired: true,
//                                       type: DcTextFieldType.email,
//                                       textInputAction: TextInputAction.next,
//                                       onEditingComplete: () {
//                                         _loginFocus.unfocus();
//                                         FocusScope.of(context)
//                                             .requestFocus(_passwordFocus);
//                                       },
//                                     ),
//                                   ),
//                                   ListSlideInStagger(
//                                     index: 5,
//                                     duration:
//                                         kSplashsceenToLoginTransitionDuration,
//                                     child: DcTextField(
//                                       focusNode: _passwordFocus,
//                                       isDisabled: isAuthorizing,
//                                       customTextEditingController:
//                                           _passwordTextController,
//                                       initValue: '',
//                                       labelText: 'Пароль',
//                                       onSave: (_) {},
//                                       isRequired: true,
//                                       textInputAction: TextInputAction.done,
//                                       type: DcTextFieldType.password,
//                                       onEditingComplete: () {
//                                         if (!isAuthorizing) {
//                                           _loginClick();
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                   ListSlideInStagger(
//                                     index: 5,
//                                     duration:
//                                         kSplashsceenToLoginTransitionDuration,
//                                     child: Padding(
//                                       padding:
//                                           EdgeInsets.fromLTRB(16, 0, 16, 12),
//                                       child: isAuthorizing
//                                           ? Center(
//                                               child:
//                                                   DcCircularProgressIndicator(),
//                                             )
//                                           : DcRaisedButton(
//                                               padding: EdgeInsets.symmetric(
//                                                   vertical: 14),
//                                               borderRadius: 20,
//                                               child: Text(
//                                                 'Войти',
//                                                 style: TextStyle(fontSize: 18),
//                                               ),
//                                               onPressed: !isAuthorizing
//                                                   ? _loginClick
//                                                   : null,
//                                             ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 20),
//                                   ListSlideInStagger(
//                                     index: 10,
//                                     duration:
//                                         kSplashsceenToLoginTransitionDuration,
//                                     child: Wrap(
//                                       alignment: WrapAlignment.spaceBetween,
//                                       crossAxisAlignment:
//                                           WrapCrossAlignment.center,
//                                       spacing: 20,
//                                       runSpacing: 20,
//                                       children: <Widget>[
//                                         FlatButton(
//                                           child: Text(
//                                             'Регистрация',
//                                             style: TextStyle(
//                                               decoration:
//                                                   TextDecoration.underline,
//                                               color: kSecondaryColor(context),
//                                             ),
//                                           ),
//                                           onPressed: () async {
//                                             const registrationUrl =
//                                             if (await canLaunch(
//                                                 registrationUrl)) {
//                                               launch(
//                                                 registrationUrl,
//                                                 forceSafariVC: false,
//                                                 forceWebView: false,
//                                               );
//                                             }
//                                           },
//                                         ),
//                                         FlatButton(
//                                           child: Text(
//                                             'Забыли пароль?',
//                                             maxLines: 2,
//                                             style: TextStyle(
//                                               decoration:
//                                                   TextDecoration.underline,
//                                               color: kSecondaryColor(context),
//                                             ),
//                                           ),
//                                           onPressed: () async {
//                                             const forgetPasswordUrl =
//                                             if (await canLaunch(
//                                                 forgetPasswordUrl)) {
//                                               launch(
//                                                 forgetPasswordUrl,
//                                                 forceSafariVC: false,
//                                                 forceWebView: false,
//                                               );
//                                             }
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _authBlocListener(
//       BuildContext context, AuthenticationState state) async {
//     if (state is AuthorizationSuccessState) {
//       _onAuthSuccess(context);
//     }

//     if (state is ErrorAuthenticationState) {
//       ToastUtils.showToast(
//         state.message,
//         type: SnackBarType.error,
//       );
//     }
//   }

//   Future<void> _onAuthSuccess(BuildContext context) async {
//     // if (!mounted) return;
//     // await PermissionsUtils.requestAccess(context, PermissionGroup.notification);

//     if (!mounted) return;
//     Navigator.of(context).pushReplacementNamed(
//       PinPage.routeName,
//       arguments: {'leadId': widget.leadId},
//     );
//   }

//   void _loginClick() {
//     FocusScope.of(context).unfocus();
//     var login = _loginTextController.text.trim();
//     if (login == '' || _passwordTextController.text == '') {
//       ToastUtils.showToast(
//         'Не заполнено поле логин или пароль',
//       );
//       return;
//     }
//     var userCredentials = UserCredentials(
//       login: login,
//       password: _passwordTextController.text,
//     );
//     AuthenticationBloc().authorize(userCredentials);
//   }

//   @override
//   void dispose() {
//     _loginFocus?.dispose();
//     _passwordFocus?.dispose();
//     _loginTextController?.dispose();
//     _passwordTextController?.dispose();
//     super.dispose();
//   }
// }
