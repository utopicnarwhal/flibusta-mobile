// import 'package:flibusta/services/logic/validation_service/validation_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';

// import 'selector.dart';

// abstract class DsFieldBaseWidget<S> extends StatefulWidget {
//   final String labelText;

//   /// use [isRequired] from [state] instead
//   final bool isRequired;

//   /// use [isDisabled] from [state] instead
//   final bool isDisabled;
//   final void Function(S value) onChange;

//   final FocusNode focusNode;

//   const DsFieldBaseWidget({
//     Key key,
//     @required this.labelText,
//     this.isRequired = false,
//     this.isDisabled = false,
//     this.onChange,
//     this.focusNode,
//   }) : super(key: key);
// }

// mixin DsFieldBaseState<T extends DsFieldBaseWidget<S>, S> on State<T> {
//   bool _didInitState = false;

//   /// init it in [initState]
//   /// needs for [isEmptyField] check
//   @protected
//   ValueNotifier fieldController;

//   @protected
//   FieldMetadata fieldMetadata;

//   @protected
//   bool showRequired = true;
//   @protected
//   bool showNotRequired = true;

//   ValidationService _validationService;

//   @protected
//   FocusNode focusNode;

//   @protected
//   bool checkFieldMask() {
//     return true;
//   }

//   /// Can't be called in [initState]
//   @protected
//   bool get isRequired {
//     return (fieldMetadata?.isRequired ?? false) || widget.isRequired;
//   }

//   /// Can't be called in [initState]
//   @protected
//   bool get isDisabled {
//     return (fieldMetadata?.isDisabled ?? false) || widget.isDisabled;
//   }

//   /// Can't be called in [initState]
//   @protected
//   bool get isShow {
//     return fieldMetadata?.isShow ?? true;
//   }

//   /// Can't be called in [initState]
//   @protected
//   String get isValueValid {
//     return fieldMetadata?.isValueValid ?? null;
//   }

//   @protected
//   dynamic get controllerValue {
//     if (fieldController is TextEditingController) {
//       return (fieldController as TextEditingController).text;
//     }
//     if (fieldController is DsSelectorController) {
//       return (fieldController as DsSelectorController).option;
//     }
//   }

//   @mustCallSuper
//   void didInitState() {
//     showRequired = isRequired && isFieldEmpty;
//     showNotRequired = !isRequired && isFieldEmpty;

//     if (widget.focusNode != null) {
//       focusNode = widget.focusNode;
//     }

//     focusNode ??= FocusNode();
//     // this.focusNode.addListener(_handleFocusChange);
//     _validationService?.addListener(_updateMetadata);
//     _updateMetadata();
//   }

//   @protected
//   void handleChange() {
//     if (checkFieldMask() != false && widget.onChange != null) {
//       widget.onChange(controllerValue);
//     }
//   }

//   void _updateMetadata() {
//     FieldMetadata newFieldMetadata;
//     try {
//       newFieldMetadata = _validationService?.getFieldMetadata(widget.labelText);
//     } on ProviderNotFoundException catch (_) {
//       setState(() {
//         showRequired = isRequired && isFieldEmpty;
//         showNotRequired = !isRequired && isFieldEmpty;
//       });
//     }

//     if (newFieldMetadata == fieldMetadata) {
//       return;
//     }

//     fieldMetadata = newFieldMetadata;
//     setState(() {
//       showRequired = isRequired && isFieldEmpty;
//       showNotRequired = !isRequired && isFieldEmpty;
//     });
//   }

//   @override
//   @mustCallSuper
//   void didChangeDependencies() {
//     try {
//       _validationService = Provider.of<ValidationService>(context);
//     } on ProviderNotFoundException catch (_) {}

//     if (!_didInitState) {
//       didInitState();
//       _didInitState = true;
//     }
//     super.didChangeDependencies();
//   }

//   @override
//   void didUpdateWidget(oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     checkFieldMask();
//   }

//   // @protected
//   // void _handleFocusChange() async {
//   //   print('${widget.labelText}: ${focusNode.hasPrimaryFocus}');
//   //   if (focusNode.hasPrimaryFocus) {
//   //     _fullLabelTextBottomSheetController = showBottomSheet(
//   //       // backgroundColor: Theme.of(context).hoverColor,
//   //       elevation: 8,
//   //       context: context,
//   //       builder: (context) {
//   //         return Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           crossAxisAlignment: CrossAxisAlignment.stretch,
//   //           children: <Widget>[
//   //             Divider(),
//   //             Padding(
//   //               padding: const EdgeInsets.all(8.0),
//   //               child: Row(
//   //                 mainAxisAlignment: MainAxisAlignment.start,
//   //                 crossAxisAlignment: CrossAxisAlignment.center,
//   //                 children: <Widget>[
//   //                   Icon(
//   //                     EvaIcons.infoOutline,
//   //                     size: 16,
//   //                     color: kSecondaryColor(context),
//   //                   ),
//   //                   SizedBox(width: 8),
//   //                   Text(
//   //                     widget.labelText,
//   //                     style: TextStyle(fontSize: 12),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //         );
//   //       },
//   //     )..closed?.whenComplete(() {
//   //         _fullLabelTextBottomSheetController = null;
//   //       });
//   //   } else {
//   //     _fullLabelTextBottomSheetController = null;
//   //   }
//   // }

//   @override
//   void dispose() {
//     focusNode?.unfocus();
//     // focusNode?.removeListener(_handleFocusChange);
//     if (widget.focusNode == null) {
//       focusNode?.dispose();
//     }
//     _validationService?.removeListener(_updateMetadata);
//     super.dispose();
//   }

//   @protected
//   bool get isFieldEmpty {
//     if (fieldController is TextEditingController) {
//       return isTextFieldEmpty((fieldController as TextEditingController).text);
//     }
//     if (fieldController is DsSelectorController) {
//       return isSelectorFieldEmpty(
//           (fieldController as DsSelectorController).option);
//     }
//     return false;
//   }

//   static bool isTextFieldEmpty(String text) {
//     return text?.trim()?.isEmpty != false;
//   }

//   static bool isSelectorFieldEmpty(dynamic option) {
//     return option == null;
//   }
// }
