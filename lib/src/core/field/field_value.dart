import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A generic class representing a field's value with associated metadata
@immutable
class FieldValue<T> extends Equatable {
  const FieldValue({
    required this.name,
    required this.value,
    this.isDirty = false,
    this.error,
  });

  /// Creates a new field value with initial value
  factory FieldValue.initial({
    required String name,
    required T value,
  }) => FieldValue<T>(
    name: name,
    value: value,
  );

  /// Name of the field (used as key in form)
  final String name;

  /// Current value
  final T value;

  /// Whether field has been modified
  final bool isDirty;

  /// Error message if any
  final String? error;

  /// Whether field is valid (no errors)
  bool get isValid => error == null;

  /// Create a copy with some properties changed
  FieldValue<T> copyWith({
    String? name,
    T? value,
    bool? isDirty,
    String? error,
    bool clearError = false,
  }) {
    return FieldValue<T>(
      name: name ?? this.name,
      value: value ?? this.value,
      isDirty: isDirty ?? this.isDirty,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [name, value, isDirty, error];
} 