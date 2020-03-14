import 'package:flutter/material.dart';

import 'selector.dart';

abstract class DsFieldBaseWidget<S> extends StatefulWidget {
  final String labelText;

  /// use [isRequired] from [state] instead
  final bool isRequired;

  /// use [isDisabled] from [state] instead
  final bool isDisabled;
  final void Function(S value) onChange;

  final FocusNode focusNode;

  const DsFieldBaseWidget({
    Key key,
    @required this.labelText,
    this.isRequired = false,
    this.isDisabled = false,
    this.onChange,
    this.focusNode,
  }) : super(key: key);
}

mixin DsFieldBaseState<T extends DsFieldBaseWidget<S>, S> on State<T> {
  bool _didInitState = false;

  /// init it in [initState]
  /// needs for [isEmptyField] check
  @protected
  ValueNotifier fieldController;

  @protected
  bool showRequired = true;
  @protected
  bool showNotRequired = true;

  @protected
  FocusNode focusNode;

  @protected
  bool checkFieldMask() {
    return true;
  }

  @protected
  dynamic get controllerValue {
    if (fieldController is TextEditingController) {
      return (fieldController as TextEditingController).text;
    }
    if (fieldController is DsSelectorController) {
      return (fieldController as DsSelectorController).option;
    }
  }

  @mustCallSuper
  void didInitState() {
    if (widget.focusNode != null) {
      focusNode = widget.focusNode;
    }

    focusNode ??= FocusNode();
  }

  @protected
  void handleChange() {
    if (checkFieldMask() != false && widget.onChange != null) {
      widget.onChange(controllerValue);
    }
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (!_didInitState) {
      didInitState();
      _didInitState = true;
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    checkFieldMask();
  }

  @override
  void dispose() {
    focusNode?.unfocus();
    // focusNode?.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      focusNode?.dispose();
    }
    super.dispose();
  }

  @protected
  bool get isFieldEmpty {
    if (fieldController is TextEditingController) {
      return isTextFieldEmpty((fieldController as TextEditingController).text);
    }
    if (fieldController is DsSelectorController) {
      return isSelectorFieldEmpty(
          (fieldController as DsSelectorController).option);
    }
    return false;
  }

  static bool isTextFieldEmpty(String text) {
    return text?.trim()?.isEmpty != false;
  }

  static bool isSelectorFieldEmpty(dynamic option) {
    return option == null;
  }
}
