
import 'package:formwiz/src/core/field/field_state.dart';
import 'package:formwiz/src/core/validators/field_validator.dart';
import 'package:formwiz/src/presentation/cubits/fields/base_field_cubit.dart';
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Manages the state of a checkbox group field
class CheckboxGroupFieldCubit extends BaseFieldCubit<List<String>, CheckboxGroupFieldState> {
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

  /// Check if an option is selected
  bool isSelected(String option) => state.value.contains(option);

  @override
  void updateStateWithTouch(String? error) {
    final newState = state.copyWith(
      touched: true,
      error: error,
    );
    
    updateState(newState);
  }

  @override
  void updateStateWithValidation(String? error) {
    final newState = state.copyWith(
      error: error,
      clearError: error == null,
    );
    
    updateState(newState);
  }

  @override
  void reset() {
    final initialState = CheckboxGroupFieldState.initial(
      name: state.name,
      options: state.options,
      initialValues: [],
    );
    
    emit(initialState);
    
    // Reset validation status
    final error = validateValue(initialState.value);
    final fieldValue = initialState.toFieldValue().copyWith(
      error: error,
    );
    
    formCubit?.updateField(fieldValue);
  }
} 