import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  static const routeName = "/Login";
  @override
  createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Вход"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Form(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/img/flibusta_logo.png"),
                        width: 150.0,
                        height: 150.0,
                        fit: BoxFit.fill),
                    TextFormField(
                      maxLines: 1,
                      autofocus: true,
                      decoration: InputDecoration(
                          icon: Icon(
                            Icons.assignment_ind,
                          ),
                          hintText: "Логин"),
                    ),
                    TextFormField(
                      maxLines: 1,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.lock,
                        ),
                        hintText: "Пароль",
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
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
}
