import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/domain/models/validation_model.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_state.dart';

/// A dropdown field widget that integrates with FormWiz
class FormWizDropdownField<T> extends StatefulWidget {
  /// Unique name for the field
  final String name;

  /// Initial value of the field
  final T? initialValue;

  /// Available items for the dropdown
  final List<DropdownMenuItem<T>> items;

  /// List of validators for the field
  final List<FormWizValidator<T>> validators;

  /// Decoration for the field
  final InputDecoration decoration;

  /// Whether to validate on change
  final bool validateOnChange;

  /// Whether to validate on blur
  final bool validateOnBlur;

  /// Focus node for the field
  final FocusNode? focusNode;

  /// Creates a new FormWizDropdownField
  const FormWizDropdownField({
    Key? key,
    required this.name,
    required this.items,
    this.initialValue,
    this.validators = const [],
    this.decoration = const InputDecoration(),
    this.validateOnChange = false,
    this.validateOnBlur = true,
    this.focusNode,
  }) : super(key: key);

  @override
  _FormWizDropdownFieldState<T> createState() => _FormWizDropdownFieldState<T>();
}

class _FormWizDropdownFieldState<T> extends State<FormWizDropdownField<T>> {
  late final FormFieldCubit<T> _fieldCubit;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();

    _fieldCubit = FormFieldCubit<T>(
      name: widget.name,
      initialValue: widget.initialValue,
      validators: widget.validators,
      validateOnChange: widget.validateOnChange,
      validateOnBlur: widget.validateOnBlur,
      decoration: widget.decoration,
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
    return BlocBuilder<FormFieldCubit<T>, FormFieldCubitState<T>>(
      bloc: _fieldCubit,
      builder: (context, state) {
        final InputDecoration decoration = widget.decoration.copyWith(
          errorText: state.model.shouldShowError ? state.model.errorMessage : null,
        );

        return DropdownButtonFormField<T>(
          focusNode: _focusNode,
          decoration: decoration,
          value: state.model.value,
          items: widget.items,
          onChanged: (value) {
            _fieldCubit.updateValue(value);
          },
        );
      },
    );
  }
}
