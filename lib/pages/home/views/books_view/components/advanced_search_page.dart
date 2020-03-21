import 'package:flibusta/blocs/genres_list/genres_list_bloc.dart';
import 'package:flibusta/ds_controls/ui/app_bar.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

final _biggerFont = const TextStyle(fontSize: 18.0);

class AdvancedSearchPage extends StatefulWidget {
  static const String routeName = '/advanced_search';

  final AdvancedSearchParams advancedSearchParams;

  AdvancedSearchPage({
    Key key,
    this.advancedSearchParams,
  }) : super(key: key);

  @override
  _AdvancedSearchPageState createState() =>
      _AdvancedSearchPageState(advancedSearchParams);
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  TextEditingController titleController;
  TextEditingController firstnameController;
  TextEditingController lastnameController;
  TextEditingController middlenameController;
  TextEditingController genresTextFieldController = TextEditingController();

  GenresListBloc _genresListBloc;
  AdvancedSearchParams advancedSearchParams;

  _AdvancedSearchPageState(this.advancedSearchParams);

  @override
  void initState() {
    super.initState();
    _genresListBloc = GenresListBloc();
    titleController = TextEditingController(text: advancedSearchParams?.title);
    firstnameController =
        TextEditingController(text: advancedSearchParams?.firstname);
    lastnameController =
        TextEditingController(text: advancedSearchParams?.lastname);
    middlenameController =
        TextEditingController(text: advancedSearchParams?.middlename);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DsAppBar(
        title: Text(
          'Расширенный поиск',
          overflow: TextOverflow.fade,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: StreamBuilder(
            stream: _genresListBloc.allGenresListStream,
            builder:
                (context, AsyncSnapshot<List<Genre>> allGenresListSnapshot) {
              return StreamBuilder(
                stream: _genresListBloc.selectedGenresListStream,
                builder: (context,
                    AsyncSnapshot<List<Genre>> selectedGenresListSnapshot) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
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
                          decoration: InputDecoration(labelText: "Фамилия"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: TextField(
                          autocorrect: true,
                          controller: firstnameController,
                          style: _biggerFont,
                          decoration: InputDecoration(labelText: "Имя"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: TextField(
                          autocorrect: true,
                          controller: middlenameController,
                          style: _biggerFont,
                          decoration: InputDecoration(labelText: "Отчество"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: TypeAheadField(
                          autoFlipDirection: true,
                          textFieldConfiguration: TextFieldConfiguration(
                            autocorrect: true,
                            controller: genresTextFieldController,
                            style: _biggerFont,
                            enabled: allGenresListSnapshot.hasData,
                            decoration: InputDecoration(
                              labelText: "Жанр(-ы)",
                              suffixIcon: allGenresListSnapshot.hasData
                                  ? null
                                  : Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: DsCircularProgressIndicator()),
                            ),
                          ),
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion.name),
                            );
                          },
                          suggestionsCallback: (pattern) {
                            return Future.sync(() => allGenresListSnapshot.data
                                .where((genre) => genre.name
                                    .trim()
                                    .toLowerCase()
                                    .contains(pattern.toLowerCase()))
                                .toList());
                          },
                          onSuggestionSelected: (Genre suggestion) {
                            _genresListBloc.addToGenresList(suggestion);
                            genresTextFieldController.clear();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 14.0),
                        child: Wrap(
                          spacing: 6.0,
                          children: selectedGenresListSnapshot.data?.map(
                                (genre) {
                                  return Chip(
                                    backgroundColor:
                                        Theme.of(context).primaryColorLight,
                                    label: Text(genre.name),
                                    onDeleted: () {
                                      _genresListBloc
                                          .removeFromGenresList(genre);
                                    },
                                  );
                                },
                              )?.toList() ??
                              [],
                        ),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        color: Colors.blue,
                        child: Text(
                          "Искать!",
                          style: TextStyle(color: Colors.white, fontSize: 22.0),
                        ),
                        onPressed: () {
                          var resultAdvancedSearchParams = AdvancedSearchParams(
                              title: titleController.text,
                              lastname: lastnameController.text,
                              firstname: firstnameController.text,
                              middlename: middlenameController.text);
                          var selectedGenresString = "";
                          selectedGenresListSnapshot.data
                              ?.forEach((selectedGenre) {
                            if (selectedGenresString.isNotEmpty) {
                              selectedGenresString = selectedGenresString + ",";
                            }
                            selectedGenresString =
                                selectedGenresString + selectedGenre.code;
                          });

                          resultAdvancedSearchParams.genres =
                              selectedGenresString;
                          Navigator.pop(context, resultAdvancedSearchParams);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _genresListBloc.dispose();
    titleController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    middlenameController.dispose();
    super.dispose();
  }
}
