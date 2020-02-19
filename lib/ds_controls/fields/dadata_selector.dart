// import 'package:flibusta/ds_controls/enums/dadata_types.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:flibusta/extension_methods/string_extension.dart';

// import '../theme.dart';
// import 'field_base.dart';
// import 'selector.dart';

// class DaDataSelector extends DsFieldBaseWidget<String> {
//   final int type;
//   final String initValue;
//   final TextEditingController customTextEditingController;
//   final DsSelectorController<PicklistItem> customGenderCodeController;
//   final void Function(String text) onSave;
//   final void Function(Suggestion) onSuggestionSelected;

//   const DaDataSelector({
//     Key key,
//     @required this.type,
//     @required this.initValue,
//     @required this.onSave,
//     void Function(String text) onChange,
//     @required this.onSuggestionSelected,
//     @required String labelText,
//     bool isRequired = false,
//     bool isDisabled = false,
//     this.customTextEditingController,
//     this.customGenderCodeController,
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
//   _DaDataSelectorState createState() => _DaDataSelectorState();
// }

// class _DaDataSelectorState extends State<DaDataSelector>
//     with DsFieldBaseState<DaDataSelector, String> {
//   TextEditingController _textController;
//   DsSelectorController<Suggestion> _suggestionController;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.customTextEditingController != null) {
//       _textController = widget.customTextEditingController;
//     }

//     _textController ??= TextEditingController(
//       text: widget.initValue,
//     );

//     _suggestionController ??= DsSelectorController(
//       option: null,
//     );
//     fieldController = _textController;

//     _textController.addListener(handleChange);
//   }

//   @override
//   bool checkFieldMask() {
//     if (widget.type == DaDataType.fio &&
//         _textController.text != _textController.text.toProperCase()) {
//       _textController.value = _textController.value.copyWith(
//         text: _textController.text.toProperCase(),
//       );
//       return false;
//     }
//     return true;
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
//               // Изменено на TextInputType.visiblePassword так как
//               // Bug 31613: МП. На клавиатуре samsung дубликация строки в полях ввода после символов . @ (Если включен режим T9 интеллектуальный набор)
//               keyboardType: TextInputType.visiblePassword,
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
//             suggestionsBoxDecoration: SuggestionsBoxDecoration(
//               borderRadius: BorderRadius.circular(kPopupMenuBorderRadius),
//               elevation: 8,
//             ),
//             hideOnEmpty: true,
//             hideOnLoading: true,
//             hideOnError: true,
//             keepSuggestionsOnLoading: false,
//             autoFlipDirection: true,
//             suggestionsCallback: _getSuggestions,
//             onSuggestionSelected: (Suggestion selected) {
//               _textController.text = selected?.value ?? '';

//               if (selected?.data?.gender != null) {
//                 widget.customGenderCodeController?.option = PicklistItem(
//                   value: selected.data.gender == 'MALE' ? 1 : 2,
//                 );
//               } else {
//                 widget.customGenderCodeController?.option = null;
//               }
//               widget.onSuggestionSelected(selected);
//             },
//             itemBuilder: (context, Suggestion suggestion) {
//               return ListTile(
//                 title: Text(suggestion.value),
//               );
//             },
//             validator: (value) {
//               String result = fieldMetadata?.isValid;
//               return result;
//             },
//             onSaved: (text) {
//               if (text.trim().isEmpty && widget.initValue == null) {
//                 return widget.onSave(null);
//               }
//               widget.onSave(text);
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
//     super.dispose();
//   }
// }
