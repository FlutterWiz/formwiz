import 'package:equatable/equatable.dart';

import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/core/field/field_value.dart';

/// Base state for field cubits
abstract class FieldState<T> extends Equatable {
  /// Field name (used as key in form data)
  final String name;
  
  /// Current value
  final T value;
  
  /// Whether the field has been modified
  final bool isDirty;
  
  /// Whether the user has interacted with the field
  final bool touched;
  
  /// Validation error message, if any
  final String? error;

  const FieldState({
    required this.name,
    required this.value,
    this.isDirty = false,
    this.touched = false,
    this.error,
  });

  /// Whether this field has no validation errors
  bool get isValid => error == null;

  @override
  List<Object?> get props => [name, value, isDirty, touched, error];
  
  /// Convert to FieldValue for form submission
  FieldValue<T> toFieldValue() => FieldValue<T>(
    name: name,
    value: value,
    isDirty: isDirty,
    error: error,
  );
  
  /// Validate value against validators
  String? validate(List<FieldValidator<T>> validators) {
    for (final validator in validators) {
      if (!validator.isValid(value)) {
        return validator.errorMessage;
      }
    }
    return null;
  }
}

/// Field state for checkbox fields
class CheckboxFieldState extends FieldState<bool> {
  const CheckboxFieldState({
    required super.name,
    required super.value,
    super.isDirty,
    super.touched,
    super.error,
  });

  /// Creates an initial state with default values
  factory CheckboxFieldState.initial({
    required String name,
    bool initialValue = false,
  }) => CheckboxFieldState(
    name: name,
    value: initialValue,
  );

  /// Create a copy with some properties changed
  CheckboxFieldState copyWith({
    String? name,
    bool? value,
    bool? isDirty,
    bool? touched,
    String? error,
    bool clearError = false,
  }) {
    return CheckboxFieldState(
      name: name ?? this.name,
      value: value ?? this.value,
      isDirty: isDirty ?? this.isDirty,
      touched: touched ?? this.touched,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Field state for checkbox group fields
class CheckboxGroupFieldState extends FieldState<List<String>> {
  /// Available options for this checkbox group
  final List<String> options;
  
  const CheckboxGroupFieldState({
    required super.name,
    required super.value,
    required this.options,
    super.isDirty,
    super.touched,
    super.error,
  });

  /// Creates an initial state with default values
  factory CheckboxGroupFieldState.initial({
    required String name,
    required List<String> options,
    List<String>? initialValues,
  }) => CheckboxGroupFieldState(
    name: name,
    value: initialValues ?? [],
    options: options,
  );

  /// Create a copy with some properties changed
  CheckboxGroupFieldState copyWith({
    String? name,
    List<String>? value,
    List<String>? options,
    bool? isDirty,
    bool? touched,
    String? error,
    bool clearError = false,
  }) {
    return CheckboxGroupFieldState(
      name: name ?? this.name,
      value: value ?? this.value,
      options: options ?? this.options,
      isDirty: isDirty ?? this.isDirty,
      touched: touched ?? this.touched,
      error: clearError ? null : (error ?? this.error),
    );
  }
  
  @override
  List<Object?> get props => [...super.props, options];
} 