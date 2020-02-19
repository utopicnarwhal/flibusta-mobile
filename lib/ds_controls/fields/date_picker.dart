// import 'package:flibusta/models/base.dart';
// import 'package:flibusta/services/logic/validation_service/value_validators.dart';
// import 'package:flibusta/utils/date_utils.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// import '../theme.dart';
// import 'field_base.dart';

// class DsDatePicker extends DsFieldBaseWidget<String> {
//   final Date initValue;
//   final DateTime firstDate;
//   final DateTime lastDate;
//   final bool customError;
//   final TextEditingController customTextEditingController;
//   final void Function(Date) onSave;

//   DsDatePicker({
//     Key key,
//     @required this.initValue,
//     @required this.firstDate,
//     @required DateTime lastDate,
//     this.customTextEditingController,
//     this.customError = false,
//     @required this.onSave,
//     @required String labelText,
//     void Function(String text) onChange,
//     bool isRequired = false,
//     bool isDisabled = false,
//     FocusNode focusNode,
//   })  : this.lastDate = DateUtils.endOfTheDayOf(lastDate),
//         super(
//           key: key,
//           labelText: labelText,
//           isRequired: isRequired,
//           isDisabled: isDisabled,
//           onChange: onChange,
//           focusNode: focusNode,
//         );

//   @override
//   _DsDatePickerState createState() => _DsDatePickerState();
// }

// class _DsDatePickerState extends State<DsDatePicker>
//     with DsFieldBaseState<DsDatePicker, String> {
//   MaskTextInputFormatter _dateMaskFormatter = MaskTextInputFormatter(
//     mask: '##.##.####',
//     filter: {"#": RegExp(r'[0-9]')},
//   );

//   TextEditingController _textController;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.customTextEditingController != null) {
//       _textController = widget.customTextEditingController;
//     }

//     _textController ??= TextEditingController(
//       text: widget.initValue?.toDateString(),
//     );

//     fieldController = _textController;
//     _textController.addListener(handleChange);
//     var oldTextValue = TextEditingValue(text: '');
//     var newTextValue = TextEditingValue(text: _textController?.text ?? '');
//     _dateMaskFormatter?.formatEditUpdate(oldTextValue, newTextValue);
//   }

//   @override
//   bool checkFieldMask() {
//     if (_dateMaskFormatter?.lastResValue != null &&
//         _dateMaskFormatter.lastResValue?.text != _textController.value?.text) {
//       var maskedValue = _dateMaskFormatter?.formatEditUpdate(
//         _dateMaskFormatter.lastResValue,
//         _textController.value,
//       );
//       if (maskedValue?.text != _textController?.value?.text) {
//         _textController.value = maskedValue;
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
//           Stack(
//             alignment: Alignment.topRight,
//             children: <Widget>[
//               TextFormField(
//                 enabled: !isDisabled,
//                 textInputAction: TextInputAction.done,
//                 controller: _textController,
//                 keyboardType: TextInputType.datetime,
//                 focusNode: focusNode,
//                 decoration: InputDecoration(
//                   helperText: '',
//                   counterText: showNotRequired ? 'Не обязательно' : '',
//                   errorBorder: showRequired
//                       ? Theme.of(context).inputDecorationTheme.border
//                       : null,
//                   errorMaxLines: 3,
//                   filled: isDisabled,
//                 ),
//                 style: textStyle,
//                 // inputFormatters: [_dateMaskFormatter], DON'T USE THIS!!! ON SLOW DEVICES STARTS INFINITE LOOP ON FAST EDITING. USE #checkFieldMask INSTEAD
//                 validator: (value) {
//                   String result = fieldMetadata?.isValid;

//                   if (_dateMaskFormatter != null &&
//                       value != _dateMaskFormatter.getMaskedText()) {
//                     return result;
//                   }

//                   if (value?.isEmpty == false &&
//                       !_isBeforeAndAfterValid(
//                           value, widget.firstDate, widget.lastDate)) {
//                     if (widget.customError &&
//                         DateUtils.stringToDateTime(value)
//                                 ?.isAfter(widget.lastDate) ==
//                             true) {
//                       return 'Одобрение заемщика возможно с 20 лет при наличии созаёмщика, и с 21 года без созамещика';
//                     }

//                     return 'Некорректное значение поля';
//                   }
//                   return result;
//                 },
//                 onSaved: (value) {
//                   if (_dateMaskFormatter != null &&
//                       value != _dateMaskFormatter.getMaskedText()) {
//                     return;
//                   }
//                   if (!ValueValidators.isDateFieldIsValid(value) ||
//                       !_isBeforeAndAfterValid(
//                           value, widget.firstDate, widget.lastDate)) {
//                     return widget.onSave(null);
//                   }

//                   return widget.onSave(Date(value: value, time: '00:00'));
//                 },
//               ),
//               Padding(
//                 padding: EdgeInsets.fromLTRB(6, 0, 0, 22),
//                 child: IconButton(
//                   padding: EdgeInsets.all(0),
//                   tooltip: 'Выбрать дату через календарь',
//                   icon: Icon(
//                     EvaIcons.calendarOutline,
//                     size: 28,
//                   ),
//                   onPressed: isDisabled ? null : () => _pickDate(context),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _pickDate(BuildContext context) async {
//     var currentPastedDate = DateUtils.dateToDateTime(
//       Date(value: _textController.text, time: '00:00'),
//     );

//     FocusScope.of(context).unfocus();

//     var result = await showDatePicker(
//       context: context,
//       initialDate: currentPastedDate ??
//           (widget.lastDate.isBefore(DateTime.now())
//               ? widget.lastDate
//               : DateTime.now()),
//       firstDate: widget.firstDate ?? DateTime(1920),
//       lastDate: widget.lastDate ?? DateTime(2050),
//       locale: Locale('ru'),
//     );

//     if (result == null) {
//       return;
//     }

//     var date = DateUtils.dateTimeToString(result);

//     _textController.text = '';
//     _textController.text = date;
//   }

//   static bool _isBeforeAndAfterValid(
//       String value, DateTime firstDate, DateTime lastDate) {
//     DateTime dateFieldValue = DateUtils.stringToDateTime(value);

//     if (dateFieldValue == null ||
//         (firstDate != null && dateFieldValue.isBefore(firstDate)) ||
//         (lastDate != null && dateFieldValue.isAfter(lastDate))) {
//       return false;
//     }

//     return true;
//   }

//   @override
//   void dispose() {
//     _textController?.removeListener(handleChange);

//     if (widget.customTextEditingController == null) {
//       _textController.dispose();
//     }
//     super.dispose();
//   }
// }
