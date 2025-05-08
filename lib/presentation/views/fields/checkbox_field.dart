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

  /// Visual density of the checkbox
  final VisualDensity? visualDensity;

  /// Checkbox active color
  final Color? activeColor;

  /// Checkbox fill color
  final WidgetStateProperty<Color?>? fillColor;

  /// Checkbox check color
  final Color? checkColor;

  /// Checkbox overlay color
  final WidgetStateProperty<Color?>? overlayColor;

  /// Checkbox shape
  final OutlinedBorder? shape;

  /// Side of the checkbox
  final BorderSide? side;

  /// Style for the error text
  final TextStyle? errorStyle;

  /// Style for the label text
  final TextStyle? labelStyle;

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
    this.visualDensity,
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.overlayColor,
    this.shape,
    this.side,
    this.errorStyle,
    this.labelStyle,
  }) : super(key: key);

  @override
  State<FormWizCheckboxField> createState() => _FormWizCheckboxFieldState();
}

class _FormWizCheckboxFieldState extends State<FormWizCheckboxField> {
  late final FormFieldCubit<bool> _fieldCubit;
  late final FocusNode _focusNode;

  // Performance optimization: Check if the field is already registered with the form
  bool _isRegistered = false;

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

    // Setup focus listeners
    _focusNode.addListener(_handleFocusChange);

    // Delay form registration until after the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerWithForm();
    });
  }

  void _registerWithForm() {
    if (!_isRegistered && mounted) {
      final formCubit = context.read<FormCubit>();
      formCubit.addField(_fieldCubit);
      _isRegistered = true;
    }
  }

  @override
  void didUpdateWidget(FormWizCheckboxField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if validators changed and update if needed
    if (widget.validators != oldWidget.validators) {
      // Use the new updateValidators method we've added to FormFieldCubit
      _fieldCubit.updateValidators(widget.validators);
    }
  }

  @override
  void dispose() {
    // Cleanup
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);

    // Only close the cubit if we registered it
    if (_isRegistered) {
      _fieldCubit.close();
    }

    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _fieldCubit.focus();
    } else {
      _fieldCubit.blur();
    }
  }

  void _handleValueChange(bool? value) {
    _fieldCubit.updateValue(value ?? false);
  }

  void _toggleValue(FormFieldCubitState<bool> state) {
    final newValue = !(state.model.value ?? false);
    _fieldCubit.updateValue(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormFieldCubit<bool>, FormFieldCubitState<bool>>(
      bloc: _fieldCubit,
      buildWhen: (previous, current) {
        // Performance optimization: Only rebuild if relevant properties change
        return previous.model.value != current.model.value ||
            previous.model.errorMessage != current.model.errorMessage ||
            previous.model.touched != current.model.touched;
      },
      builder: (context, state) {
        final errorText = state.model.shouldShowError ? state.model.errorMessage : null;
        final theme = Theme.of(context);
        final defaultErrorStyle = TextStyle(color: theme.colorScheme.error, fontSize: 12.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  focusNode: _focusNode,
                  value: state.model.value ?? false,
                  onChanged: state.model.enabled ? _handleValueChange : null,
                  visualDensity: widget.visualDensity,
                  activeColor: widget.activeColor,
                  fillColor: widget.fillColor,
                  checkColor: widget.checkColor,
                  overlayColor: widget.overlayColor,
                  shape: widget.shape,
                  side: widget.side,
                ),
                if (widget.label != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: state.model.enabled ? () => _toggleValue(state) : null,
                      child: widget.label!,
                    ),
                  )
                else if (widget.labelText != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: state.model.enabled ? () => _toggleValue(state) : null,
                      child: Text(widget.labelText!, style: widget.labelStyle),
                    ),
                  ),
              ],
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(errorText, style: widget.errorStyle ?? defaultErrorStyle),
              ),
          ],
        );
      },
    );
  }
}
