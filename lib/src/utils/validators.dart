import '../models/validation_model.dart';

/// Utility class providing ready-to-use validators for FormWiz.
class FormWizValidators {
  /// Creates a required field validator
  static FormWizValidator<T> required<T>(String message) {
    return FormWizValidator.required<T>(message);
  }
  
  /// Creates an email validator
  static FormWizValidator<String> email(String message) {
    return FormWizValidator.email(message);
  }
  
  /// Creates a minimum length validator
  static FormWizValidator<String> minLength(int length, String message) {
    return FormWizValidator.minLength(length, message);
  }
  
  /// Creates a maximum length validator
  static FormWizValidator<String> maxLength(int length, String message) {
    return FormWizValidator.maxLength(length, message);
  }
  
  /// Creates a pattern validator
  static FormWizValidator<String> pattern(RegExp pattern, String message) {
    return FormWizValidator.pattern(pattern, message);
  }
  
  /// Creates a matches validator
  static FormWizValidator<String> matches(String value, String message) {
    return FormWizValidator<String>(
      message: message,
      validate: (val) {
        if (val == null || val.isEmpty) return null;
        if (val != value) return message;
        return null;
      },
    );
  }
  
  /// Creates a min value validator for numbers
  static FormWizValidator<num> min(num min, String message) {
    return FormWizValidator<num>(
      message: message,
      validate: (val) {
        if (val == null) return null;
        if (val < min) return message;
        return null;
      },
    );
  }
  
  /// Creates a max value validator for numbers
  static FormWizValidator<num> max(num max, String message) {
    return FormWizValidator<num>(
      message: message,
      validate: (val) {
        if (val == null) return null;
        if (val > max) return message;
        return null;
      },
    );
  }
  
  /// Creates a range validator for numbers
  static FormWizValidator<num> range(num min, num max, String message) {
    return FormWizValidator<num>(
      message: message,
      validate: (val) {
        if (val == null) return null;
        if (val < min || val > max) return message;
        return null;
      },
    );
  }
  
  /// Creates a validator for URLs
  static FormWizValidator<String> url(String message) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$'
    );
    return FormWizValidator<String>(
      message: message,
      validate: (val) {
        if (val == null || val.isEmpty) return null;
        if (!urlRegex.hasMatch(val)) return message;
        return null;
      },
    );
  }
  
  /// Creates a validator for phone numbers
  static FormWizValidator<String> phone(String message) {
    final phoneRegex = RegExp(r'^\+?[\d\s]{8,}$');
    return FormWizValidator<String>(
      message: message,
      validate: (val) {
        if (val == null || val.isEmpty) return null;
        if (!phoneRegex.hasMatch(val)) return message;
        return null;
      },
    );
  }
  
  /// Creates a custom validator using a provided function
  static FormWizValidator<T> custom<T>(ValidationFunction<T> validator, String message) {
    return FormWizValidator.custom<T>(validator, message);
  }
  
  /// Creates an asynchronous validator
  static FormWizValidator<T> async<T>(AsyncValidationFunction<T> validator, String message) {
    return FormWizValidator.async<T>(validator, message);
  }
  
  /// Composes multiple validators into one
  static FormWizValidator<T> compose<T>(List<FormWizValidator<T>> validators) {
    return FormWizValidator<T>(
      message: '',
      validate: (val) {
        for (final validator in validators) {
          final error = validator.validate(val);
          if (error != null) return error;
        }
        return null;
      },
      asyncValidate: validators.any((v) => v.asyncValidate != null)
          ? (val) async {
              for (final validator in validators) {
                if (validator.asyncValidate != null) {
                  final error = await validator.asyncValidate!(val);
                  if (error != null) return error;
                }
              }
              return null;
            }
          : null,
    );
  }
} 