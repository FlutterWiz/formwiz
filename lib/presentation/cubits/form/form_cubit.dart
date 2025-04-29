// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart';
import 'package:formwiz/presentation/cubits/form/form_state.dart';

/// Cubit that manages form state
///
/// Follows MVVM architecture as the ViewModel layer for forms
class FormCubit extends Cubit<FormCubitState> {
  /// Subscriptions to field cubits
  final Map<String, StreamSubscription> _fieldSubscriptions = {};

  /// Initial values to preserve for reset
  final Map<String, dynamic> _initialValues = {};

  /// Debounce timer for validation
  Timer? _debounceTimer;

  /// Debounce duration for validation
  final Duration _debounceDuration;

  /// Whether to validate on value changes
  final bool validateOnChange;

  FormCubit({Duration? debounceDuration, this.validateOnChange = true})
    : _debounceDuration = debounceDuration ?? const Duration(milliseconds: 300),
      super(FormInitial());

  @override
  Future<void> close() {
    _cancelDebounce();

    // Cancel all field subscriptions
    for (final subscription in _fieldSubscriptions.values) {
      subscription.cancel();
    }
    _fieldSubscriptions.clear();

    return super.close();
  }

  /// Initialize the form with initial values
  void initialize({Map<String, dynamic> initialValues = const {}}) {
    // Store initial values for reset
    _initialValues.addAll(initialValues);

    // Initialize fields with values if provided
    if (initialValues.isNotEmpty) {
      for (final entry in initialValues.entries) {
        final fieldCubit = state.fields[entry.key];
        if (fieldCubit != null) {
          fieldCubit.initialize(entry.value);
        }
      }
    }

    // Collect current values
    final values = _collectValues();

    emit(FormValidationSuccess(fields: state.fields, values: values, isDirty: false));
  }

  /// Add a field to the form
  void addField(FormFieldCubit fieldCubit) {
    // Avoid duplicate field names
    if (state.fields.containsKey(fieldCubit.name)) {
      removeField(fieldCubit.name);
    }

    // Create new fields map with the added field
    final fields = Map<String, FormFieldCubit>.from(state.fields);
    fields[fieldCubit.name] = fieldCubit;

    // Initialize field with initial value if available
    if (_initialValues.containsKey(fieldCubit.name)) {
      fieldCubit.initialize(_initialValues[fieldCubit.name]);
    }

    // Subscribe to field state changes
    _subscribeToFieldChanges(fieldCubit);

    // Collect updated values
    final values = _collectValues();

    // Update form state
    emit(FormValidationSuccess(fields: fields, values: values, isDirty: state.isDirty));

    // Check validation if validateOnChange is true
    if (validateOnChange) {
      validate();
    }
  }

  /// Remove a field from the form
  void removeField(String fieldName) {
    if (!state.fields.containsKey(fieldName)) {
      return;
    }

    // Unsubscribe from field changes
    _unsubscribeFromFieldChanges(fieldName);

    // Create new fields map without the removed field
    final fields = Map<String, FormFieldCubit>.from(state.fields);
    fields.remove(fieldName);

    // Collect updated values
    final values = Map<String, dynamic>.from(state.values);
    values.remove(fieldName);

    // Update form state
    emit(
      FormValidationSuccess(
        fields: fields,
        values: values,
        isDirty: state.isDirty,
        hasBeenSubmitted: state.hasBeenSubmitted,
      ),
    );
  }

