import 'package:meta/meta.dart';

/// Base class for all field validators
@immutable
abstract class FieldValidator<T> {
  const FieldValidator(this.errorMessage);

  /// The error message to display when validation fails
  final String errorMessage;

  /// Validates the field value and returns true if valid, false otherwise
  bool isValid(T? value);
} 