import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flutter/material.dart';

Future<AdvancedSearchParams> showAdvancedSearchBS(GlobalKey<ScaffoldState> scaffoldKey, AdvancedSearchParams advancedSearchParams) async {
  final titleController = TextEditingController(text: advancedSearchParams.title);
  final firstnameController = TextEditingController(text: advancedSearchParams.firstname);
  final lastnameController = TextEditingController(text: advancedSearchParams.lastname);
  final middlenameController = TextEditingController(text: advancedSearchParams.middlename);
  final _biggerFont = const TextStyle(fontSize: 18.0);
  
  var persistentBottomSheetController = scaffoldKey.currentState.showBottomSheet<AdvancedSearchParams>((BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 14)],
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade800
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget> [
              TextField(
                controller: titleController,
                style: _biggerFont,
                decoration: InputDecoration(
                  labelText: "Название"
                ),
              ),
              TextField(
                controller: lastnameController,
                style: _biggerFont,
                decoration: InputDecoration(
                  labelText: "Фамилия"
                ),
              ),
              TextField(
                controller: firstnameController,
                style: _biggerFont,
                decoration: InputDecoration(
                  labelText: "Имя"
                ),
              ),
              TextField(
                controller: middlenameController,
                style: _biggerFont,
                decoration: InputDecoration(
                  labelText: "Отчество"
                ),
              ),
              RaisedButton(
                color: Colors.blue,
                child: Text("Искать!", style: TextStyle(color: Colors.white),),
                onPressed: () {
                  advancedSearchParams = AdvancedSearchParams(
                    title: titleController.text,
                    lastname: lastnameController.text,
                    firstname: firstnameController.text,
                    middlename: middlenameController.text
                  );
                  
                  Navigator.pop(context, advancedSearchParams);
                },
              ),
            ],
          ),
        ),
      ),
    );
  });

  await persistentBottomSheetController.closed;
  return advancedSearchParams;
}