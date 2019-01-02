import 'package:flutter/material.dart';
import 'dart:io';

class Login extends StatefulWidget {
  @override
  createState() => new LoginState();
}

class LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: false,
        title: new Text("Вход"),
      ),
      body: 
        SingleChildScrollView(
          child: Center(
            child: new Container(
              margin: const EdgeInsets.all(10.0),
              child: new Form(
                child: new Theme(
                  data: new ThemeData(
                    primarySwatch: Colors.blue,
                    inputDecorationTheme: new InputDecorationTheme(

                    )
                  ),
                  child: new Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: new Column(
                      children: <Widget>[
                        new Image(
                          image: new AssetImage("assets/img/flibusta_logo.png"),
                          width: 150.0,
                          height: 150.0,
                          fit: BoxFit.fill
                        ),
                        new TextFormField(
                          maxLines: 1,
                          autofocus: true,
                          decoration: new InputDecoration(
                            
                            icon: new Icon(Icons.assignment_ind,),
                            hintText: "Логин"
                          ),
                        ),
                        new TextFormField(
                          maxLines: 1,
                          decoration: new InputDecoration(
                            icon: new Icon(Icons.lock,),
                            hintText: "Пароль",
                          ),
                          keyboardType: TextInputType.text,
                          obscureText: true,
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(top: 20.0),
                        ),
                        new RaisedButton(
                          child: new Text("Войти"),
                          onPressed: () {
                            HttpClient httpClient = new HttpClient();
                          },
                        )
                      ],
                    ),
                  )
                  
                ),
              )
            ),
          )
      )
    );
  }
}