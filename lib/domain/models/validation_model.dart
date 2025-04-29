import 'dart:async';
import 'package:meta/meta.dart';

/// Validator function type for synchronous validation
typedef ValidatorFunction<T> = String? Function(T? value);

/// Validator function type for asynchronous validation
typedef AsyncValidatorFunction<T> = Future<String?> Function(T? value);

/// Validator class for form field validation
@immutable
class FormWizValidator<T> {
  /// Synchronous validator function
  final ValidatorFunction<T> validate;

  /// Optional asynchronous validator function
  final AsyncValidatorFunction<T>? asyncValidate;

  /// Whether this validator checks for required values
  final bool isRequired;

  /// Creates a validator with a synchronous validation function
  /// and an optional asynchronous validation function
  const FormWizValidator(this.validate, {this.asyncValidate, this.isRequired = false});

  /// Creates a required field validator
  static FormWizValidator<T> required<T>([String? message]) {
    return FormWizValidator<T>((value) {
      if (value == null) {
        return message ?? 'This field is required';
      }

      if (value is String && value.isEmpty) {
        return message ?? 'This field is required';
      }

      if (value is Iterable && value.isEmpty) {
        return message ?? 'This field is required';
      }

      return null;
    }, isRequired: true,);
  }

  /// Creates an email validator
  static FormWizValidator<String> email([String? message]) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    return FormWizValidator<String>((value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }

      return null;
    });
  }

  /// Creates a minimum length validator for strings
  static FormWizValidator<String> minLength(int length, [String? message]) {
    return FormWizValidator<String>((value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (value.length < length) {
        return message ?? 'Minimum length is $length characters';
      }

      return null;
    });
  }

  /// Creates a maximum length validator for strings
  static FormWizValidator<String> maxLength(int length, [String? message]) {
    return FormWizValidator<String>((value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (value.length > length) {
        return message ?? 'Maximum length is $length characters';
      }

      return null;
    });
  }

  /// Creates a minimum value validator for numbers
  static FormWizValidator<num> min(num minValue, [String? message]) {
    return FormWizValidator<num>((value) {
      if (value == null) {
        return null;
      }

      if (value < minValue) {
        return message ?? 'Value must be at least $minValue';
      }

      return null;
    });
  }

  /// Creates a maximum value validator for numbers
  static FormWizValidator<num> max(num maxValue, [String? message]) {
    return FormWizValidator<num>((value) {
      if (value == null) {
        return null;
      }

      if (value > maxValue) {
        return message ?? 'Value must be at most $maxValue';
      }

      return null;
    });
  }

  /// Creates a pattern validator for strings
  static FormWizValidator<String> pattern(RegExp pattern, [String? message]) {
    return FormWizValidator<String>((value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!pattern.hasMatch(value)) {
        return message ?? 'Invalid format';
      }

      return null;
    });
  }

  /// Creates a custom validator from a function
  static FormWizValidator<T> custom<T>(ValidatorFunction<T> validate, [String? message, bool isRequired = false]) {
    return FormWizValidator<T>(validate, isRequired: isRequired);
  }

  /// Creates a custom async validator from a function
  static FormWizValidator<T> async<T>(
    AsyncValidatorFunction<T> asyncValidate, [
    String? message,
    bool isRequired = false,
  ]) {
    return FormWizValidator<T>((value) => null, asyncValidate: asyncValidate, isRequired: isRequired);
  }
}

/// Exception thrown when validation fails
class ValidationException implements Exception {
  final String message;
  final Map<String, String?> errors;

  ValidationException(this.message, [this.errors = const {}]);

  @override
  String toString() => 'ValidationException: $message, errors: $errors';
}
