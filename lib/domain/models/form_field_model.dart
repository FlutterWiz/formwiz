import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:formwiz/domain/models/validation_model.dart';

/// Base model for all form fields.
/// Follows MVVM architecture as the model layer for form fields.
@immutable
class FormFieldModel<T> extends Equatable {
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

  /// Whether the field has been focused at least once
  final bool wasFocused;
  
  /// Whether the field is valid
  bool get isValid => errorMessage == null && !isValidating;
  
  /// Whether the field is required
  bool get isRequired => validators.any((v) => v.isRequired);

  /// Whether the field should show error
  bool get shouldShowError => touched && errorMessage != null;

  /// Creates a new form field model instance
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
    this.wasFocused = false,
  });
  
  /// Creates a copy of this model with the given fields replaced with new values
  FormFieldModel<T> copyWith({
    String? name,
    Object? value = _undefined,
    Object? initialValue = _undefined,
    bool? enabled,
    InputDecoration? decoration,
    List<FormWizValidator<T>>? validators,
    Object? errorMessage = _undefined,
    bool? touched,
    bool? isValidating,
    bool? wasFocused,
  }) {
    return FormFieldModel<T>(
      name: name ?? this.name,
      value: value == _undefined ? this.value : value as T?,
      initialValue: initialValue == _undefined ? this.initialValue : initialValue as T?,
      enabled: enabled ?? this.enabled,
      decoration: decoration ?? this.decoration,
      validators: validators ?? this.validators,
      errorMessage: errorMessage == _undefined ? this.errorMessage : errorMessage as String?,
      touched: touched ?? this.touched,
      isValidating: isValidating ?? this.isValidating,
      wasFocused: wasFocused ?? this.wasFocused,
    );
  }

  /// Reset the field to its initial state
  FormFieldModel<T> reset() {
    return copyWith(
      value: initialValue,
      errorMessage: null,
      touched: false,
      isValidating: false,
    );
  }

  /// Mark the field as touched
  FormFieldModel<T> touch() {
    return copyWith(touched: true);
  }

  /// Mark the field as focused
  FormFieldModel<T> focus() {
    return copyWith(wasFocused: true);
  }

  /// Set the field value
  FormFieldModel<T> setValue(T? value) {
    return copyWith(value: value);
  }

  /// Set the field error message
  FormFieldModel<T> setError(String? errorMessage) {
    return copyWith(errorMessage: errorMessage);
  }

  /// Set the field validation state
  FormFieldModel<T> setValidating(bool isValidating) {
    return copyWith(isValidating: isValidating);
  }

  @override
  List<Object?> get props => [
    name,
    value,
    initialValue,
    enabled,
    decoration,
    validators,
    errorMessage,
    touched,
    isValidating,
    wasFocused,
  ];
  
  @override
  bool get stringify => true;
}

// Used for the copyWith method to determine if a parameter was provided
const _undefined = Object(); 