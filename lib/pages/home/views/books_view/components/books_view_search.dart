import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class BooksViewSearch extends StatelessWidget {
  final GlobalKey<ScaffoldState> scafffoldKey;
  final GridDataBloc currentGridDataBloc;
  final TextEditingController searchTextController;

  const BooksViewSearch({
    Key key,
    @required this.scafffoldKey,
    @required this.currentGridDataBloc,
    @required this.searchTextController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var suggestionBoxController = SuggestionsBoxController();

    return Theme(
      data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context)
              .inputDecorationTheme
              .copyWith(isCollapsed: true)),
      child: TypeAheadField<String>(
        itemBuilder: (context, suggestion) {
          return ListTile(
            leading: Icon(Icons.history),
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) async {
          currentGridDataBloc?.searchByString(suggestion);
          searchTextController.text = suggestion;
          var previousBookSearches =
              await LocalStorage().getPreviousBookSearches();
          LocalStorage().setPreviousBookSearches([
            suggestion,
            ...previousBookSearches..remove(suggestion),
          ]);
        },
        suggestionsCallback: (searchText) async {
          var previousBookSearches =
              await LocalStorage().getPreviousBookSearches();

          var filteredSuggestions = previousBookSearches
              ?.where((suggestion) => suggestion
                  ?.toLowerCase()
                  ?.startsWith(searchText.trim().toLowerCase()))
              ?.toList();

          return filteredSuggestions;
        },
        suggestionsBoxController: suggestionBoxController,
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
        textFieldConfiguration: TextFieldConfiguration(
          controller: searchTextController,
          textInputAction: TextInputAction.search,
          onEditingComplete: () async {
            currentGridDataBloc?.searchByString(searchTextController.text);
            if (searchTextController.text?.isEmpty != false) {
              return;
            }
            var previousBookSearches =
                await LocalStorage().getPreviousBookSearches();
            LocalStorage().setPreviousBookSearches([
              searchTextController.text,
              ...previousBookSearches,
            ]);
          },
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Поиск',
            isDense: true,
            hasFloatingPlaceholder: false,
            fillColor: Theme.of(context).cardColor,
            filled: true,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchTextController,
              builder: (context, textEditingValue, _) {
                if (textEditingValue?.text?.isEmpty == true) {
                  return SizedBox.shrink();
                }
                return IconButton(
                  icon: Icon(
                    EvaIcons.close,
                    size: 24,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).unfocus();
                      searchTextController?.clear();
                      currentGridDataBloc?.searchByString('');
                    });
                  },
                );
              },
            ),
            prefixIcon: Icon(
              EvaIcons.search,
              size: 28,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white,
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white,
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white,
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
