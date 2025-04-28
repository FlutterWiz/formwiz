import 'package:flutter/material.dart';
import 'validation_model.dart';

/// Base model for all form fields.
class FormFieldModel<T> {
  /// Unique identifier for the field
  final String name;
  
  /// Current value of the field
  final T? value;
  
  /// Initial value of the field
  final T? initialValue;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Decoration for the field
  final InputDecoration? decoration;
  
  /// List of validators for the field
  final List<FormWizValidator<T>> validators;
  
  /// Current error message, if any
  final String? errorMessage;
  
  /// Whether the field has been touched by the user
  final bool touched;
  
  /// Whether the field is currently validating asynchronously
  final bool isValidating;
  
  /// Whether the field is valid
  bool get isValid => errorMessage == null && !isValidating;
  
  /// Whether the field is required
  bool get isRequired => validators.any((v) => v.isRequired);

  const FormFieldModel({
    required this.name,
    this.value,
    this.initialValue,
    this.enabled = true,
    this.decoration,
    this.validators = const [],
    this.errorMessage,
    this.touched = false,
    this.isValidating = false,
  });
  
  /// Creates a copy of this model with the given fields replaced with new values
  FormFieldModel<T> copyWith({
    String? name,
    T? value,
    T? initialValue,
    bool? enabled,
    InputDecoration? decoration,
    List<FormWizValidator<T>>? validators,
    String? errorMessage,
    bool? touched,
    bool? isValidating,
  }) {
    return FormFieldModel<T>(
      name: name ?? this.name,
      value: value ?? this.value,
      initialValue: initialValue ?? this.initialValue,
      enabled: enabled ?? this.enabled,
      decoration: decoration ?? this.decoration,
      validators: validators ?? this.validators,
      errorMessage: errorMessage,
      touched: touched ?? this.touched,
      isValidating: isValidating ?? this.isValidating,
    );
  }
} 