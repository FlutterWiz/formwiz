import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/domain/models/validation_model.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_state.dart';

/// A checkbox field widget that integrates with FormWiz
class FormWizCheckboxField extends StatefulWidget {
  /// Unique name for the field
  final String name;

  /// Initial value of the field
  final bool? initialValue;

  /// List of validators for the field
  final List<FormWizValidator<bool>> validators;

  /// Label widget to display next to the checkbox
  final Widget? label;

  /// Label text to display next to the checkbox (alternative to label widget)
  final String? labelText;

  /// Whether to validate on change
  final bool validateOnChange;

  /// Whether to validate on blur
  final bool validateOnBlur;

  /// Focus node for the field
  final FocusNode? focusNode;

  /// Creates a new FormWizCheckboxField
  const FormWizCheckboxField({
    Key? key,
    required this.name,
    this.initialValue = false,
    this.validators = const [],
    this.label,
    this.labelText,
    this.validateOnChange = true,
    this.validateOnBlur = true,
    this.focusNode,
  }) : super(key: key);

  @override
  _FormWizCheckboxFieldState createState() => _FormWizCheckboxFieldState();
}

class _FormWizCheckboxFieldState extends State<FormWizCheckboxField> {
  late final FormFieldCubit<bool> _fieldCubit;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();

    _fieldCubit = FormFieldCubit<bool>(
      name: widget.name,
      initialValue: widget.initialValue ?? false,
      validators: widget.validators,
      validateOnChange: widget.validateOnChange,
      validateOnBlur: widget.validateOnBlur,
    );

    // Add field to form
    final formCubit = context.read<FormCubit>();
    formCubit.addField(_fieldCubit);

    // Setup focus listeners
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    // Cleanup
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _fieldCubit.close();

    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _fieldCubit.focus();
    } else {
      _fieldCubit.blur();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormFieldCubit<bool>, FormFieldCubitState<bool>>(
      bloc: _fieldCubit,
      builder: (context, state) {
        final errorText = state.model.shouldShowError ? state.model.errorMessage : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  focusNode: _focusNode,
                  value: state.model.value ?? false,
                  onChanged: (value) {
                    _fieldCubit.updateValue(value ?? false);
                  },
                ),
                if (widget.label != null)
                  Expanded(child: widget.label!)
                else if (widget.labelText != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final newValue = !(state.model.value ?? false);
                        _fieldCubit.updateValue(newValue);
                      },
                      child: Text(widget.labelText!),
                    ),
                  ),
              ],
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(errorText, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.0)),
              ),
          ],
        );
      },
    );
  }
}
