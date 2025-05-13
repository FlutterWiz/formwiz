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
    
    // Try to get form cubit from context
    final formCubit = context.read<FormCubit?>();
    
    _cubit = CheckboxGroupFieldCubit(
      name: widget.name,
      options: widget.options,
      initialValues: widget.initialValues,
      validators: widget.validators,
      formCubit: formCubit,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormWizCheckboxGroupField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If key properties changed, recreate the cubit
    if (oldWidget.name != widget.name ||
        oldWidget.options != widget.options ||
        oldWidget.validators != widget.validators) {
      _cubit.close();
      
      final formCubit = context.read<FormCubit?>();
      _cubit = CheckboxGroupFieldCubit(
        name: widget.name,
        options: widget.options,
        initialValues: widget.initialValues,
        validators: widget.validators,
        formCubit: formCubit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CheckboxGroupFieldCubit, CheckboxGroupFieldState>(
        builder: (context, state) {
          // Custom builder takes precedence
          if (widget.builder != null) {
            return widget.builder!(
              context,
              state.value,
              state.options,
              state.isValid,
              state.error,
              (option) {
                if (!widget.disabled) {
                  _cubit.toggleOption(option);
                }
              },
            );
          }

          // Default checkbox group implementation
          return Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: widget.checkboxTheme,
            ),
            child: FormField<List<String>>(
              initialValue: state.value,
              validator: (_) => state.error,
              builder: (formFieldState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.labelText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          widget.labelText!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ...state.options.map((option) {
                      final isSelected = state.value.contains(option);
                      final label = widget.optionLabels?[option] ?? option;

                      if (widget.optionBuilder != null) {
                        return widget.optionBuilder!(
                          context,
                          option,
                          label,
                          isSelected,
                          widget.disabled ? () {} : () => _cubit.toggleOption(option),
                        );
                      }

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
                    }).toList(),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
} 