import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../view_models/form_field_bloc.dart' as formwiz;
import 'base_field.dart';

/// A high-performance text input widget for forms.
class FormWizTextField extends FormWizBaseField<String> {
  /// Keyboard type for the field
  final TextInputType? keyboardType;
  
  /// Text input action
  final TextInputAction? textInputAction;
  
  /// Text capitalization
  final TextCapitalization textCapitalization;
  
  /// Input formatters for the field
  final List<TextInputFormatter>? inputFormatters;
  
  /// Whether to obscure the text (for passwords)
  final bool obscureText;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Minimum number of lines
  final int? minLines;
  
  /// Maximum text length
  final int? maxLength;
  
  /// Text alignment
  final TextAlign textAlign;
  
  /// Text style
  final TextStyle? style;
  
  /// Cursor color
  final Color? cursorColor;
  
  /// Text direction
  final TextDirection? textDirection;
  
  /// Auto-focus on this field when displayed
  final bool autofocus;
  
  /// Whether to enable suggestions
  final bool enableSuggestions;

  const FormWizTextField({
    super.key,
    required super.name,
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
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
    this.cursorColor,
    this.textDirection,
    this.autofocus = false,
    this.enableSuggestions = true,
  });

  @override
  State<FormWizTextField> createState() => _FormWizTextFieldState();
}

class _FormWizTextFieldState extends FormWizBaseFieldState<String, FormWizTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }
  
  @override
  void onFieldBlocInitialized(formwiz.FormFieldBloc<String> fieldBloc) {
    // Initialize the controller if needed
    if (_controller.text.isEmpty && widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }
  
  @override
  void onFieldStateChanged(formwiz.FormFieldState<String> state) {
    // Update controller if value changed externally
    if (state.model.value != _controller.text && 
        state.model.value != null &&
        _controller.text != state.model.value) {
      _controller.text = state.model.value!;
    }
  }
  
  @override
  void didUpdateWidget(FormWizTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controller text if initialValue changed
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
      onFieldValueChanged(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildFieldWidget(
    BuildContext context, 
    formwiz.FormFieldState<String> state, 
    InputDecoration decoration, 
    bool enabled
  ) {
    return TextField(
      controller: _controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      enabled: enabled,
      inputFormatters: widget.inputFormatters,
      cursorColor: widget.cursorColor,
      enableSuggestions: widget.enableSuggestions,
      onChanged: (value) => onFieldValueChanged(value),
    );
  }
} 