import 'package:easy_debounce/easy_debounce.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flibusta/blocs/grid/grid_data/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class BooksViewSearch extends StatefulWidget {
  final GridDataBloc currentGridDataBloc;
  final TextEditingController searchTextController;

  const BooksViewSearch({
    Key key,
    @required this.currentGridDataBloc,
    @required this.searchTextController,
  }) : super(key: key);

  @override
  _BooksViewSearchState createState() => _BooksViewSearchState();
}

class _BooksViewSearchState extends State<BooksViewSearch> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context)
              .inputDecorationTheme
              .copyWith(isCollapsed: true)),
      child: TypeAheadField(
        itemBuilder: (context, _) {
          return Text('123');
        },
        onSuggestionSelected: (suggestion) {
          print(suggestion);
        },
        suggestionsCallback: (searchText) {
          return [
            Text('123'),
          ];
        },
        textFieldConfiguration: TextFieldConfiguration(
          controller: widget.searchTextController,
          textInputAction: TextInputAction.search,
          onChanged: (searchQuery) {
            EasyDebounce.debounce(
              'search-debouncer',
              Duration(milliseconds: 1000),
              () => widget.currentGridDataBloc?.searchByString(searchQuery),
            );
          },
          decoration: InputDecoration(
            hintText: 'Поиск',
            isDense: true,
            hasFloatingPlaceholder: false,
            fillColor: Theme.of(context).cardColor,
            filled: true,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.searchTextController,
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
                      widget.searchTextController?.clear();
                      widget.currentGridDataBloc?.searchByString('');
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
