import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/field/field_value.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Base cubit class for all form field types
/// Handles common operations like validation, form registration, etc.
abstract class BaseFieldCubit<T, S extends FieldState<T>> extends Cubit<S> {
  final List<FieldValidator<T>> validators;
  final FormCubit? formCubit;

  BaseFieldCubit({
    required S initialState,
    required this.validators,
    this.formCubit,
  }) : super(initialState) {
    // Register with form
    registerInitialValueWithForm();
  }

  /// Register the initial value with the form
  void registerInitialValueWithForm() {
    final value = state.value;
    final isValid = _isValueValid(value);
    
    // Create field value with proper validation status
    final fieldValue = FieldValue<T>(
      name: state.name,
      value: value,
      // Set error internally for validation tracking, but it won't be displayed
      // until the field is touched
      error: isValid ? null : _getValidationError(value),
    );
    
    // Register with the form
    formCubit?.registerField(fieldValue);
  }
  
  /// Check if a value is valid according to all validators
  bool _isValueValid(T value) {
    if (validators.isEmpty) return true;
    
    for (final validator in validators) {
      if (!validator.isValid(value)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get the first validation error message for a value
  String? _getValidationError(T value) {
    if (validators.isEmpty) return null;
    
    for (final validator in validators) {
      if (!validator.isValid(value)) {
        return validator.errorMessage;
      }
    }
    
    return null;
  }

  /// Run validation on the current or provided value
  String? validateValue([T? valueToValidate]) {
    final value = valueToValidate ?? state.value;
    return _getValidationError(value);
  }
  
  /// Update the field state with a new value and notify the form
  void updateState(S newState) {
    emit(newState);
    formCubit?.updateField(newState.toFieldValue());
  }
  
  /// Mark field as touched, showing validation errors if any
  void touch() {
    if (state.touched) return;
    
    final error = validateValue();
    updateStateWithTouch(error);
  }
  
  /// Update state to show touched state
  void updateStateWithTouch(String? error);
  
  /// Validate the field and update state if needed
  void validate() {
    final error = validateValue();
    
    if (error != state.error) {
      updateStateWithValidation(error);
    }
  }
  
  /// Update state with validation results
  void updateStateWithValidation(String? error);
  
  /// Reset the field to its initial state
  void reset();

  @override
  Future<void> close() {
    // Remove field from form
    formCubit?.removeField(state.name);
    return super.close();
  }
} 