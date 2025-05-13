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
  
  // Track field touched state to avoid showing errors before interaction
  final Map<String, bool> touchedFields;
  
  // Separately track which fields have validation errors
  // This allows us to enable the submit button based on validation
  // without showing error messages until fields are touched
  final Map<String, bool> fieldValidationStatus;

  const FormState({
    this.fields = const {},
    this.status = FormSubmissionStatus.initial,
    this.error,
    this.touchedFields = const {},
    this.fieldValidationStatus = const {},
  });

  /// Creates an initial form state
  factory FormState.initial() => const FormState();

  /// Whether the form has any validation errors
  /// This determines if the submit button is enabled
  bool get isValid => !fieldValidationStatus.values.contains(false);

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
    Map<String, bool>? touchedFields,
    Map<String, bool>? fieldValidationStatus,
  }) {
    return FormState(
      fields: fields ?? this.fields,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      touchedFields: touchedFields ?? this.touchedFields,
      fieldValidationStatus: fieldValidationStatus ?? this.fieldValidationStatus,
    );
  }

  /// Updates a field in the form
  FormState updateField(FieldValue fieldValue) {
    final newFields = Map<String, FieldValue>.from(fields);
    newFields[fieldValue.name] = fieldValue;
    
    // Update touched state if the field is dirty
    final newTouchedFields = Map<String, bool>.from(touchedFields);
    if (fieldValue.isDirty) {
      newTouchedFields[fieldValue.name] = true;
    }
    
    // Update validation status
    final newFieldValidationStatus = Map<String, bool>.from(fieldValidationStatus);
    newFieldValidationStatus[fieldValue.name] = fieldValue.error == null;
    
    return copyWith(
      fields: newFields,
      touchedFields: newTouchedFields,
      fieldValidationStatus: newFieldValidationStatus,
    );
  }

  /// Removes a field from the form
  FormState removeField(String name) {
    final newFields = Map<String, FieldValue>.from(fields);
    newFields.remove(name);
    
    final newTouchedFields = Map<String, bool>.from(touchedFields);
    newTouchedFields.remove(name);
    
    final newFieldValidationStatus = Map<String, bool>.from(fieldValidationStatus);
    newFieldValidationStatus.remove(name);
    
    return copyWith(
      fields: newFields,
      touchedFields: newTouchedFields,
      fieldValidationStatus: newFieldValidationStatus,
    );
  }

  @override
  List<Object?> get props => [fields, status, error, touchedFields, fieldValidationStatus];
} 