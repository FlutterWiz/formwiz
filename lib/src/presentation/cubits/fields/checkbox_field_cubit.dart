// ignore_for_file: avoid_redundant_argument_values

import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/fields/base_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Manages the state of a checkbox field
class CheckboxFieldCubit extends BaseFieldCubit<bool, CheckboxFieldState> {
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

  /// Update field value
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

  /// Toggle the checkbox value
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
    final initialState = CheckboxFieldState.initial(name: state.name, initialValue: false);

    emit(initialState);

    // Reset validation status
    final error = validateValue(initialState.value);
    final fieldValue = initialState.toFieldValue().copyWith(error: error);

    formCubit?.updateField(fieldValue);
  }
}
