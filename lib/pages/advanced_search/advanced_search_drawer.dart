import 'package:flibusta/blocs/genres_list/genres_list_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/ui/buttons/outline_button.dart';
import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
import 'package:flibusta/model/advancedSearchParams.dart';
import 'package:flibusta/model/genre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AdvancedSearchDrawer extends StatefulWidget {
  static const String routeName = '/advanced_search';

  final AdvancedSearchParams advancedSearchParams;
  final void Function() onSearch;

  AdvancedSearchDrawer({
    Key key,
    @required this.advancedSearchParams,
    @required this.onSearch,
  }) : super(key: key);

  @override
  _AdvancedSearchDrawerState createState() => _AdvancedSearchDrawerState();
}

class _AdvancedSearchDrawerState extends State<AdvancedSearchDrawer> {
  TextEditingController titleController;
  TextEditingController firstnameController;
  TextEditingController lastnameController;
  TextEditingController middlenameController;
  TextEditingController genresTextFieldController = TextEditingController();

  GenresListBloc _genresListBloc;

  @override
  void initState() {
    super.initState();
    _genresListBloc = GenresListBloc();
    titleController =
        TextEditingController(text: widget.advancedSearchParams?.title);
    firstnameController =
        TextEditingController(text: widget.advancedSearchParams?.firstname);
    lastnameController =
        TextEditingController(text: widget.advancedSearchParams?.lastname);
    middlenameController =
        TextEditingController(text: widget.advancedSearchParams?.middlename);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        type: MaterialType.card,
        borderRadius: BorderRadius.zero,
        child: SafeArea(
          child: StreamBuilder<List<Genre>>(
            stream: _genresListBloc.allGenresListStream,
            builder: (context, allGenresListSnapshot) {
              return StreamBuilder<List<Genre>>(
                stream: _genresListBloc.selectedGenresListStream,
                builder: (context, selectedGenresListSnapshot) {
                  return ListView(
                    physics: kBouncingAlwaysScrollableScrollPhysics,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    children: <Widget>[
                      Text(
                        'Параметры поиска:',
                        style: Theme.of(context).textTheme.title,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Название'),
                      ),
                      TextField(
                        autocorrect: true,
                        controller: titleController,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Фамилия'),
                      ),
                      TextField(
                        autocorrect: true,
                        controller: lastnameController,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Имя'),
                      ),
                      TextField(
                        autocorrect: true,
                        controller: firstnameController,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Отчество'),
                      ),
                      TextField(
                        autocorrect: true,
                        controller: middlenameController,
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Жанр(-ы)'),
                      ),
                      TypeAheadField(
                        autoFlipDirection: true,
                        textFieldConfiguration: TextFieldConfiguration(
                          autocorrect: true,
                          controller: genresTextFieldController,
                          enabled: allGenresListSnapshot.hasData,
                          decoration: InputDecoration(
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
                      SizedBox(height: 14),
                      Wrap(
                        spacing: 6.0,
                        children: selectedGenresListSnapshot.data?.map(
                              (genre) {
                                return Chip(
                                  backgroundColor:
                                      Theme.of(context).primaryColorLight,
                                  label: Text(genre.name),
                                  onDeleted: () {
                                    _genresListBloc.removeFromGenresList(genre);
                                  },
                                );
                              },
                            )?.toList() ??
                            [],
                      ),
                      SizedBox(height: 14),
                      DsOutlineButton(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'Искать!',
                        ),
                        onPressed: () {
                          if (widget.advancedSearchParams == null) {
                            Navigator.of(context).pop();
                            return;
                          }
                          widget.advancedSearchParams.title =
                              titleController.text;
                          widget.advancedSearchParams.lastname =
                              lastnameController.text;
                          widget.advancedSearchParams.firstname =
                              firstnameController.text;
                          widget.advancedSearchParams.middlename =
                              middlenameController.text;

                          var selectedGenresString = "";
                          selectedGenresListSnapshot.data
                              ?.forEach((selectedGenre) {
                            if (selectedGenresString.isNotEmpty) {
                              selectedGenresString = selectedGenresString + ",";
                            }
                            selectedGenresString =
                                selectedGenresString + selectedGenre.code;
                          });

                          widget.advancedSearchParams.genres =
                              selectedGenresString;

                          if (widget.onSearch != null) {
                            widget.onSearch();
                          }
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
    _genresListBloc?.dispose();
    titleController?.dispose();
    genresTextFieldController?.dispose();
    firstnameController?.dispose();
    lastnameController?.dispose();
    middlenameController?.dispose();
    super.dispose();
  }
}
