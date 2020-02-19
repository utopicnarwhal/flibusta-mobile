// import 'package:flutter/material.dart';

// import '../theme.dart';
// import 'field_base.dart';
// import 'package:flibusta/extension_methods/string_extension.dart';

// class NumberBox extends DsFieldBaseWidget<String> {
//   final num initValue;
//   final String suffixText;
//   final TextEditingController customTextEditingController;
//   final bool isSpacedDevisions;
//   final void Function(num) onSave;

//   const NumberBox({
//     Key key,
//     @required this.initValue,
//     @required this.onSave,
//     this.suffixText,
//     this.customTextEditingController,
//     this.isSpacedDevisions = false,
//     @required String labelText,
//     void Function(String text) onChange,
//     FocusNode focusNode,
//     bool isRequired = false,
//     bool isDisabled = false,
//   }) : super(
//           key: key,
//           labelText: labelText,
//           isRequired: isRequired,
//           isDisabled: isDisabled,
//           onChange: onChange,
//           focusNode: focusNode,
//         );

//   @override
//   _NumberBoxState createState() => _NumberBoxState();
// }

// class _NumberBoxState extends State<NumberBox>
//     with DsFieldBaseState<NumberBox, String> {
//   TextEditingController _numberController;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.customTextEditingController != null) {
//       _numberController = widget.customTextEditingController;
//     }

//     _numberController ??= TextEditingController(
//       text: widget.initValue != null
//           ? widget.initValue.toStringAsFixed(0).spaceDevisions()
//           : '',
//     );

//     fieldController = _numberController;
//     _numberController.addListener(handleChange);
//   }

//   @override
//   bool checkFieldMask() {
//     var value = _numberController.text;
//     if (widget.isSpacedDevisions) {
//       var spacedDevisionText = value.spaceDevisions();
//       if (spacedDevisionText != value) {
//         _savingCursorPositionPasting(value, spacedDevisionText);
//         return false;
//       }
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
//           TextFormField(
//             enabled: !isDisabled,
//             textInputAction: TextInputAction.done,
//             keyboardType: TextInputType.number,
//             controller: _numberController,
//             focusNode: focusNode,
//             decoration: InputDecoration(
//               helperText: '',
//               counterText: showNotRequired ? 'Не обязательно' : '',
//               suffixText: widget.suffixText,
//               filled: isDisabled,
//               errorBorder: showRequired
//                   ? Theme.of(context).inputDecorationTheme.border
//                   : null,
//             ),
//             style: textStyle,
//             validator: (textValue) {
//               textValue = textValue?.replaceAll(' ', '');
//               var numValue = num.tryParse(textValue);
//               if (textValue?.isNotEmpty == true && numValue == null) {
//                 return 'Введите число';
//               }

//               String result = fieldMetadata?.isValid;

//               return result;
//             },
//             onSaved: (textValue) {
//               if (widget.isSpacedDevisions) {
//                 textValue = textValue.replaceAll(' ', '');
//               }
//               var numValue = num.tryParse(textValue);
//               widget.onSave(numValue);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _savingCursorPositionPasting(String value, String spacedDevisionText) {
//     var offset = _numberController.value.selection.start;
//     if (spacedDevisionText.length > value.length) {
//       offset++;
//     } else if (spacedDevisionText.length < value.length) {
//       offset--;
//     }
//     _numberController.value = _numberController.value.copyWith(
//       text: spacedDevisionText,
//       selection: TextSelection.collapsed(
//         offset: offset,
//       ),
//       composing: TextRange.empty,
//     );
//   }

//   @override
//   void dispose() {
//     _numberController?.removeListener(handleChange);
//     if (widget.customTextEditingController == null) {
//       _numberController?.dispose();
//     }
//     super.dispose();
//   }
// }
