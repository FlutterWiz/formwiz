import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/fields/checkbox_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/src/core/field/field_state.dart';

/// A single checkbox field for use with FormWiz
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
    
    // Try to get form cubit from context
    final formCubit = context.read<FormCubit?>();
    
    _cubit = CheckboxFieldCubit(
      name: widget.name,
      initialValue: widget.initialValue,
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
  void didUpdateWidget(covariant FormWizCheckboxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If key properties changed, recreate the cubit
    if (oldWidget.name != widget.name ||
        oldWidget.validators != widget.validators) {
      _cubit.close();
      
      final formCubit = context.read<FormCubit?>();
      _cubit = CheckboxFieldCubit(
        name: widget.name,
        initialValue: widget.initialValue,
        validators: widget.validators,
        formCubit: formCubit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<CheckboxFieldCubit, CheckboxFieldState>(
        builder: (context, state) {
          // Custom builder takes precedence
          if (widget.builder != null) {
            return widget.builder!(
              context,
              state.value,
              state.isValid,
              state.error,
              (value) {
                if (!widget.disabled) {
                  _cubit.setValue(value);
                }
              },
            );
          }

          // Default checkbox implementation
          return Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: widget.checkboxTheme,
            ),
            child: FormField<bool>(
              initialValue: state.value,
              validator: (_) => state.error,
              builder: (formFieldState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
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