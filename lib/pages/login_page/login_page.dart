import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/enums/text_field_types.dart';
import 'package:flibusta/ds_controls/fields/text_field.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/buttons/raised_button.dart';
import 'package:flibusta/ds_controls/ui/decor/flibusta_logo.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/extension_methods/dio_error_extension.dart';
import 'package:flibusta/model/userCredentials.dart';
import 'package:flibusta/services/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utopic_toast/utopic_toast.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  final String leadId;

  LoginPage({this.leadId});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _loginTextController;
  final FocusNode _loginFocus = FocusNode();
  TextEditingController _passwordTextController;
  final FocusNode _passwordFocus = FocusNode();

  bool _isAuthorizing = false;
  String _formBuildId;

  @override
  void initState() {
    super.initState();
    _loginTextController = TextEditingController();
    _passwordTextController = TextEditingController();

    _getFormBuildId();
  }

  Future<void> _getFormBuildId() async {
    Uri url = Uri.https(ProxyHttpClient().getHostAddress(), '/');

    try {
      var response = await ProxyHttpClient().getDio().getUri(url);

      if (response.data is String) {
        print((response.data as String)
            .matchAsPrefix(r'/(?<=name="form_build_id" id=")form--[^"]+/gm'));
      }
    } on DsError catch (dsError) {
      ToastManager().showToast(dsError.userMessage);
    }
    // _formBuildId = ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).cardColor
          : null,
      appBar: DsAppBar(
        title: Text('Авторизация'),
      ),
      body: SingleChildScrollView(
        physics: kBouncingAlwaysScrollableScrollPhysics,
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: SafeArea(
            child: Container(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: FlibustaLogo(
                        sideHeight: 200,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          DsTextField(
                            focusNode: _loginFocus,
                            isDisabled: _isAuthorizing,
                            customTextEditingController: _loginTextController,
                            initValue: '',
                            labelText: 'Логин',
                            onSave: (_) {},
                            isRequired: true,
                            type: DsTextFieldType.email,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () {
                              _loginFocus.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocus);
                            },
                          ),
                          DsTextField(
                            focusNode: _passwordFocus,
                            isDisabled: _isAuthorizing,
                            customTextEditingController:
                                _passwordTextController,
                            initValue: '',
                            labelText: 'Пароль',
                            onSave: (_) {},
                            isRequired: true,
                            textInputAction: TextInputAction.done,
                            type: DsTextFieldType.password,
                            onEditingComplete: () {
                              if (!_isAuthorizing) {
                                _loginClick();
                              }
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: _isAuthorizing
                                ? Center(
                                    child: DsCircularProgressIndicator(),
                                  )
                                : DsRaisedButton(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    borderRadius: 20,
                                    child: Text(
                                      'Войти',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    onPressed:
                                        !_isAuthorizing ? _loginClick : null,
                                  ),
                          ),
                          SizedBox(height: 40),
                          // Wrap(
                          //     alignment: WrapAlignment.spaceBetween,
                          //     crossAxisAlignment:
                          //         WrapCrossAlignment.center,
                          //     spacing: 20,
                          //     runSpacing: 20,
                          //     children: <Widget>[
                          // FlatButton(
                          //   child: Text(
                          //     'Регистрация',
                          //     style: TextStyle(
                          //       decoration:
                          //           TextDecoration.underline,
                          //       color: kSecondaryColor(context),
                          //     ),
                          //   ),
                          //   onPressed: () async {
                          //     const registrationUrl =
                          //     if (await canLaunch(
                          //         registrationUrl)) {
                          //       launch(
                          //         registrationUrl,
                          //         forceSafariVC: false,
                          //         forceWebView: false,
                          //       );
                          //     }
                          //   },
                          // ),
                          // FlatButton(
                          //   child: Text(
                          //     'Забыли пароль?',
                          //     maxLines: 2,
                          //     style: TextStyle(
                          //       decoration:
                          //           TextDecoration.underline,
                          //       color: kSecondaryColor(context),
                          //     ),
                          //   ),
                          //   onPressed: () async {
                          //     const forgetPasswordUrl =
                          //     if (await canLaunch(
                          //         forgetPasswordUrl)) {
                          //       launch(
                          //         forgetPasswordUrl,
                          //         forceSafariVC: false,
                          //         forceWebView: false,
                          //       );
                          //     }
                          //   },
                          // ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAuthSuccess(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _loginClick() async {
    FocusScope.of(context).unfocus();
    var login = _loginTextController.text.trim();
    if (login == '' || _passwordTextController.text == '') {
      ToastManager().showToast(
        'Не заполнено поле логин или пароль',
      );
      return;
    }
    var userCredentials = UserCredentials(
      login: login,
      password: _passwordTextController.text,
    );

    Uri url = Uri.https(
      ProxyHttpClient().getHostAddress(),
      '/node',
      {'destination': 'node'},
    );

    try {
      var response = await ProxyHttpClient().getDio().postUri(
        url,
        data: {
          'grant_type': 'password',
          'name': userCredentials.login,
          'pass': userCredentials.password,
          'persistent_login': 1,
          'op': 'Вход+в+систему',
          'form_id': 'user_login_block',
          'openid_identifier': '',
          'form_build_id': '',
        },
      );
      if (response.data is String) {
        print((response.data as String).contains('messages error'));
      }
    } on DsError catch (dsError) {
      ToastManager().showToast(dsError.userMessage);
    }

    print(ProxyHttpClient().getCookies());
  }

  @override
  void dispose() {
    _loginFocus?.dispose();
    _passwordFocus?.dispose();
    _loginTextController?.dispose();
    _passwordTextController?.dispose();
    super.dispose();
  }
}
