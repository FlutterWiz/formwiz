import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Manages the state of a checkbox field
class CheckboxFieldCubit extends Cubit<CheckboxFieldState> {
  final List<FieldValidator<bool>> validators;
  final FormCubit? formCubit;

  CheckboxFieldCubit({
    required String name,
    bool initialValue = false,
    this.validators = const [],
    this.formCubit,
  }) : super(CheckboxFieldState.initial(
    name: name,
    initialValue: initialValue,
  ),) {
    // Register field with form
    _registerWithForm();
  }

  /// Register this field with the parent form
  void _registerWithForm() {
    formCubit?.registerField(state.toFieldValue());
  }

  /// Update field value
  void setValue(bool value) {
    final newState = state.copyWith(
      value: value,
      isDirty: true,
      touched: true,
      error: state.validate(validators),
      clearError: validators.isEmpty,
    );
    
    emit(newState);
    formCubit?.updateField(newState.toFieldValue());
  }

  /// Toggle the checkbox value
  void toggle() {
    setValue(!state.value);
  }

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
    emit(CheckboxFieldState.initial(
      name: state.name,
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