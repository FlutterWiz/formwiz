import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'form_field_bloc.dart';

// Form events
abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object?> get props => [];
}

class FormInitialized extends FormEvent {
  final Map<String, dynamic> initialValues;

  const FormInitialized({this.initialValues = const {}});

  @override
  List<Object?> get props => [initialValues];
}

class FormFieldAdded extends FormEvent {
  final FormFieldBloc fieldBloc;

  const FormFieldAdded(this.fieldBloc);

  @override
  List<Object?> get props => [fieldBloc];
}

class FormFieldRemoved extends FormEvent {
  final String fieldName;

  const FormFieldRemoved(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class FormSubmitted extends FormEvent {}

class FormReset extends FormEvent {}

class FormValidationRequested extends FormEvent {}

class FormValuePatched extends FormEvent {
  final Map<String, dynamic> values;

  const FormValuePatched(this.values);

  @override
  List<Object?> get props => [values];
}

// Form states
abstract class FormState extends Equatable {
  final Map<String, FormFieldBloc> fields;
  final Map<String, dynamic> values;
  final bool isValid;
  final bool isSubmitting;
  final bool isValidating;
  final bool hasBeenSubmitted;

  const FormState({
    required this.fields,
    required this.values,
    required this.isValid,
    required this.isSubmitting,
    required this.isValidating,
    required this.hasBeenSubmitted,
  });

  @override
  List<Object?> get props => [values, isValid, isSubmitting, isValidating, hasBeenSubmitted];
}

class FormInitial extends FormState {
  FormInitial()
    : super(
        fields: const {},
        values: const {},
        isValid: false,
        isSubmitting: false,
        isValidating: false,
        hasBeenSubmitted: false,
      );
}

class FormValidationSuccess extends FormState {
  const FormValidationSuccess({
    required super.fields,
    required super.values,
    super.isSubmitting = false,
    super.isValidating = false,
    super.hasBeenSubmitted = false,
  }) : super(isValid: true);
}

class FormValidationFailure extends FormState {
  final Map<String, String?> errors;

  const FormValidationFailure({
    required super.fields,
    required super.values,
    required this.errors,
    super.isSubmitting = false,
    super.isValidating = false,
    super.hasBeenSubmitted = false,
  }) : super(isValid: false);

  @override
  List<Object?> get props => [values, isValid, isSubmitting, isValidating, hasBeenSubmitted, errors];
}

class FormSubmitting extends FormState {
  const FormSubmitting({
    required super.fields,
    required super.values,
    required super.isValid,
    super.isValidating = false,
    super.hasBeenSubmitted = false,
  }) : super(isSubmitting: true);
}

class FormSubmissionSuccess extends FormState {
  const FormSubmissionSuccess({
    required super.fields,
    required super.values,
    required super.isValid,
    super.isSubmitting = false,
    super.isValidating = false,
  }) : super(hasBeenSubmitted: true);
}

class FormSubmissionFailure extends FormState {
  final String errorMessage;

  const FormSubmissionFailure({
    required super.fields,
    required super.values,
    required super.isValid,
    required this.errorMessage,
    super.isSubmitting = false,
    super.isValidating = false,
    super.hasBeenSubmitted = true,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

// Form BLoC
class FormBloc extends Bloc<FormEvent, FormState> {
  final Map<String, StreamSubscription> _fieldSubscriptions = {};

  FormBloc() : super(FormInitial()) {
    on<FormInitialized>(_onInitialized);
    on<FormFieldAdded>(_onFieldAdded);
    on<FormFieldRemoved>(_onFieldRemoved);
    on<FormSubmitted>(_onSubmitted);
    on<FormReset>(_onReset);
    on<FormValidationRequested>(_onValidationRequested);
    on<FormValuePatched>(_onValuePatched);
  }

  @override
  Future<void> close() {
    for (final subscription in _fieldSubscriptions.values) {
      subscription.cancel();
    }
    _fieldSubscriptions.clear();
    return super.close();
  }

  void _onInitialized(FormInitialized event, Emitter<FormState> emit) {
    // Initialize fields with values if provided
    if (event.initialValues.isNotEmpty) {
      for (final entry in event.initialValues.entries) {
        final fieldBloc = state.fields[entry.key];
        if (fieldBloc != null) {
          fieldBloc.add(FormFieldInitialized(entry.value));
        }
      }
    }

    _emitUpdatedState(emit);
  }

  void _onFieldAdded(FormFieldAdded event, Emitter<FormState> emit) {
    final updatedFields = Map<String, FormFieldBloc>.from(state.fields);
    final fieldName = event.fieldBloc.name;

    // Remove existing subscription if any
    if (_fieldSubscriptions.containsKey(fieldName)) {
      _fieldSubscriptions[fieldName]?.cancel();
      _fieldSubscriptions.remove(fieldName);
    }

    // Add the field
    updatedFields[fieldName] = event.fieldBloc;

    // Subscribe to field changes with debounce
    _fieldSubscriptions[fieldName] = event.fieldBloc.stream
      .distinct() // Only react to distinct states
      .listen((_) {
        // Debounce validation requests
        Future.microtask(() {
          add(FormValidationRequested());
        });
      });

    emit(
      FormValidationSuccess(
        fields: updatedFields,
        values: _collectValues(updatedFields),
        isSubmitting: state.isSubmitting,
        isValidating: state.isValidating,
        hasBeenSubmitted: state.hasBeenSubmitted,
      ),
    );
  }

  void _onFieldRemoved(FormFieldRemoved event, Emitter<FormState> emit) {
    final updatedFields = Map<String, FormFieldBloc>.from(state.fields);

    // Remove subscription
    if (_fieldSubscriptions.containsKey(event.fieldName)) {
      _fieldSubscriptions[event.fieldName]?.cancel();
      _fieldSubscriptions.remove(event.fieldName);
    }

    // Remove the field
    updatedFields.remove(event.fieldName);

    _emitUpdatedState(emit);
  }

  Future<void> _onSubmitted(FormSubmitted event, Emitter<FormState> emit) async {
    // First validate all fields
    await _validateAllFields();

    // Check if form is valid
    if (!_isFormValid()) {
      _emitUpdatedState(emit);
      return;
    }

    // Mark form as submitting
    emit(FormSubmitting(fields: state.fields, values: state.values, isValid: true));

    // In a real app, you might perform some async action here
    // For now, just emit success immediately
    emit(FormSubmissionSuccess(fields: state.fields, values: state.values, isValid: true));
  }

  void _onReset(FormReset event, Emitter<FormState> emit) {
    // Reset all fields
    for (final field in state.fields.values) {
      field.add(FormFieldReset());
    }

    _emitUpdatedState(emit);
  }

  void _onValidationRequested(FormValidationRequested event, Emitter<FormState> emit) {
    _emitUpdatedState(emit);
  }

  void _onValuePatched(FormValuePatched event, Emitter<FormState> emit) {
    // Update field values
    for (final entry in event.values.entries) {
      final fieldBloc = state.fields[entry.key];
      if (fieldBloc != null) {
        fieldBloc.add(FormFieldValueChanged(entry.value));
      }
    }

    _emitUpdatedState(emit);
  }

  Future<void> _validateAllFields() async {
    for (final field in state.fields.values) {
      final currentState = field.state;
      field.add(FormFieldValidationRequested(currentState.model.value));
    }

    // Wait a bit for all fields to validate
    await Future.delayed(const Duration(milliseconds: 10));
  }

  bool _isFormValid() {
    return state.fields.values.every((field) => field.state.model.isValid);
  }

  Map<String, String?> _collectErrors(Map<String, FormFieldBloc> fields) {
    final errors = <String, String?>{};
    for (final entry in fields.entries) {
      final fieldState = entry.value.state;
      if (fieldState.model.errorMessage != null) {
        errors[entry.key] = fieldState.model.errorMessage;
      }
    }
    return errors;
  }

  Map<String, dynamic> _collectValues(Map<String, FormFieldBloc> fields) {
    final values = <String, dynamic>{};
    for (final entry in fields.entries) {
      values[entry.key] = entry.value.state.model.value;
    }
    return values;
  }

  void _emitUpdatedState(Emitter<FormState> emit) {
    final values = _collectValues(state.fields);
    final isValid = _isFormValid();

    if (isValid) {
      emit(
        FormValidationSuccess(
          fields: state.fields,
          values: values,
          isSubmitting: state.isSubmitting,
          isValidating: state.isValidating,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
    } else {
      final errors = _collectErrors(state.fields);
      emit(
        FormValidationFailure(
          fields: state.fields,
          values: values,
          errors: errors,
          isSubmitting: state.isSubmitting,
          isValidating: state.isValidating,
          hasBeenSubmitted: state.hasBeenSubmitted,
        ),
      );
    }
  }
}
