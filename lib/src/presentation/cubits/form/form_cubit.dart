import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/field/field_value.dart';
import 'package:formwiz/src/core/form/form.dart';

/// FormCubit manages the state of a form
class FormCubit extends Cubit<FormState> {
  final void Function(Map<String, dynamic>)? onSubmit;
  
  FormCubit({this.onSubmit}) : super(FormState.initial());

  /// Register a new field with the form
  void registerField(FieldValue fieldValue) {
    emit(state.updateField(fieldValue));
  }

  /// Update a field in the form
  void updateField(FieldValue fieldValue) {
    emit(state.updateField(fieldValue));
  }

  /// Remove a field from the form
  void removeField(String name) {
    emit(state.removeField(name));
  }

  /// Reset the form to its initial state
  void reset() {
    emit(FormState.initial());
  }

  /// Submit the form
  Future<void> submit() async {
    if (!state.isValid) return;
    
    emit(state.copyWith(status: FormSubmissionStatus.submitting));
    
    try {
      onSubmit?.call(state.values);
      emit(state.copyWith(status: FormSubmissionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FormSubmissionStatus.failure,
        error: e.toString(),
      ),);
    }
  }
} 