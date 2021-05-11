// import 'package:flibusta/ds_controls/ui/progress_indicator.dart';
// import 'package:flutter/material.dart';

// import '../theme.dart';
// import 'field_base.dart';
// import 'selector.dart';

// class SegmentedSelector<T> extends DsFieldBaseWidget<T> {
//   final T initValue;
//   final List<T> getCollection;
//   final DsSelectorController customSelectorController;
//   final void Function(T) onSave;

//   const SegmentedSelector({
//     Key key,
//     this.initValue,
//     this.getCollection,
//     this.customSelectorController,
//     this.onSave,
//     @required String labelText,
//     void Function(T value) onChange,
//     bool isRequired = false,
//     bool isDisabled = false,
//   }) : super(
//           key: key,
//           labelText: labelText,
//           isRequired: isRequired,
//           isDisabled: isDisabled,
//           onChange: onChange,
//         );

//   @override
//   _SegmentedSelectorState<T> createState() => _SegmentedSelectorState<T>();
// }

// class _SegmentedSelectorState<T> extends State<SegmentedSelector<T>>
//     with DsFieldBaseState<SegmentedSelector<T>, T> {
//   DsSelectorController<T> _selectorController;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.customSelectorController != null) {
//       _selectorController = widget.customSelectorController;
//     }

//     _selectorController ??= DsSelectorController(option: widget.initValue);

//     fieldController = _selectorController;
//     _selectorController.addListener(handleChange);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isShow == false) {
//       return Container();
//     }

//     TextStyle labelStyle;
//     if (isDisabled) {
//       labelStyle = TextStyle(color: Theme.of(context).disabledColor);
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
//           SegmentedSelectorFormField<T>(
//             controller: _selectorController,
//             decoration: InputDecoration(
//               alignLabelWithHint: false,
//               enabled: !isDisabled || widget.getCollection?.isEmpty != false,
//               helperText: '',
//               errorBorder: showRequired
//                   ? Theme.of(context).inputDecorationTheme.border
//                   : null,
//               counterText: showNotRequired ? 'Не обязательно' : '',
//               filled: isDisabled,
//               suffixIcon: widget.getCollection == null
//                   ? Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.max,
//                       children: <Widget>[
//                         ConstrainedBox(
//                           constraints:
//                               BoxConstraints(maxHeight: 30, maxWidth: 30),
//                           child: DsCircularProgressIndicator(),
//                         ),
//                       ],
//                     )
//                   : null,
//             ),
//             validator: (value) {
//               String result = fieldMetadata?.isValid;

//               return result;
//             },
//             items: Map<T, Widget>.fromIterable(
//               widget.getCollection,
//               key: (item) => item,
//               value: (item) => Text(
//                 item.toString != null ? item.toString() : item,
//               ),
//             ),
//             onChange: !isDisabled ? (selected) {} : null,
//             onSave: (value) {
//               widget.onSave(value);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _selectorController?.removeListener(handleChange);

//     if (widget.customSelectorController == null) {
//       _selectorController?.dispose();
//     }
//     super.dispose();
//   }
// }

// class SegmentedSelectorFormField<T> extends FormField<T> {
//   final DsSelectorController<T> controller;

//   SegmentedSelectorFormField({
//     Key key,
//     T value,
//     @required Map<T, Widget> items,
//     this.onChange,
//     this.controller,
//     InputDecoration decoration = const InputDecoration(),
//     FormFieldSetter<T> onSave,
//     FormFieldValidator<T> validator,
//     Widget hint,
//   })  : assert(decoration != null),
//         super(
//           key: key,
//           onSaved: onSave,
//           initialValue: controller.option ?? value,
//           validator: validator,
//           enabled: onChange != null,
//           builder: (FormFieldState<T> state) {
//             final InputDecoration effectiveDecoration =
//                 decoration.applyDefaults(
//               Theme.of(state.context).inputDecorationTheme.copyWith(
//                     isCollapsed: true,
//                     contentPadding: EdgeInsets.fromLTRB(0.5, 0, 0.5, -1),
//                     isDense: true,
//                     hasFloatingPlaceholder: false,
//                   ),
//             );

//             return InputDecorator(
//               decoration: effectiveDecoration,
//               isEmpty: state.value == null,
//               child: Padding(
//                 padding: EdgeInsets.only(top: 2),
//                 child: SegmentedControl<T>(
//                   items: items,
//                   groupValue: state.value,
//                   onValueChanged: onChange == null
//                       ? null
//                       : (newValue) {
//                           if (newValue != state.value) {
//                             if (controller != null) {
//                               controller.option = newValue;
//                             } else {
//                               state.didChange(newValue);
//                             }
//                           }
//                         },
//                 ),
//               ),
//             );
//           },
//         );

//   /// Called when the user selects an item.
//   final ValueChanged<T> onChange;

//   @override
//   FormFieldState<T> createState() => _SegmentedSelectorFormFieldState<T>();
// }

// class _SegmentedSelectorFormFieldState<T> extends FormFieldState<T> {
//   @override
//   SegmentedSelectorFormField<T> get widget => super.widget;

//   @override
//   void initState() {
//     super.initState();
//     widget.controller?.addListener(updateValueFromController);
//   }

//   @override
//   void didChange(T value) {
//     if (widget.onChange != null) {
//       widget.onChange(value);
//     }
//     super.didChange(value);
//   }

//   void updateValueFromController() {
//     var newValue = widget.controller?.option;
//     if (newValue != value) {
//       didChange(newValue);
//     }
//   }

//   @override
//   void dispose() {
//     widget.controller?.removeListener(updateValueFromController);
//     super.dispose();
//   }
// }

// class SegmentedControl<T> extends StatelessWidget {
//   final Map<T, Widget> items;
//   final void Function(T) onValueChanged;
//   final T groupValue;

//   SegmentedControl({
//     this.items,
//     this.onValueChanged,
//     this.groupValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     List<Widget> children = [];
//     var counter = 0;
//     items.forEach((value, widget) {
//       children.add(
//         Expanded(
//           child: TextButton(
//             padding: EdgeInsets.all(0),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.horizontal(
//                 left: Radius.circular(counter == 0 ? 3 : 0),
//                 right: Radius.circular(counter == (items.length - 1) ? 3 : 0),
//               ),
//             ),
//             child: widget,
//             textColor: value == groupValue
//                 ? Colors.white
//                 : Theme.of(context).textTheme.button.color,
//             disabledTextColor: value == groupValue
//                 ? ThemeData.dark().textTheme.subhead.color
//                 : kDisabledFieldTextColor(context),
//             color: value == groupValue
//                 ? kSecondaryColor(context)
//                 : Colors.transparent,
//             disabledColor:
//                 value == groupValue ? kSecondaryColor(context) : null,
//             onPressed:
//                 onValueChanged != null ? () => onValueChanged(value) : null,
//           ),
//         ),
//       );
//       if (counter != (items.length - 1)) {
//         children.add(VerticalDivider());
//       }
//       counter++;
//     });
//     return Semantics(
//       button: true,
//       child: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         behavior: HitTestBehavior.opaque,
//         child: SizedBox(
//           height: 46,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: children,
//           ),
//         ),
//       ),
//     );
//   }
// }
