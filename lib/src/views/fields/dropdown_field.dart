import 'package:flutter/material.dart';

import '../../view_models/form_field_bloc.dart' as formwiz;
import 'base_field.dart';

/// A dropdown option item
class FormWizDropdownOption<T> {
  /// The value of the option
  final T value;
  
  /// The label to display
  final String label;
  
  /// Optional widget to display instead of a text label
  final Widget? child;
  
  /// Creates a dropdown option
  const FormWizDropdownOption({
    required this.value,
    required this.label,
    this.child,
  });
}

/// A high-performance dropdown field for forms.
class FormWizDropdown<T> extends FormWizBaseField<T> {
  /// List of dropdown options
  final List<FormWizDropdownOption<T>> options;
  
  /// Whether the dropdown is dense
  final bool isDense;
  
  /// Icon displayed next to the dropdown button
  final Widget? icon;
  
  /// Style for the dropdown items
  final TextStyle? itemStyle;
  
  /// Border radius for the dropdown
  final BorderRadius? borderRadius;
  
  /// Dropdown elevation
  final int elevation;
  
  /// Color of the dropdown menu
  final Color? dropdownColor;

  const FormWizDropdown({
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
    this.isDense = false,
    this.icon,
    this.itemStyle,
    this.borderRadius,
    this.elevation = 8,
    this.dropdownColor,
  });

  @override
  State<FormWizDropdown<T>> createState() => _FormWizDropdownState<T>();
}

class _FormWizDropdownState<T> extends FormWizBaseFieldState<T, FormWizDropdown<T>> {
  @override
  Widget buildFieldWidget(
    BuildContext context, 
    formwiz.FormFieldState<T> state, 
    InputDecoration decoration, 
    bool enabled
  ) {
    // Transform options to dropdown menu items
    final dropdownItems = widget.options.map<DropdownMenuItem<T>>((option) {
      return DropdownMenuItem<T>(
        value: option.value,
        child: option.child ?? Text(option.label, style: widget.itemStyle),
      );
    }).toList();
    
    return InputDecorator(
      decoration: decoration,
      isEmpty: state.model.value == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: state.model.value,
          items: dropdownItems,
          isDense: widget.isDense,
          icon: widget.icon,
          elevation: widget.elevation,
          dropdownColor: widget.dropdownColor,
          focusNode: focusNode,
          isExpanded: true,
          borderRadius: widget.borderRadius,
          onChanged: enabled
              ? (value) => onFieldValueChanged(value)
              : null,
        ),
      ),
    );
  }
} 