  /// Validate the form
  Future<bool> validate({bool forceValidation = false}) async {
    if (state.fields.isEmpty) {
      emit(
        FormValidationSuccess(
          fields: state.fields,
          values: state.values,
          isDirty: state.isDirty,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
      return true;
    }

    // Set validating state - Using FormValidationSuccess with isValidating=true
    emit(
      FormValidationSuccess(
        fields: state.fields,
        values: state.values,
        isValidating: true,
        isDirty: state.isDirty,
        hasBeenSubmitted: state.hasBeenSubmitted,
      ),
    );

    // Validate all fields
    final validationResults = <String, String?>{};

    for (final field in state.fields.values) {
      await field.validate(field.state.model.value, forceValidation: forceValidation);

      final fieldState = field.state;
      if (fieldState.model.errorMessage != null) {
        validationResults[field.name] = fieldState.model.errorMessage;
      }
    }

    // Collect updated values
    final values = _collectValues();

    // Update form state based on validation results
    if (validationResults.isEmpty) {
      emit(
        FormValidationSuccess(
          fields: state.fields,
          values: values,
          isDirty: state.isDirty,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
      return true;
    } else {
      emit(
        FormValidationFailure(
          fields: state.fields,
          values: values,
          errors: validationResults,
          isDirty: state.isDirty,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
      return false;
    }
  }

  /// Submit the form
  Future<bool> submit({
    void Function(Map<String, dynamic> values)? onSuccess,
    void Function(Map<String, String?> errors)? onFailure,
  }) async {
    // Validate all fields before submission
    final isValid = await validate(forceValidation: true);

    if (!isValid) {
      if (onFailure != null && state is FormValidationFailure) {
        onFailure((state as FormValidationFailure).errors);
      }
      return false;
    }

    // Set submitting state
    emit(FormSubmitting(fields: state.fields, values: state.values, isValid: true, isDirty: state.isDirty));

    try {
      // Execute success callback if provided
      if (onSuccess != null) {
        onSuccess(state.values);
      }

      // Set submission success state
      emit(FormSubmissionSuccess(fields: state.fields, values: state.values, isValid: true, isDirty: state.isDirty));

      return true;
    } catch (e) {
      // Set submission failure state
      emit(
        FormSubmissionFailure(
          fields: state.fields,
          values: state.values,
          isValid: true,
          errorMessage: e.toString(),
          isDirty: state.isDirty,
        ),
      );

      return false;
    }
  }

  /// Reset the form to its initial state
  void reset() {
    // Reset all fields
    for (final field in state.fields.values) {
      field.reset();
    }

    // Collect updated values
    final values = _collectValues();

    // Update form state
    emit(FormValidationSuccess(fields: state.fields, values: values, isDirty: false, hasBeenSubmitted: false));
  }

  /// Patch form values
  void patchValue(Map<String, dynamic> values, {bool validateFields = true}) {
    // Update field values
    for (final entry in values.entries) {
      final fieldCubit = state.fields[entry.key];
      if (fieldCubit != null) {
        fieldCubit.updateValue(entry.value, validateImmediately: validateFields);
      }
    }

    // Collect updated values
    final updatedValues = _collectValues();

    // Update form state
    final currentState = state;
    if (currentState is FormValidationSuccess) {
      emit(
        FormValidationSuccess(
          fields: state.fields,
          values: updatedValues,
          isDirty: true,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
    } else if (currentState is FormValidationFailure) {
      emit(
        FormValidationFailure(
          fields: state.fields,
          values: updatedValues,
          errors: currentState.errors,
          isDirty: true,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
    } else {
      // Use FormValidationSuccess as default concrete implementation
      emit(
        FormValidationSuccess(
          fields: state.fields,
          values: updatedValues,
          isSubmitting: state.isSubmitting,
          isValidating: state.isValidating,
          hasBeenSubmitted: state.hasBeenSubmitted,
          isDirty: true,
        ),
      );
    }

    // Validate form if requested
    if (validateFields) {
      _debounceValidation();
    }
  }

  /// Collect values from all fields
  Map<String, dynamic> _collectValues() {
    final values = <String, dynamic>{};

    for (final entry in state.fields.entries) {
      values[entry.key] = entry.value.state.model.value;
    }

    return values;
  }

  /// Subscribe to field changes
  void _subscribeToFieldChanges(FormFieldCubit fieldCubit) {
    // Unsubscribe if already subscribed
    _unsubscribeFromFieldChanges(fieldCubit.name);

    // Subscribe to field state changes
    _fieldSubscriptions[fieldCubit.name] = fieldCubit.stream.listen((_) {
      // Field state changed, update form state
      final values = _collectValues();

      // Mark form as dirty if values changed
      final isDirty = !const DeepCollectionEquality().equals(values, _initialValues);

      // Debounce validation if validateOnChange is true
      if (validateOnChange) {
        _debounceValidation();
      }

      // Update form state
      final currentState = state;
      if (currentState is FormValidationSuccess) {
        emit(
          FormValidationSuccess(
            fields: state.fields,
            values: values,
            isDirty: isDirty,
            hasBeenSubmitted: state.hasBeenSubmitted,
          ),
        );
      } else if (currentState is FormValidationFailure) {
        // Remove error for the updated field
        final errors = Map<String, String?>.from(currentState.errors);
        errors.remove(fieldCubit.name);

        emit(
          errors.isEmpty
              ? FormValidationSuccess(
                fields: state.fields,
                values: values,
                isDirty: isDirty,
                hasBeenSubmitted: state.hasBeenSubmitted,
              )
              : FormValidationFailure(
                fields: state.fields,
                values: values,
                errors: errors,
                isDirty: isDirty,
                hasBeenSubmitted: state.hasBeenSubmitted,
              ),
        );
      } else {
        // Use FormValidationSuccess as default concrete implementation
        emit(
          FormValidationSuccess(
            fields: state.fields,
            values: values,
            isSubmitting: state.isSubmitting,
            isValidating: state.isValidating,
            hasBeenSubmitted: state.hasBeenSubmitted,
            isDirty: isDirty,
          ),
        );
      }
    });
  }

  /// Unsubscribe from field changes
  void _unsubscribeFromFieldChanges(String fieldName) {
    final subscription = _fieldSubscriptions.remove(fieldName);
    if (subscription != null) {
      subscription.cancel();
    }
  }

  /// Debounce validation
  void _debounceValidation() {
    _cancelDebounce();
    _debounceTimer = Timer(_debounceDuration, () {
      if (!isClosed) {
        validate();
      }
    });
  }

  /// Cancel validation debounce
  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
