import 'dart:async';

/// Function type for synchronous validators
typedef ValidationFunction<T> = String? Function(T? value);

/// Function type for asynchronous validators
typedef AsyncValidationFunction<T> = Future<String?> Function(T? value);

/// Base class for all validators
class FormWizValidator<T> {
  /// Error message to display when validation fails
  final String message;
  
  /// Whether this is a required field validator
  final bool isRequired;
  
  /// Function that performs validation
  final ValidationFunction<T> validate;
  
  /// Optional asynchronous validation function
  final AsyncValidationFunction<T>? asyncValidate;

  const FormWizValidator({
    required this.message,
    required this.validate,
    this.asyncValidate,
    this.isRequired = false,
  });
  
  /// Creates a required field validator
  static FormWizValidator<T> required<T>(String message) {
    return FormWizValidator<T>(
      message: message,
      isRequired: true,
      validate: (value) {
        if (value == null) return message;
        if (value is String && value.isEmpty) return message;
        if (value is List && value.isEmpty) return message;
        if (value is Map && value.isEmpty) return message;
        return null;
      },
    );
  }
  
  /// Creates an email validator
  static FormWizValidator<String> email(String message) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return FormWizValidator<String>(
      message: message,
      validate: (value) {
        if (value == null || value.isEmpty) return null;
        if (!emailRegex.hasMatch(value)) return message;
        return null;
      },
    );
  }
  
  /// Creates a minimum length validator
  static FormWizValidator<String> minLength(int length, String message) {
    return FormWizValidator<String>(
      message: message,
      validate: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.length < length) return message;
        return null;
      },
    );
  }
  
  /// Creates a maximum length validator
  static FormWizValidator<String> maxLength(int length, String message) {
    return FormWizValidator<String>(
      message: message,
      validate: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.length > length) return message;
        return null;
      },
    );
  }
  
  /// Creates a pattern validator
  static FormWizValidator<String> pattern(RegExp pattern, String message) {
    return FormWizValidator<String>(
      message: message,
      validate: (value) {
        if (value == null || value.isEmpty) return null;
        if (!pattern.hasMatch(value)) return message;
        return null;
      },
    );
  }
  
  /// Creates a custom validator using a provided function
  static FormWizValidator<T> custom<T>(ValidationFunction<T> validator, String message) {
    return FormWizValidator<T>(
      message: message,
      validate: validator,
    );
  }
  
  /// Creates an asynchronous validator
  static FormWizValidator<T> async<T>(AsyncValidationFunction<T> validator, String message) {
    return FormWizValidator<T>(
      message: message,
      validate: (_) => null, // Synchronous validation always passes
      asyncValidate: validator,
    );
  }
} 