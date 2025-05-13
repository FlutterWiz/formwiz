import 'package:equatable/equatable.dart';

import 'package:formwiz/src/core/field/field_value.dart';

/// Form submission status
enum FormSubmissionStatus {
  /// Initial state - not submitted
  initial,
  
  /// Form is being submitted
  submitting,
  
  /// Form was successfully submitted
  success,
  
  /// Form submission failed
  failure;

  bool get isInitial => this == FormSubmissionStatus.initial;
  bool get isSubmitting => this == FormSubmissionStatus.submitting;
  bool get isSuccess => this == FormSubmissionStatus.success; 
  bool get isFailure => this == FormSubmissionStatus.failure;
}

/// Form state that contains all field values and submission status
class FormState extends Equatable {
  final Map<String, FieldValue> fields;
  final FormSubmissionStatus status;
  final String? error;

  const FormState({
    this.fields = const {},
    this.status = FormSubmissionStatus.initial,
    this.error,
  });

  /// Creates an initial form state
  factory FormState.initial() => const FormState(
    
  );

  /// Whether the form has any validation errors
  bool get isValid => !fields.values.any((field) => field.error != null);

  /// Get all field values as a map
  Map<String, dynamic> get values => {
    for (final entry in fields.entries)
      entry.key: entry.value.value,
  };

  /// Create a copy with some properties changed
  FormState copyWith({
    Map<String, FieldValue>? fields,
    FormSubmissionStatus? status,
    String? error,
    bool clearError = false,
  }) {
    return FormState(
      fields: fields ?? this.fields,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Updates a field in the form
  FormState updateField(FieldValue fieldValue) {
    final newFields = Map<String, FieldValue>.from(fields);
    newFields[fieldValue.name] = fieldValue;
    
    return copyWith(fields: newFields);
  }

  /// Removes a field from the form
  FormState removeField(String name) {
    final newFields = Map<String, FieldValue>.from(fields);
    newFields.remove(name);
    
    return copyWith(fields: newFields);
  }

  @override
  List<Object?> get props => [fields, status, error];
} 