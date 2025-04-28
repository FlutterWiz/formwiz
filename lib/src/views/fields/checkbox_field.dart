import 'package:flutter/material.dart';

import '../../view_models/form_field_bloc.dart' as formwiz;
import 'base_field.dart';

/// A checkbox field for forms
class FormWizCheckbox extends FormWizBaseField<bool> {
  /// Custom color for the active checkbox
  final Color? activeColor;

  /// Custom color for the checkbox border
  final Color? checkColor;

  /// Custom shape for the checkbox
  final OutlinedBorder? shape;

  /// Side (border) configuration for the checkbox
  final BorderSide? side;

  /// The visual density of the checkbox
  final VisualDensity? visualDensity;

  const FormWizCheckbox({
    super.key,
    required super.name,
    super.initialValue = false,
    super.enabled,
    super.decoration = const InputDecoration(),
    super.validators = const [],
    super.onChanged,
    super.focusNode,
    super.autoValidate,
    super.fieldBloc,
    super.valueTransformer,
    super.visibilityCondition,
    this.activeColor,
    this.checkColor,
    this.shape,
    this.side,
    this.visualDensity,
  });

  @override
  State<FormWizCheckbox> createState() => _FormWizCheckboxState();
}

class _FormWizCheckboxState extends FormWizBaseFieldState<bool, FormWizCheckbox> {
  @override
  Widget buildFieldWidget(
    BuildContext context,
    formwiz.FormFieldState<bool> state,
    InputDecoration decoration,
    bool enabled,
  ) {
    return InputDecorator(
      decoration: decoration,
      child: Row(
        children: [
          Checkbox(
            value: state.model.value ?? false,
            onChanged: enabled ? (value) => onFieldValueChanged(value) : null,
            activeColor: widget.activeColor,
            checkColor: widget.checkColor,
            shape: widget.shape,
            side: widget.side,
            visualDensity: widget.visualDensity,
            focusNode: focusNode,
          ),
          if (decoration.labelText != null)
            Expanded(
              child: GestureDetector(
                onTap: enabled ? () => onFieldValueChanged(!(state.model.value ?? false)) : null,
                child: Text(
                  decoration.labelText!,
                  style: decoration.labelStyle ?? Theme.of(context).inputDecorationTheme.labelStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
