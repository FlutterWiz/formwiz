import 'package:formwiz/domain/models/validation_model.dart';

/// Service class for form validation functions
class ValidationService {
  /// Required field validator
  static FormWizValidator<T> required<T>([String? message]) => FormWizValidator.required<T>(message);

  /// Email validator
  static FormWizValidator<String> email([String? message]) => FormWizValidator.email(message);

  /// Min length validator
  static FormWizValidator<String> minLength(int length, [String? message]) =>
      FormWizValidator.minLength(length, message);

  /// Max length validator
  static FormWizValidator<String> maxLength(int length, [String? message]) =>
      FormWizValidator.maxLength(length, message);

  /// Min value validator
  static FormWizValidator<num> min(num minValue, [String? message]) => FormWizValidator.min(minValue, message);

  /// Max value validator
  static FormWizValidator<num> max(num maxValue, [String? message]) => FormWizValidator.max(maxValue, message);

  /// Pattern validator
  static FormWizValidator<String> pattern(RegExp pattern, [String? message]) =>
      FormWizValidator.pattern(pattern, message);

  /// Custom validator
  static FormWizValidator<T> custom<T>(ValidatorFunction<T> validate, [String? message, bool isRequired = false]) =>
      FormWizValidator.custom<T>(validate, message, isRequired);

  /// Async validator
  static FormWizValidator<T> async<T>(
    AsyncValidatorFunction<T> asyncValidate, [
    String? message,
    bool isRequired = false,
  ]) => FormWizValidator.async<T>(asyncValidate, message, isRequired);
}
