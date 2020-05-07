import 'dart:async';
import 'dart:ui';

import 'package:flibusta/ds_controls/enums/text_field_types.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../theme.dart';
import 'field_base.dart';

class DsTextField extends DsFieldBaseWidget<String> {
  final int type;
  final StreamController<int> typeController;
  final String initValue;
  final TextEditingController customTextEditingController;
  final void Function(String) onSave;
  final VoidCallback onEditingComplete;
  final TextInputAction textInputAction;

  const DsTextField({
    Key key,
    this.typeController,
    this.type = DsTextFieldType.text,
    @required this.initValue,
    @required this.onSave,
    this.customTextEditingController,
    @required String labelText,
    void Function(String text) onChange,
    bool isRequired = false,
    bool isDisabled = false,
    this.onEditingComplete,
    this.textInputAction,
    FocusNode focusNode,
  }) : super(
          key: key,
          labelText: labelText,
          isRequired: isRequired,
          isDisabled: isDisabled,
          onChange: onChange,
          focusNode: focusNode,
        );

  @override
  _DsTextFieldState createState() => _DsTextFieldState();
}

class _DsTextFieldState extends State<DsTextField>
    with DsFieldBaseState<DsTextField, String> {
  TextEditingController _textController;
  MaskTextInputFormatter _maskFormatter;
  TextInputType _keyboardType;
  bool _passwordVisibility = false;
  bool _checkPassportInProgress = false;

  StreamSubscription _typeSubscription;
  String _hintText;
  String _prefixText;

  @override
  void initState() {
    super.initState();

    if (widget.customTextEditingController != null) {
      _textController = widget.customTextEditingController;
    }

    _initFieldByType(widget.type);

    fieldController = _textController;
    _textController.addListener(handleChange);
    _typeSubscription = widget.typeController?.stream?.listen((newType) {
      newType ??= DsTextFieldType.text;
      _initFieldByType(newType);
    });
  }

  @override
  bool checkFieldMask() {
    if (_maskFormatter?.lastResValue != null &&
        _maskFormatter.lastResValue?.text != _textController.value?.text) {
      var maskedValue = _maskFormatter?.formatEditUpdate(
        _maskFormatter.lastResValue,
        _textController.value,
      );
      if (maskedValue?.text != _textController?.value?.text) {
        _textController.value = maskedValue;
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle;
    TextStyle textStyle;
    if (widget.isDisabled) {
      labelStyle = TextStyle(color: Theme.of(context).disabledColor);
      textStyle = Theme.of(context)
          .textTheme
          .subtitle1
          .copyWith(color: kDisabledFieldTextColor(context));
    } else {
      labelStyle = TextStyle(color: Theme.of(context).hintColor);
      textStyle = Theme.of(context).textTheme.subtitle1;
    }

    Widget suffixIcon;
    if (widget.type == DsTextFieldType.password) {
      suffixIcon = IconButton(
        icon: Icon(
          _passwordVisibility ? EvaIcons.eyeOff2Outline : EvaIcons.eyeOutline,
        ),
        onPressed: () => setState(() {
          _passwordVisibility = !_passwordVisibility;
        }),
      );
    } else {
      suffixIcon = null;
    }

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 8.0, top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 4.0, right: 8.0),
            child: Text(
              widget.labelText,
              style: labelStyle,
            ),
          ),
          TextFormField(
            enabled: !widget.isDisabled,
            textInputAction: widget.textInputAction ?? TextInputAction.done,
            keyboardType: _keyboardType,
            controller: _textController,
            maxLines: 1,
            onEditingComplete: widget.onEditingComplete,
            focusNode: focusNode,
            // inputFormatters:  DON'T USE THIS!!! ON SLOW DEVICES STARTS INFINITE LOOP ON FAST EDITING. USE #checkFieldMask INSTEAD
            decoration: InputDecoration(
              helperText: '',
              counterText: !widget.isRequired ? 'Не обязательно' : '',
              errorBorder: showRequired
                  ? Theme.of(context).inputDecorationTheme.border
                  : null,
              suffixIcon: suffixIcon,
              filled: widget.isDisabled,
              hintText: _hintText,
              errorMaxLines: 3,
              prefixText: _prefixText,
              prefixStyle: textStyle,
            ),
            style: textStyle,
            obscureText:
                !_passwordVisibility && widget.type == DsTextFieldType.password,
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              if (_maskFormatter != null &&
                  value != _maskFormatter.getMaskedText()) {
                return;
              }
              if (value.trim().isEmpty || _checkPassportInProgress == true) {
                return widget.onSave(null);
              }
              if (widget.type == DsTextFieldType.mobilephone) {
                return widget.onSave('+7 9' + value);
              }
              return widget.onSave(value);
            },
          ),
        ],
      ),
    );
  }

  void _initFieldByType(int type) {
    switch (type) {
      case DsTextFieldType.mobilephone:
        _keyboardType = TextInputType.phone;
        _textController ??= TextEditingController(
          text: widget.initValue?.replaceFirst('+7 9', ''),
        );
        _maskFormatter = MaskTextInputFormatter(
          mask: '## #######',
          filter: {"#": RegExp(r'[0-9]')},
        );
        break;
      case DsTextFieldType.text:
      case DsTextFieldType.password:
        // Изменено на TextInputType.visiblePassword так как
        // Bug 31613: МП. На клавиатуре samsung дубликация строки в полях ввода после символов . @ (Если включен режим T9 интеллектуальный набор)
        _keyboardType = TextInputType.visiblePassword;
        _textController ??= TextEditingController(
          text: widget.initValue,
        );
        break;
      case DsTextFieldType.email:
        // Изменено на TextInputType.visiblePassword так как
        // Bug 31613: МП. На клавиатуре samsung дубликация строки в полях ввода после символов . @ (Если включен режим T9 интеллектуальный набор)
        _keyboardType = TextInputType.visiblePassword;
        _textController ??= TextEditingController(
          text: widget.initValue,
        );
        break;
      default:
        _keyboardType = TextInputType.text;
        _textController ??= TextEditingController(
          text: widget.initValue,
        );
        break;
    }
    // _hintText = _getHintText(type);
    _prefixText = _getPrefixText(type);

    var oldTextValue = TextEditingValue(text: '');
    var newTextValue = TextEditingValue(text: _textController?.text ?? '');
    _maskFormatter?.formatEditUpdate(oldTextValue, newTextValue);
  }

  String _getPrefixText(int type) {
    switch (widget.type) {
      case DsTextFieldType.mobilephone:
        return '+7 9';
    }
    return null;
  }

  @override
  void dispose() {
    _typeSubscription?.cancel();
    _textController?.removeListener(handleChange);
    if (widget.customTextEditingController == null) {
      _textController?.dispose();
    }
    super.dispose();
  }
}
