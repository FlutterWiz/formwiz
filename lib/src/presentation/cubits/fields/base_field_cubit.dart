import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/field/field_value.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Base cubit class for all form field types.
///
/// Handles common operations like validation, form registration, and state management.
/// All field cubits should extend this class to ensure consistent behavior.
abstract class BaseFieldCubit<T, S extends FieldState<T>> extends Cubit<S> {
  /// Validators to apply to this field's value
  final List<FieldValidator<T>> validators;
  
  /// Reference to the parent form's cubit (if this field is in a form)
  final FormCubit? formCubit;

  /// Creates a new field cubit with the given initial state and validators
  BaseFieldCubit({
    required S initialState,
    required this.validators,
    this.formCubit,
  }) : super(initialState) {
    registerInitialValueWithForm();
  }

  /// Registers the field's initial value with the parent form
  ///
  /// This informs the form about this field and its initial validation state
  /// without displaying errors to the user until they interact with the field.
  void registerInitialValueWithForm() {
    final value = state.value;
    final isValid = _isValueValid(value);
    
    final fieldValue = FieldValue<T>(
      name: state.name,
      value: value,
      // Include validation error for form's internal tracking,
      // but UI won't show it until the field is touched
      error: isValid ? null : _getValidationError(value),
    );
    
    formCubit?.registerField(fieldValue);
  }
  
  /// Checks if a value passes all validators
  bool _isValueValid(T value) {
    if (validators.isEmpty) return true;
    
    for (final validator in validators) {
      if (!validator.isValid(value)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Gets the first validation error message for a value
  ///
  /// Returns null if the value is valid or there are no validators.
  String? _getValidationError(T value) {
    if (validators.isEmpty) return null;
    
    for (final validator in validators) {
      if (!validator.isValid(value)) {
        return validator.errorMessage;
      }
    }
    
    return null;
  }

  /// Validates a value against all validators
  ///
  /// If no value is provided, the current state value is used.
  /// Returns an error message if validation fails, or null if valid.
  String? validateValue([T? valueToValidate]) {
    final value = valueToValidate ?? state.value;
    return _getValidationError(value);
  }
  
  /// Updates the field state and notifies the parent form
  ///
  /// This is the preferred way to update state to ensure the form
  /// is always notified of changes.
  void updateState(S newState) {
    emit(newState);
    formCubit?.updateField(newState.toFieldValue());
  }
  
  /// Marks the field as touched to show validation errors
  ///
  /// This is typically called when the user interacts with the field.
  void touch() {
    if (state.touched) return;
    
    final error = validateValue();
    updateStateWithTouch(error);
  }
  
  /// Updates the state to reflect a touched field with validation
  ///
  /// Implement this in subclasses to handle field-specific state updates.
  void updateStateWithTouch(String? error);
  
  /// Validates the field and updates state if needed
  ///
  /// This can be called to explicitly trigger validation, for example
  /// when a form is submitted.
  void validate() {
    final error = validateValue();
    
    if (error != state.error) {
      updateStateWithValidation(error);
    }
  }
  
  /// Updates state with validation results
  ///
  /// Implement this in subclasses to handle field-specific validation state updates.
  void updateStateWithValidation(String? error);
  
  /// Resets the field to its initial state
  ///
  /// Implement this in subclasses to handle field-specific reset behavior.
  void reset();

  @override
  Future<void> close() {
    // Remove field from form when this cubit is closed
    formCubit?.removeField(state.name);
    return super.close();
  }
} 