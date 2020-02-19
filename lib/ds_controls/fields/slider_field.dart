
import 'package:flutter/material.dart';

class SliderFormField extends FormField<int> {
  SliderFormField({
    @required int initValue,
    @required String labelText,
    @required int min,
    @required int max,
    isDisabled = false,
    FormFieldSetter<int> onSave,
  })  : assert(max != null && min != null),
        assert(max > min),
        super(
          enabled: !isDisabled,
          initialValue: initValue ?? 0,
          onSaved: onSave,
          builder: (FormFieldState<int> state) {
            TextStyle labelStyle;
            if (isDisabled) {
              labelStyle =
                  TextStyle(color: Theme.of(state.context).disabledColor);
            } else {
              labelStyle = TextStyle(color: Theme.of(state.context).hintColor);
            }

            return Padding(
              key: ValueKey(isDisabled),
              padding:
                  EdgeInsets.only(left: 16, right: 16, bottom: 8.0, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 8.0, bottom: 4.0, right: 8.0),
                    child: Text(
                      labelText,
                      style: labelStyle,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(min.toString()),
                      Flexible(
                        flex: 1,
                        child: Slider(
                            min: min.toDouble(),
                            max: max.toDouble(),
                            divisions: max - min,
                            label: state.value?.toString(),
                            value: state.value?.toDouble(),
                            onChanged: isDisabled
                                ? null
                                : (newValue) {
                                    if (newValue != state.value) {
                                      state.didChange(newValue.toInt());
                                    }
                                  }),
                      ),
                      Text(max.toString()),
                    ],
                  ),
                ],
              ),
            );
          },
        );
}
