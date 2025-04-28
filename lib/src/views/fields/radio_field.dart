import 'package:flutter/material.dart';

import '../../view_models/form_field_bloc.dart' as formwiz;
import 'base_field.dart';

/// A radio button field for forms
class FormWizRadio<T> extends FormWizBaseField<T> {
  /// List of radio options
  final List<T> options;

  /// Function to create labels for each option
  final String Function(T)? labelBuilder;

  /// Radio button active color
  final Color? activeColor;

  /// Function to create title widgets for each option
  final Widget Function(T)? titleBuilder;

  /// Position of the radio button relative to the label
  final ListTileControlAffinity controlAffinity;

  /// Content padding for each radio option
  final EdgeInsetsGeometry? contentPadding;

  /// Toggle density of the list tile
  final VisualDensity? toggleDensity;

  const FormWizRadio({
    super.key,
    required super.name,
    required this.options,
    super.initialValue,
    super.enabled,
    super.decoration = const InputDecoration(),
    super.validators = const [],
    super.onChanged,
    super.focusNode,
    super.autoValidate,
    super.fieldBloc,
    super.valueTransformer,
    super.visibilityCondition,
    this.labelBuilder,
    this.activeColor,
    this.titleBuilder,
    this.controlAffinity = ListTileControlAffinity.trailing,
    this.contentPadding,
    this.toggleDensity,
  });

  @override
  State<FormWizRadio<T>> createState() => _FormWizRadioState<T>();
}

class _FormWizRadioState<T> extends FormWizBaseFieldState<T, FormWizRadio<T>> {
  @override
  Widget buildFieldWidget(
    BuildContext context,
    formwiz.FormFieldState<T> state,
    InputDecoration decoration,
    bool enabled,
  ) {
    return InputDecorator(
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.options.map((option) {
            return RadioListTile<T>(
              title:
                  widget.titleBuilder != null
                      ? widget.titleBuilder!(option)
                      : Text(widget.labelBuilder?.call(option) ?? option.toString()),
              value: option,
              groupValue: state.model.value,
              onChanged: enabled ? (value) => onFieldValueChanged(value) : null,
              controlAffinity: widget.controlAffinity,
              activeColor: widget.activeColor,
              contentPadding: widget.contentPadding,
              dense: widget.toggleDensity != null,
              visualDensity: widget.toggleDensity,
            );
          }),
        ],
      ),
    );
  }
}
