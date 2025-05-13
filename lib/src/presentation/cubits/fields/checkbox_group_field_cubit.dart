import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Manages the state of a checkbox group field
class CheckboxGroupFieldCubit extends Cubit<CheckboxGroupFieldState> {
  final List<FieldValidator<List<String>>> validators;
  final FormCubit? formCubit;

  CheckboxGroupFieldCubit({
    required String name,
    required List<String> options,
    List<String>? initialValues,
    this.validators = const [],
    this.formCubit,
  }) : super(CheckboxGroupFieldState.initial(
    name: name,
    options: options,
    initialValues: initialValues,
  ),) {
    // Register field with form
    _registerWithForm();
  }

  /// Register this field with the parent form
  void _registerWithForm() {
    formCubit?.registerField(state.toFieldValue());
  }

  /// Toggle a single option in the group
  void toggleOption(String option) {
    final currentValues = List<String>.from(state.value);
    
    if (currentValues.contains(option)) {
      currentValues.remove(option);
    } else {
      currentValues.add(option);
    }
    
    _setValue(currentValues);
  }

  /// Set the value directly
  void setValue(List<String> values) {
    _setValue(values);
  }

  /// Internal method to update state and notify form
  void _setValue(List<String> values) {
    final newState = state.copyWith(
      value: values,
      isDirty: true,
      touched: true,
      error: state.validate(validators),
      clearError: validators.isEmpty,
    );
    
    emit(newState);
    formCubit?.updateField(newState.toFieldValue());
  }

  /// Check if an option is selected
  bool isSelected(String option) => state.value.contains(option);

  /// Mark field as touched
  void touch() {
    if (state.touched) return;
    
    final newState = state.copyWith(
      touched: true,
      error: state.validate(validators),
    );
    
    emit(newState);
    formCubit?.updateField(newState.toFieldValue());
  }

  /// Validate the field
  void validate() {
    final error = state.validate(validators);
    
    if (error != state.error) {
      final newState = state.copyWith(error: error, clearError: error == null);
      emit(newState);
      formCubit?.updateField(newState.toFieldValue());
    }
  }

  /// Reset field to initial value
  void reset() {
    emit(CheckboxGroupFieldState.initial(
      name: state.name,
      options: state.options,
    ),);
    
    _registerWithForm();
  }

  @override
  Future<void> close() {
    // Remove field from form
    formCubit?.removeField(state.name);
    return super.close();
  }
} 