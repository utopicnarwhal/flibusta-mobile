import 'dart:io';
import 'dart:convert';

import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flibusta/services/http_client_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

Future<AdvancedSearchParams> showAdvancedSearchBS(GlobalKey<ScaffoldState> scaffoldKey, AdvancedSearchParams advancedSearchParams) async {
  final titleController = TextEditingController(text: advancedSearchParams.title);
  final firstnameController = TextEditingController(text: advancedSearchParams.firstname);
  final lastnameController = TextEditingController(text: advancedSearchParams.lastname);
  final middlenameController = TextEditingController(text: advancedSearchParams.middlename);
  final genresTextFieldController = TextEditingController();

  final _biggerFont = const TextStyle(fontSize: 18.0);

  List<Genre> selectedGenres = List<Genre>();
  List<Genre> allGenres = List<Genre>();
  getAllGenres().then((genres) => allGenres = genres);

  advancedSearchParams = null;
  
  PersistentBottomSheetController persistentBottomSheetController;
  persistentBottomSheetController = scaffoldKey.currentState.showBottomSheet<AdvancedSearchParams>((BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (persistentBottomSheetController != null) {
          persistentBottomSheetController.close();
        }
      },
        child: Container(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: TextField(
                    autocorrect: true,
                    controller: titleController,
                    style: _biggerFont,
                    decoration: InputDecoration(
                      labelText: "Название",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: TextField(
                    autocorrect: true,
                    controller: lastnameController,
                    style: _biggerFont,
                    decoration: InputDecoration(
                      labelText: "Фамилия"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: TextField(
                    autocorrect: true,
                    controller: firstnameController,
                    style: _biggerFont,
                    decoration: InputDecoration(
                      labelText: "Имя"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: TextField(
                    autocorrect: true,
                    controller: middlenameController,
                    style: _biggerFont,
                    decoration: InputDecoration(
                      labelText: "Отчество"
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: TypeAheadField(
                    suggestionsBoxVerticalOffset: -200,
                    suggestionsBoxDecoration: SuggestionsBoxDecoration(
                      constraints: BoxConstraints.loose(Size.fromHeight(150.0))
                    ),
                    textFieldConfiguration: TextFieldConfiguration(
                      autocorrect: true,
                      controller: genresTextFieldController,
                      style: _biggerFont,
                      decoration: InputDecoration(
                        labelText: "Жанр(-ы)"
                      ),
                    ),
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.name),
                      );
                    },
                    suggestionsCallback: (pattern) {
                      return Future.sync(() => allGenres.where((genre) => genre.name.toLowerCase().contains(pattern.toLowerCase())).toList());
                    },
                    onSuggestionSelected: (suggestion) {
                      if (persistentBottomSheetController != null) {
                        persistentBottomSheetController.setState(() {
                          selectedGenres.add(suggestion);
                          genresTextFieldController.clear();
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Wrap(
                    children: selectedGenres.map((genre) {
                      return Chip(
                        label: Text(genre.name),
                        onDeleted: () {
                          if (persistentBottomSheetController != null) {
                            persistentBottomSheetController.setState(() {
                              selectedGenres.removeWhere((selected) => selected.id == genre.id);
                            });
                          }
                        },
                      );
                    }).toList()
                  ),
                ),
                RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  color: Colors.blue,
                  child: Text("Искать!", style: TextStyle(color: Colors.white, fontSize: 22.0),),
                  onPressed: () {
                    advancedSearchParams = AdvancedSearchParams(
                      title: titleController.text,
                      lastname: lastnameController.text,
                      firstname: firstnameController.text,
                      middlename: middlenameController.text
                    );
                    var selectedGenresString = "";
                    selectedGenres.forEach((selectedGenre) {
                      if (selectedGenresString.isNotEmpty) {
                        selectedGenresString = selectedGenresString + ",";
                      }
                      selectedGenresString = selectedGenresString + selectedGenre.code;
                    });
                    
                    advancedSearchParams.genres = selectedGenresString;
                    Navigator.pop(context, advancedSearchParams);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });

  await persistentBottomSheetController.closed;
  return advancedSearchParams;
}

Future<List<Genre>> getAllGenres() async {
  HttpClient _httpClient = ProxyHttpClient().getHttpClient();

  var result = List<Genre>();
  Map<String, String> queryParams = { "op" : "getList",};
  Uri url = Uri.https(ProxyHttpClient().getFlibustaHostAddress(), "/ajaxro/genre", queryParams);
  try {
    var superRealResponse = "";
    var response = await _httpClient.getUrl(url).timeout(Duration(seconds: 5)).then((r) => r.close());
    await response.transform(utf8.decoder).listen((contents) {
      superRealResponse += contents;
    }).asFuture();
    var jsonresult = json.decode(superRealResponse);
    jsonresult.forEach((headIndex, headGenre) {
      headGenre.forEach((genre) {
        result.add(
          Genre(
            id: int.tryParse(genre["id"]),
            name: genre["name"],
            code: genre["code"],
          )
        );
      });
    });
    return result;
  } catch(error) {
    print(error);
    return result;
  }
}