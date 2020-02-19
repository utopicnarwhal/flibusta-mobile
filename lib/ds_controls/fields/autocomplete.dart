// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:rxdart/rxdart.dart';

// import '../theme.dart';
// import 'field_base.dart';

// enum AutocompleteType {
//   normal,
// }

// class Autocomplete<T> extends DsFieldBaseWidget<String> {
//   final AutocompleteType type;
//   final T initValue;
//   final bool forceChoose;
//   final TextEditingController customTextEditingController;
//   final List<T> Function(String) getSuggestions;
//   final void Function(T) onSave;
//   final void Function(T) onSuggestionSelected;

//   const Autocomplete({
//     Key key,
//     this.type = AutocompleteType.normal,
//     @required this.initValue,
//     @required this.onSave,
//     @required this.getSuggestions,
//     @required this.onSuggestionSelected,
//     this.customTextEditingController,
//     this.forceChoose = false,
//     @required String labelText,
//     void Function(String text) onChange,
//     bool isRequired = false,
//     bool isDisabled = false,
//     FocusNode focusNode,
//   }) : super(
//           key: key,
//           labelText: labelText,
//           isRequired: isRequired,
//           isDisabled: isDisabled,
//           onChange: onChange,
//           focusNode: focusNode,
//         );

//   @override
//   _AutocompleteState<T> createState() => _AutocompleteState<T>();
// }

// class _AutocompleteState<T> extends State<Autocomplete<T>>
//     with DsFieldBaseState<Autocomplete<T>, String> {
//   TextEditingController _textController;
//   BehaviorSubject<T> _valueController;
//   TextInputType _keyboardType;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.customTextEditingController != null) {
//       _textController = widget.customTextEditingController;
//     }

//     switch (widget.type) {
//       case AutocompleteType.normal:
//         _keyboardType = TextInputType.text;
//         _textController ??= TextEditingController(
//           text: widget.initValue?.toString != null
//               ? widget.initValue.toString()
//               : '',
//         );
//         break;
//       default:
//         _keyboardType = TextInputType.text;
//         _textController ??= TextEditingController(
//           text: widget.initValue?.toString != null
//               ? widget.initValue.toString()
//               : '',
//         );
//         break;
//     }

//     _valueController = BehaviorSubject<T>.seeded(widget.initValue);

//     fieldController = _textController;
//     _textController.addListener(handleChange);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isShow == false) {
//       return Container();
//     }

//     TextStyle labelStyle;
//     TextStyle textStyle;
//     if (isDisabled) {
//       labelStyle = TextStyle(color: Theme.of(context).disabledColor);
//       textStyle = TextStyle(color: kDisabledFieldTextColor(context));
//     } else {
//       labelStyle = TextStyle(color: Theme.of(context).hintColor);
//     }

//     return Padding(
//       key: ValueKey(isDisabled),
//       padding: EdgeInsets.only(left: 16, right: 16, bottom: 8.0, top: 0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Padding(
//             padding: EdgeInsets.only(left: 8.0, bottom: 4.0, right: 8.0),
//             child: Text(
//               widget.labelText,
//               style: labelStyle,
//             ),
//           ),
//           TypeAheadFormField(
//             textFieldConfiguration: TextFieldConfiguration(
//               enabled: !isDisabled,
//               controller: _textController,
//               keyboardType: _keyboardType,
//               decoration: InputDecoration(
//                 helperText: '',
//                 counterText: showNotRequired ? 'Не обязательно' : '',
//                 errorBorder: showRequired
//                     ? Theme.of(context).inputDecorationTheme.border
//                     : null,
//                 filled: isDisabled,
//               ),
//               focusNode: focusNode,
//               style: textStyle,
//             ),
//             hideOnEmpty: !widget.forceChoose,
//             keepSuggestionsOnLoading: false,
//             autoFlipDirection: true,
//             suggestionsCallback: widget.getSuggestions,
//             onSuggestionSelected: (T selected) {
//               _valueController.add(selected);
//               _textController.text = selected.toString();
//               if (widget.onSuggestionSelected != null) {
//                 widget.onSuggestionSelected(selected);
//               }
//             },
//             itemBuilder: (context, T suggestion) {
//               return ListTile(
//                 title: Text(suggestion.toString()),
//               );
//             },
//             noItemsFoundBuilder: (context) {
//               return Container(
//                 alignment: Alignment.center,
//                 constraints: BoxConstraints(maxHeight: 80),
//                 child: Text(
//                   'Нет совпадений',
//                   style: Theme.of(context)
//                       .textTheme
//                       .display1
//                       .copyWith(fontSize: 22),
//                 ),
//               );
//             },
//             validator: (textValue) {
//               String result;

//               if (widget.forceChoose &&
//                   textValue.isNotEmpty &&
//                   textValue != _valueController?.value?.toString()) {
//                 result = 'Выберите значение из списка';
//               }

//               if (result != null) {
//                 return result;
//               }
//               result = fieldMetadata?.isValid;
//               return result;
//             },
//             onSaved: (value) {
//               if (widget.forceChoose) {
//                 if (value == _valueController.value.toString()) {
//                   widget.onSave(_valueController.value);
//                 } else {
//                   widget.onSave(null);
//                 }
//                 return;
//               }
//               if (T is String) {
//                 widget.onSave(value as T);
//               }
//               widget.onSave(_valueController.value);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _textController?.removeListener(handleChange);

//     if (widget.customTextEditingController == null) {
//       _textController?.dispose();
//     }
//     _valueController.close();
//     super.dispose();
//   }
// }
