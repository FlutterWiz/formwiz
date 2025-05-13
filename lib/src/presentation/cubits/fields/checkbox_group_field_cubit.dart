// ignore_for_file: avoid_redundant_argument_values

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/fields/base_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Manages the state of a checkbox group field
///
/// Handles multiple selection, validation, and form integration for a group of related checkboxes.
class CheckboxGroupFieldCubit extends BaseFieldCubit<List<String>, CheckboxGroupFieldState> {
  /// Creates a new checkbox group field cubit
  ///
  /// [name] is the field's identifier in the form
  /// [options] are the available checkbox options
  /// [initialValues] are the initially selected options (if any)
  /// [validators] are functions that validate the selection
  /// [formCubit] is the parent form this field belongs to, if any
  CheckboxGroupFieldCubit({
    required String name,
    required List<String> options,
    List<String>? initialValues,
    List<FieldValidator<List<String>>> validators = const [],
    FormCubit? formCubit,
  }) : super(
    initialState: CheckboxGroupFieldState.initial(
      name: name,
      options: options,
      initialValues: initialValues,
    ),
    validators: validators,
    formCubit: formCubit,
  );

  /// Toggles a single option in the group
  ///
  /// If the option is already selected, it will be deselected.
  /// If not selected, it will be added to the selection.
  void toggleOption(String option) {
    final currentValues = List<String>.from(state.value);
    
    if (currentValues.contains(option)) {
      currentValues.remove(option);
    } else {
      currentValues.add(option);
    }
    
    _setValue(currentValues);
  }

  /// Sets the selection to the provided values
  ///
  /// Replaces the current selection with the provided list of values.
  void setValue(List<String> values) {
    _setValue(values);
  }

  /// Internal method to update state and notify form
  ///
  /// Handles validation and updates the form with the new selection.
  void _setValue(List<String> values) {
    final error = validateValue(values);
    
    final newState = state.copyWith(
      value: values,
      isDirty: true,
      touched: true,
      error: error,
      clearError: error == null,
    );
    
    updateState(newState);
  }

  /// Checks if a specific option is currently selected
  bool isSelected(String option) => state.value.contains(option);

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
    // Reset to empty selection
    final initialState = CheckboxGroupFieldState.initial(
      name: state.name,
      options: state.options,
      initialValues: [],
    );
    
    emit(initialState);
    
    // Ensure form validation is updated
    final error = validateValue(initialState.value);
    final fieldValue = initialState.toFieldValue().copyWith(error: error);
    formCubit?.updateField(fieldValue);
  }
} 