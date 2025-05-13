import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/fields/checkbox_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/src/core/field/field_state.dart';

/// A single checkbox field for use with FormWiz
///
/// This widget provides a checkbox with label and error message display.
/// It can be validated and integrates with FormWiz forms.
class FormWizCheckboxField extends StatefulWidget {
  /// Field name (used as key in form data)
  final String name;

  /// Text label displayed next to the checkbox
  final String? labelText;

  /// Initial value of the checkbox
  final bool initialValue;

  /// Whether the checkbox is disabled
  final bool disabled;

  /// List of validators for this field
  final List<FieldValidator<bool>> validators;

  /// Custom builder for the checkbox
  ///
  /// Allows complete customization of the checkbox appearance and behavior.
  final Widget Function(
    BuildContext context,
    bool value,
    bool isValid,
    String? errorText,
    void Function(bool) onChanged,
  )? builder;

  /// Theme data for the checkbox
  final CheckboxThemeData? checkboxTheme;

  /// Creates a new checkbox field
  ///
  /// [name] is required and serves as the identifier in form data.
  /// [labelText] is optional and appears next to the checkbox.
  /// [initialValue] determines if the checkbox starts checked or unchecked.
  /// [disabled] when true prevents user interaction.
  /// [validators] are functions that validate the checkbox value.
  /// [builder] allows custom rendering of the checkbox.
  /// [checkboxTheme] provides styling for the checkbox when using the default appearance.
  const FormWizCheckboxField({
    super.key,
    required this.name,
    this.labelText,
    this.initialValue = false,
    this.disabled = false,
    this.validators = const [],
    this.builder,
    this.checkboxTheme,
  });

  @override
  State<FormWizCheckboxField> createState() => _FormWizCheckboxFieldState();
}

class _FormWizCheckboxFieldState extends State<FormWizCheckboxField> {
  late CheckboxFieldCubit _cubit;

  @override
  void initState() {
    super.initState();
    _initCubit();
  }
  
  /// Initialize the field cubit with appropriate configuration
  void _initCubit() {
    // Try to get form cubit from context
    final formCubit = _getFormCubit();
    
    _cubit = CheckboxFieldCubit(
      name: widget.name,
      initialValue: widget.initialValue,
      validators: widget.validators,
      formCubit: formCubit,
    );
  }
  
  /// Safely retrieves the FormCubit from context
  FormCubit? _getFormCubit() {
    try {
      return context.read<FormCubit?>();
    } catch (_) {
      return null; // No form found or provider error
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormWizCheckboxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only recreate the cubit if key properties changed
    if (_shouldRecreateField(oldWidget)) {
      _cubit.close();
      _initCubit();
    }
  }
  
  /// Determines if we need to recreate the field cubit
  bool _shouldRecreateField(FormWizCheckboxField oldWidget) {
    return oldWidget.name != widget.name || 
           oldWidget.validators != widget.validators;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CheckboxFieldCubit, CheckboxFieldState>(
        builder: (context, state) {
          return widget.builder != null
              ? _buildCustomCheckbox(context, state)
              : _buildDefaultCheckbox(context, state);
        },
      ),
    );
  }
  
  /// Builds custom checkbox using the provided builder function
  Widget _buildCustomCheckbox(BuildContext context, CheckboxFieldState state) {
    return widget.builder!(
      context,
      state.value,
      state.isValid,
      // Only show error if field has been touched
      state.touched ? state.error : null,
      (value) {
        if (!widget.disabled) {
          _cubit.setValue(value);
        }
      },
    );
  }
  
  /// Builds the default checkbox implementation
  Widget _buildDefaultCheckbox(BuildContext context, CheckboxFieldState state) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: widget.checkboxTheme,
      ),
      child: FormField<bool>(
        initialValue: state.value,
        validator: (_) => state.touched ? state.error : null,
        builder: (formFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckboxRow(state),
              if (state.touched && state.error != null)
                _buildErrorMessage(context, state.error!),
            ],
          );
        },
      ),
    );
  }
  
  /// Builds the checkbox and label row
  Widget _buildCheckboxRow(CheckboxFieldState state) {
    return Row(
      children: [
        Checkbox(
          value: state.value,
          onChanged: widget.disabled
              ? null
              : (_) => _cubit.toggle(),
        ),
        if (widget.labelText != null)
          Expanded(
            child: GestureDetector(
              onTap: widget.disabled ? null : () => _cubit.toggle(),
              child: Text(widget.labelText!),
            ),
          ),
      ],
    );
  }
  
  /// Builds the error message display
  Widget _buildErrorMessage(BuildContext context, String errorText) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        errorText,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }
} 