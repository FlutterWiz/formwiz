import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/presentation/cubits/fields/checkbox_group_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// A group of checkboxes that can be selected independently
class FormWizCheckboxGroupField extends StatefulWidget {
  /// Field name (used as key in form data)
  final String name;

  /// Optional group title/label
  final String? labelText;
  
  /// List of available options
  final List<String> options;
  
  /// Option labels (if different from option values)
  final Map<String, String>? optionLabels;

  /// Pre-selected values
  final List<String>? initialValues;

  /// Whether the checkbox group is disabled
  final bool disabled;

  /// List of validators for this field
  final List<FieldValidator<List<String>>> validators;

  /// Custom builder for the checkbox group
  final Widget Function(
    BuildContext context,
    List<String> selectedValues,
    List<String> options,
    bool isValid,
    String? errorText,
    void Function(String) onToggle,
  )? builder;

  /// Custom builder for individual options
  final Widget Function(
    BuildContext context,
    String option,
    String label,
    bool isSelected,
    void Function() onToggle,
  )? optionBuilder;

  /// Theme data for the checkboxes
  final CheckboxThemeData? checkboxTheme;

  /// Creates a new checkbox group field
  const FormWizCheckboxGroupField({
    super.key,
    required this.name,
    this.labelText,
    required this.options,
    this.optionLabels,
    this.initialValues,
    this.disabled = false,
    this.validators = const [],
    this.builder,
    this.optionBuilder,
    this.checkboxTheme,
  });

  @override
  State<FormWizCheckboxGroupField> createState() => _FormWizCheckboxGroupFieldState();
}

class _FormWizCheckboxGroupFieldState extends State<FormWizCheckboxGroupField> {
  late CheckboxGroupFieldCubit _cubit;

  @override
  void initState() {
    super.initState();
    _initCubit();
  }
  
  void _initCubit() {
    // Try to get form cubit from context
    final formCubit = _getFormCubit();
    
    _cubit = CheckboxGroupFieldCubit(
      name: widget.name,
      options: widget.options,
      initialValues: widget.initialValues,
      validators: widget.validators,
      formCubit: formCubit,
    );
  }
  
  FormCubit? _getFormCubit() {
    try {
      return context.read<FormCubit?>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormWizCheckboxGroupField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only recreate the cubit if key properties changed
    if (_shouldRecreateField(oldWidget)) {
      _cubit.close();
      _initCubit();
    }
  }
  
  bool _shouldRecreateField(FormWizCheckboxGroupField oldWidget) {
    return oldWidget.name != widget.name || 
           oldWidget.options != widget.options ||
           oldWidget.validators != widget.validators;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CheckboxGroupFieldCubit, CheckboxGroupFieldState>(
        builder: (context, state) {
          return widget.builder != null
              ? _buildCustomCheckboxGroup(context, state)
              : _buildDefaultCheckboxGroup(context, state);
        },
      ),
    );
  }
  
  Widget _buildCustomCheckboxGroup(BuildContext context, CheckboxGroupFieldState state) {
    return widget.builder!(
      context,
      state.value,
      state.options,
      state.isValid,
      // Only show error if field has been touched
      state.touched ? state.error : null,
      (option) {
        if (!widget.disabled) {
          _cubit.toggleOption(option);
        }
      },
    );
  }
  
  Widget _buildDefaultCheckboxGroup(BuildContext context, CheckboxGroupFieldState state) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: widget.checkboxTheme,
      ),
      child: FormField<List<String>>(
        initialValue: state.value,
        validator: (_) => state.touched ? state.error : null,
        builder: (formFieldState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.labelText != null)
                _buildGroupLabel(context),
              ...state.options.map((option) => _buildCheckboxOption(context, state, option)).toList(),
              if (state.touched && state.error != null)
                _buildErrorMessage(context, state.error!),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildGroupLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        widget.labelText!,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
  
  Widget _buildCheckboxOption(BuildContext context, CheckboxGroupFieldState state, String option) {
    final isSelected = state.value.contains(option);
    final label = widget.optionLabels?[option] ?? option;
    
    // Use custom option builder if provided
    if (widget.optionBuilder != null) {
      return widget.optionBuilder!(
        context,
        option,
        label,
        isSelected,
        widget.disabled ? () {} : () => _cubit.toggleOption(option),
      );
    }
    
    // Default option layout
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: widget.disabled
              ? null
              : (_) => _cubit.toggleOption(option),
        ),
        Expanded(
          child: GestureDetector(
            onTap: widget.disabled ? null : () => _cubit.toggleOption(option),
            child: Text(label),
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorMessage(BuildContext context, String errorText) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
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