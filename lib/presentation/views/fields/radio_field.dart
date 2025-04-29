import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/domain/models/validation_model.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_state.dart';

/// A radio group field widget that integrates with FormWiz
class FormWizRadioField<T> extends StatefulWidget {
  /// Unique name for the field
  final String name;

  /// Initial value of the field
  final T? initialValue;

  /// Available options
  final List<FormWizRadioOption<T>> options;

  /// List of validators for the field
  final List<FormWizValidator<T>> validators;

  /// Title for the radio group
  final String? title;

  /// Title widget for the radio group
  final Widget? titleWidget;

  /// Whether to display options horizontally
  final bool horizontal;

  /// Whether to validate on change
  final bool validateOnChange;

  /// Whether to validate on blur
  final bool validateOnBlur;

  /// Creates a new FormWizRadioField
  const FormWizRadioField({
    Key? key,
    required this.name,
    required this.options,
    this.initialValue,
    this.validators = const [],
    this.title,
    this.titleWidget,
    this.horizontal = false,
    this.validateOnChange = true,
    this.validateOnBlur = true,
  }) : super(key: key);

  @override
  _FormWizRadioFieldState<T> createState() => _FormWizRadioFieldState<T>();
}

/// An option for the radio field
class FormWizRadioOption<T> {
  /// Value of the option
  final T value;

  /// Label for the option
  final String label;

  /// Creates a new radio option
  const FormWizRadioOption({required this.value, required this.label});
}

class _FormWizRadioFieldState<T> extends State<FormWizRadioField<T>> {
  late final FormFieldCubit<T> _fieldCubit;

  @override
  void initState() {
    super.initState();

    _fieldCubit = FormFieldCubit<T>(
      name: widget.name,
      initialValue: widget.initialValue,
      validators: widget.validators,
      validateOnChange: widget.validateOnChange,
      validateOnBlur: widget.validateOnBlur,
    );

    // Add field to form
    final formCubit = context.read<FormCubit>();
    formCubit.addField(_fieldCubit);
  }

  @override
  void dispose() {
    _fieldCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormFieldCubit<T>, FormFieldCubitState<T>>(
      bloc: _fieldCubit,
      builder: (context, state) {
        final errorText = state.model.shouldShowError ? state.model.errorMessage : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.titleWidget != null)
              widget.titleWidget!
            else if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(widget.title!, style: Theme.of(context).textTheme.titleMedium),
              ),
            if (widget.horizontal)
              Row(children: _buildRadioOptions(state))
            else
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildRadioOptions(state)),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                child: Text(errorText, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.0)),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildRadioOptions(FormFieldCubitState<T> state) {
    return widget.options.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: widget.horizontal ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Radio<T>(
              value: option.value,
              groupValue: state.model.value,
              onChanged: (value) {
                if (value != null) {
                  _fieldCubit.updateValue(value);
                }
              },
            ),
            GestureDetector(
              onTap: () {
                _fieldCubit.updateValue(option.value);
              },
              child: Text(option.label),
            ),
          ],
        ),
      );
    }).toList();
  }
}
