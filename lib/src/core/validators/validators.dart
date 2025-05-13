import 'package:formwiz/src/core/validators/field_validator.dart';

/// Commonly used validators that can be directly used with form fields
abstract class FormWizValidator {
  /// Required field validator - checks if value is not null and not empty
  static FieldValidator<T> required<T>(String errorMessage) => RequiredValidator<T>(errorMessage);
}

/// Validates if the field has a value
class RequiredValidator<T> extends FieldValidator<T> {
  const RequiredValidator(super.errorMessage);

  @override
  bool isValid(T? value) {
    if (value == null) return false;
    
    if (value is String) return value.trim().isNotEmpty;
    if (value is bool) return value;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    
    return true;
  }
} 