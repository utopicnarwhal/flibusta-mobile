import 'package:flibusta/ds_controls/ui/progress_indicator.dart';

import '../theme.dart';
import '../ui/show_modal_bottom_sheet.dart';

import 'package:flibusta/constants.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import 'field_base.dart';

class DsSelectorController<T> extends ValueNotifier<T> {
  T get option => value;

  set option(T newOption) {
    value = newOption;
  }

  DsSelectorController({T option}) : super(option);
}

class DsSelector<T> extends DsFieldBaseWidget<T> {
  final T initValue;
  final List<T> getCollection;
  final DsSelectorController customSelectorController;
  final void Function(T) onSave;
  final bool selectOptionIfOne;

  const DsSelector({
    Key key,
    @required this.initValue,
    this.getCollection,
    @required this.onSave,
    this.customSelectorController,
    @required String labelText,
    void Function(T value) onChange,
    bool isRequired = false,
    bool isDisabled = false,
    this.selectOptionIfOne = true,
  }) : super(
          key: key,
          isDisabled: isDisabled,
          labelText: labelText,
          isRequired: isRequired,
          onChange: onChange,
        );

  @override
  _DsSelectorState<T> createState() => _DsSelectorState<T>();
}

class _DsSelectorState<T> extends State<DsSelector<T>>
    with DsFieldBaseState<DsSelector<T>, T> {
  DsSelectorController<T> _selectorController;

  @override
  void initState() {
    super.initState();

    if (widget.customSelectorController != null) {
      _selectorController = widget.customSelectorController;
    }

    _selectorController ??= DsSelectorController(
      option: widget.initValue,
    );
    fieldController = _selectorController;

    fieldController = _selectorController;
    _selectorController.addListener(handleChange);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectOptionIfOne &&
        widget.getCollection?.length == 1 &&
        _selectorController.option == null) {
      _selectorController.option = widget.getCollection[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdownIcon;
    if (widget.getCollection == null) {
      dropdownIcon = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 30, maxWidth: 30),
            child: DsCircularProgressIndicator(),
          ),
        ],
      );
    } else {
      dropdownIcon = Icon(
        EvaIcons.chevronDownOutline,
        size: 32,
      );
    }

    TextStyle labelStyle;
    TextStyle textStyle;
    labelStyle = TextStyle(color: Theme.of(context).hintColor);

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
          DsDropdownButtonFormField<T>(
            labelText: widget.labelText,
            controller: _selectorController,
            decoration: InputDecoration(
              enabled: widget.getCollection?.isEmpty != false,
              errorBorder: showRequired
                  ? Theme.of(context).inputDecorationTheme.border
                  : null,
              helperText: '',
              counterText: showNotRequired ? 'Не обязательно' : '',
            ),
            style: textStyle,
            dropdownIcon: dropdownIcon,
            validator: (value) {
              return null;
            },
            items: widget.getCollection,
            onChange: (selected) {},
            onSave: (value) {
              widget.onSave(value);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _selectorController?.removeListener(handleChange);

    if (widget.customSelectorController == null) {
      _selectorController?.dispose();
    }
    super.dispose();
  }
}

class DsDropdownButtonFormField<T> extends FormField<T> {
  final DsSelectorController<T> controller;
  final Widget dropdownIcon;
  final String labelText;
  final TextStyle style;

  DsDropdownButtonFormField({
    Key key,
    T value,
    @required List<T> items,
    this.onChange,
    this.controller,
    this.labelText,
    this.style,
    InputDecoration decoration = const InputDecoration(),
    FormFieldSetter<T> onSave,
    FormFieldValidator<T> validator,
    this.dropdownIcon,
  })  : assert(decoration != null),
        super(
          key: key,
          onSaved: onSave,
          initialValue: controller.option ?? value,
          validator: validator,
          enabled: onChange != null,
          builder: (FormFieldState<T> state) {
            final InputDecoration effectiveDecoration = decoration
                .applyDefaults(Theme.of(state.context).inputDecorationTheme);

            final double iconSize = effectiveDecoration.isDense ? 18.0 : 24.0;
            final Color iconColor =
                _getDefaultIconColor(Theme.of(state.context), decoration);

            var valueToDisplay;

            if (state.value?.toString()?.isEmpty == false) {
              valueToDisplay = state.value;
            } else if (items?.isEmpty == false) {
              valueToDisplay = items.firstWhere((item) => item == state.value,
                  orElse: () => null);
            }

            return GestureDetector(
              onTap: onChange == null || items?.isEmpty != false
                  ? null
                  : () async {
                      FocusScope.of(state.context).unfocus();

                      await showDsModalBottomSheet(
                        context: state.context,
                        title: labelText ?? '',
                        builder: (context) {
                          return ListView.separated(
                            physics: kBouncingAlwaysScrollableScrollPhysics,
                            shrinkWrap: true,
                            itemCount: items.length,
                            cacheExtent: 56,
                            addAutomaticKeepAlives: false,
                            addSemanticIndexes: false,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  items[index] != null
                                      ? items[index].toString()
                                      : '',
                                ),
                                trailing: state.value == items[index]
                                    ? Icon(
                                        EvaIcons.checkmarkOutline,
                                        size: 30,
                                        color: kSecondaryColor(context),
                                      )
                                    : null,
                                onTap: onChange == null
                                    ? null
                                    : () {
                                        var newValue = items[index];
                                        if (newValue != state.value) {
                                          if (controller != null) {
                                            controller.option = newValue;
                                          } else {
                                            state.didChange(newValue);
                                          }
                                        }
                                        Navigator.of(context).pop();
                                      },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(indent: 16);
                            },
                          );
                        },
                      );
                    },
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.topLeft,
                fit: StackFit.loose,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: kMinInteractiveDimension,
                        minHeight: kMinInteractiveDimension + 2,
                      ),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: iconColor,
                          size: iconSize,
                        ),
                        child: dropdownIcon,
                      ),
                    ),
                  ),
                  InputDecorator(
                    decoration: effectiveDecoration.copyWith(
                        errorText: state.errorText),
                    isEmpty: state.value == null,
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.all(1),
                        child: SingleChildScrollView(
                          physics: kBouncingAlwaysScrollableScrollPhysics,
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            (valueToDisplay ?? '').toString(),
                            maxLines: 1,
                            style: Theme.of(state.context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: style?.color),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

  final ValueChanged<T> onChange;

  static Color _getDefaultIconColor(
      ThemeData themeData, InputDecoration decoration) {
    if (!decoration.enabled) return themeData.disabledColor;

    switch (themeData.brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
      default:
        return themeData.iconTheme.color;
    }
  }

  @override
  FormFieldState<T> createState() => _DsDropdownButtonFormFieldState<T>();
}

class _DsDropdownButtonFormFieldState<T> extends FormFieldState<T> {
  @override
  DsDropdownButtonFormField<T> get widget => super.widget;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(updateValueFromController);
  }

  @override
  void didChange(T value) {
    if (widget.onChange != null) {
      widget.onChange(value);
    }
    super.didChange(value);
  }

  void updateValueFromController() {
    var newValue = widget.controller?.option;
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
