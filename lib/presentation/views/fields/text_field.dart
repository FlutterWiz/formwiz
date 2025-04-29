import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/domain/models/validation_model.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_state.dart';

/// A text field widget that integrates with FormWiz
class FormWizTextField extends StatefulWidget {
  /// Unique name for the field
  final String name;
  
  /// Initial value of the field
  final String? initialValue;
  
  /// List of validators for the field
  final List<FormWizValidator<String>> validators;
  
  /// Decoration for the field
  final InputDecoration decoration;
  
  /// Whether to hide the text (for passwords)
  final bool obscureText;
  
  /// Maximum lines for the field
  final int? maxLines;
  
  /// Keyboard type for the field
  final TextInputType? keyboardType;
  
  /// Text input action
  final TextInputAction? textInputAction;
  
  /// Focus node for the field
  final FocusNode? focusNode;
  
  /// Whether to auto-focus the field
  final bool autofocus;
  
  /// Whether to validate on value change
  final bool validateOnChange;
  
  /// Whether to validate on blur
  final bool validateOnBlur;
  
  /// Text style for the field
  final TextStyle? style;
  
  /// Creates a new FormWizTextField
  const FormWizTextField({
    Key? key,
    required this.name,
    this.initialValue,
    this.validators = const [],
    this.decoration = const InputDecoration(),
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.validateOnChange = false,
    this.validateOnBlur = true,
    this.style,
  }) : super(key: key);
  
  @override
  _FormWizTextFieldState createState() => _FormWizTextFieldState();
}

class _FormWizTextFieldState extends State<FormWizTextField> {
  late final FormFieldCubit<String> _fieldCubit;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _fieldCubit = FormFieldCubit<String>(
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
    
    // Update controller when field value changes
    _fieldCubit.stream.listen((state) {
      final value = state.model.value ?? '';
      if (_controller.text != value) {
        _controller.text = value;
      }
    });
  }
  
  @override
  void dispose() {
    // Cleanup
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
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
    return BlocBuilder<FormFieldCubit<String>, FormFieldCubitState<String>>(
      bloc: _fieldCubit,
      builder: (context, state) {
        final InputDecoration decoration = widget.decoration.copyWith(
          errorText: state.model.shouldShowError ? state.model.errorMessage : null,
        );
        
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: decoration,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          style: widget.style,
          onChanged: (value) {
            _fieldCubit.updateValue(value);
          },
        );
      },
    );
  }
} 