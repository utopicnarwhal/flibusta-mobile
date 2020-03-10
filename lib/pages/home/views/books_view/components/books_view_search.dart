import 'package:easy_debounce/easy_debounce.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flibusta/ds_controls/theme.dart';
import 'package:flibusta/pages/home/views/books_view/components/advanced_search_bs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _kAdvancedSearchString = '@!&*%AdvencedSearch%*&!@';

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
    return Theme(
      data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context)
              .inputDecorationTheme
              .copyWith(isCollapsed: true)),
      child: TypeAheadField<String>(
        itemBuilder: (context, suggestion) {
          var text = suggestion;
          if (suggestion == _kAdvancedSearchString) {
            text = 'Расширенный поиск';
          }
          return ListTile(
            title: Text(text),
          );
        },
        onSuggestionSelected: (suggestion) async {
          if (suggestion == _kAdvancedSearchString) {
            await showAdvancedSearchBS(scafffoldKey, null);
          }
          currentGridDataBloc?.searchByString(suggestion);
        },
        suggestionsCallback: (searchText) {
          return [
            _kAdvancedSearchString,
          ];
        },
        getImmediateSuggestions: true,
        hideOnEmpty: true,
        hideOnError: true,
        hideOnLoading: false,
        hideSuggestionsOnKeyboardHide: true,
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          borderRadius: BorderRadius.circular(
            kCardBorderRadius,
          ),
        ),
        textFieldConfiguration: TextFieldConfiguration(
          controller: searchTextController,
          textInputAction: TextInputAction.search,
          onChanged: (searchQuery) {
            EasyDebounce.debounce(
              'search-debouncer',
              Duration(milliseconds: 1000),
              () => currentGridDataBloc?.searchByString(searchQuery),
            );
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
            suffix: Icon(
              FontAwesomeIcons.filter,
              color: Colors.black,
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
