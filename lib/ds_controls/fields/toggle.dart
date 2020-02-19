import 'package:flutter/material.dart';

class ToggleController extends ValueNotifier<bool> {
  ToggleController(bool value) : super(value);
}

class ToggleFormField extends FormField<bool> {
  final ToggleController controller;
  final FontWeight fontWeight;

  ToggleFormField({
    @required bool initValue,
    @required String labelText,
    this.onChange,
    isDisabled = false,
    this.controller,
    this.fontWeight,
    FormFieldSetter<bool> onSave,
  }) : super(
          enabled: !isDisabled,
          initialValue: initValue ?? false,
          onSaved: onSave,
          builder: (FormFieldState<bool> state) {
            return SwitchListTile(
              value: state.value ?? false,
              onChanged: isDisabled
                  ? null
                  : (newValue) {
                      if (controller != null) {
                        controller.value = newValue;
                      } else {
                        state.didChange(newValue);
                      }
                    },
              title: Text(
                labelText,
                style: TextStyle(fontWeight: fontWeight),
                softWrap: true,
              ),
            );
          },
        );

  /// Called when the user switch toggle.
  final ValueChanged<bool> onChange;

  @override
  FormFieldState<bool> createState() => _ToggleFormFieldState();
}

class _ToggleFormFieldState extends FormFieldState<bool> {
  @override
  ToggleFormField get widget => super.widget;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(updateValueFromController);
  }

  @override
  void didChange(bool value) {
    if (widget.onChange != null) {
      widget.onChange(value);
    }
    super.didChange(value);
  }

  void updateValueFromController() {
    var newValue = widget.controller?.value;
    if (newValue != value) {
      didChange(newValue);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(updateValueFromController);
    super.dispose();
  }
}
