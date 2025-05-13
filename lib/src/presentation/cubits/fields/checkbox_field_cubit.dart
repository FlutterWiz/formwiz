// ignore_for_file: avoid_redundant_argument_values

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/fields/base_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Manages the state of a single checkbox field
///
/// Handles value updates, validation, and form integration for boolean checkbox fields.
class CheckboxFieldCubit extends BaseFieldCubit<bool, CheckboxFieldState> {
  /// Creates a new checkbox field cubit
  ///
  /// [name] is the field's identifier in the form
  /// [initialValue] is the starting checkbox state (checked/unchecked)
  /// [validators] are functions that validate the checkbox state
  /// [formCubit] is the parent form this field belongs to, if any
  CheckboxFieldCubit({
    required String name,
    bool initialValue = false,
    List<FieldValidator<bool>> validators = const [],
    FormCubit? formCubit,
  }) : super(
    initialState: CheckboxFieldState.initial(name: name, initialValue: initialValue),
    validators: validators,
    formCubit: formCubit,
  );

  /// Updates the checkbox value and validates it
  ///
  /// When the checkbox value changes, this:
  /// - Sets the field as dirty and touched
  /// - Validates the new value
  /// - Updates the form
  void setValue(bool value) {
    final error = validateValue(value);
    
    final newState = state.copyWith(
      value: value,
      isDirty: true,
      touched: true,
      error: error,
      clearError: error == null,
    );
    
    updateState(newState);
  }

  /// Toggles the checkbox between checked and unchecked states
  ///
  /// Convenience method that calls [setValue] with the opposite of current value.
  void toggle() {
    setValue(!state.value);
  }

  @override
  void updateStateWithTouch(String? error) {
    final newState = state.copyWith(touched: true, error: error);
    updateState(newState);
  }

  @override
  void updateStateWithValidation(String? error) {
    final newState = state.copyWith(error: error, clearError: error == null);
    updateState(newState);
  }

  @override
  void reset() {
    // Reset to unchecked state
    final initialState = CheckboxFieldState.initial(name: state.name, initialValue: false);
    emit(initialState);
    
    // Ensure form validation is updated
    final error = validateValue(initialState.value);
    final fieldValue = initialState.toFieldValue().copyWith(error: error);
    formCubit?.updateField(fieldValue);
  }
}
