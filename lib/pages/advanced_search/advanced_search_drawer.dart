import 'package:flibusta/blocs/book_formats/book_formats_bloc.dart';
import 'package:flibusta/blocs/book_languages/book_languages_bloc.dart';
import 'package:flibusta/blocs/genres_list/genres_list_bloc.dart';
import 'package:flibusta/constants.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/ds_controls/ui/buttons/raised_button.dart';
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
  BookFormatsBloc _bookFormatsBloc;
  BookLanguagesBloc _bookLanguagesBloc;

  @override
  void initState() {
    super.initState();
    _genresListBloc = GenresListBloc();
    _bookFormatsBloc = BookFormatsBloc(
      selectedBookFormats: widget.advancedSearchParams?.formats?.split(','),
    );
    _bookLanguagesBloc = BookLanguagesBloc(
      selectedBookLanguages: widget.advancedSearchParams?.languages?.split(','),
    );
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
          child: ListView(
            physics: kBouncingAlwaysScrollableScrollPhysics,
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            children: <Widget>[
              Text(
                'Параметры поиска:',
                style: Theme.of(context).textTheme.headline6,
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
              StreamBuilder<List<Genre>>(
                stream: _genresListBloc.allGenresListStream,
                builder: (context, allGenresListSnapshot) {
                  return StreamBuilder<List<Genre>>(
                    stream: _genresListBloc.selectedGenresListStream,
                    builder: (context, selectedGenresListSnapshot) {
                      return Column(
                        children: [
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
                            getImmediateSuggestions: true,
                            hideOnEmpty: true,
                            hideOnError: true,
                            hideOnLoading: true,
                            hideSuggestionsOnKeyboardHide: true,
                            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                              borderRadius: BorderRadius.circular(
                                kCardBorderRadius,
                              ),
                            ),
                            itemBuilder: (context, Genre suggestion) {
                              return ListTile(
                                title: Text(suggestion.name),
                              );
                            },
                            suggestionsCallback: (pattern) {
                              return Future.sync(() => allGenresListSnapshot
                                  .data
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
                                        _genresListBloc
                                            .removeFromGenresList(genre);
                                      },
                                    );
                                  },
                                )?.toList() ??
                                [],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Формат(-ы) книги'),
              ),
              StreamBuilder<List<String>>(
                stream: _bookFormatsBloc.selectedFormatsStream,
                builder: (context, selectedFormatsSnapshot) {
                  return Column(
                    children: [
                      TypeAheadField(
                        autoFlipDirection: true,
                        textFieldConfiguration: TextFieldConfiguration(
                          autocorrect: true,
                          controller: genresTextFieldController,
                          enabled: _bookFormatsBloc.allBookFormats.isNotEmpty,
                        ),
                        getImmediateSuggestions: true,
                        hideOnEmpty: true,
                        hideOnError: true,
                        hideOnLoading: true,
                        hideSuggestionsOnKeyboardHide: true,
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                          borderRadius: BorderRadius.circular(
                            kCardBorderRadius,
                          ),
                        ),
                        itemBuilder: (context, String suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        suggestionsCallback: (pattern) {
                          return Future.sync(() => _bookFormatsBloc
                              .allBookFormats
                              .where((format) => format
                                  .trim()
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList());
                        },
                        onSuggestionSelected: (String suggestion) {
                          _bookFormatsBloc.addToSelectedFormats(suggestion);
                          genresTextFieldController.clear();
                        },
                      ),
                      SizedBox(height: 14),
                      Wrap(
                        spacing: 6.0,
                        children: selectedFormatsSnapshot.data?.map(
                              (format) {
                                return Chip(
                                  backgroundColor:
                                      Theme.of(context).primaryColorLight,
                                  label: Text(format),
                                  onDeleted: () {
                                    _bookFormatsBloc
                                        .removeFromSelectedFormats(format);
                                  },
                                );
                              },
                            )?.toList() ??
                            [],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Язык(-и)'),
              ),
              StreamBuilder<List<String>>(
                stream: _bookLanguagesBloc.selectedLanguagesStream,
                builder: (context, selectedLanguagesSnapshot) {
                  return Column(
                    children: [
                      TypeAheadField(
                        autoFlipDirection: true,
                        textFieldConfiguration: TextFieldConfiguration(
                          autocorrect: true,
                          controller: genresTextFieldController,
                          enabled:
                              _bookLanguagesBloc.allBookLanguages.isNotEmpty,
                        ),
                        getImmediateSuggestions: true,
                        hideOnEmpty: true,
                        hideOnError: true,
                        hideOnLoading: true,
                        hideSuggestionsOnKeyboardHide: true,
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(
                          borderRadius: BorderRadius.circular(
                            kCardBorderRadius,
                          ),
                        ),
                        itemBuilder: (context, String suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        suggestionsCallback: (pattern) {
                          return Future.sync(() => _bookLanguagesBloc
                              .allBookLanguages
                              .where((language) => language
                                  .trim()
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList());
                        },
                        onSuggestionSelected: (String suggestion) {
                          _bookLanguagesBloc.addToSelectedLanguages(suggestion);
                          genresTextFieldController.clear();
                        },
                      ),
                      SizedBox(height: 14),
                      Wrap(
                        spacing: 6.0,
                        children: selectedLanguagesSnapshot.data?.map(
                              (language) {
                                return Chip(
                                  backgroundColor:
                                      Theme.of(context).primaryColorLight,
                                  label: Text(language),
                                  onDeleted: () {
                                    _bookLanguagesBloc
                                        .removeFromSelectedLanguages(language);
                                  },
                                );
                              },
                            )?.toList() ??
                            [],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 14),
              DsRaisedButton(
                elevation: 4,
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Искать!',
                ),
                onPressed: () {
                  if (widget.advancedSearchParams == null) {
                    Navigator.of(context).pop();
                    return;
                  }
                  widget.advancedSearchParams.title = titleController.text;
                  widget.advancedSearchParams.lastname =
                      lastnameController.text;
                  widget.advancedSearchParams.firstname =
                      firstnameController.text;
                  widget.advancedSearchParams.middlename =
                      middlenameController.text;

                  widget.advancedSearchParams.genres =
                      _genresListBloc.getSelectedGenres();

                  widget.advancedSearchParams.formats =
                      _bookFormatsBloc.getSelectedFormats().join(',');

                  widget.advancedSearchParams.languages =
                      _bookLanguagesBloc.getSelectedLanguages().join(',');

                  if (widget.onSearch != null) {
                    widget.onSearch();
                  }
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _genresListBloc?.dispose();
    _bookFormatsBloc?.dispose();
    _bookLanguagesBloc?.dispose();
    titleController?.dispose();
    genresTextFieldController?.dispose();
    firstnameController?.dispose();
    lastnameController?.dispose();
    middlenameController?.dispose();
    super.dispose();
  }
}
