import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/form_field_model.dart';
import '../models/validation_model.dart';

// Form field events
abstract class FormFieldEvent extends Equatable {
  const FormFieldEvent();

  @override
  List<Object?> get props => [];
}

class FormFieldInitialized<T> extends FormFieldEvent {
  final T? initialValue;

  const FormFieldInitialized(this.initialValue);

  @override
  List<Object?> get props => [initialValue];
}

class FormFieldValueChanged<T> extends FormFieldEvent {
  final T? value;

  const FormFieldValueChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class FormFieldValidationRequested<T> extends FormFieldEvent {
  final T? value;
  final bool markAsTouched;

  const FormFieldValidationRequested(this.value, {this.markAsTouched = true});

  @override
  List<Object?> get props => [value, markAsTouched];
}

class FormFieldReset extends FormFieldEvent {}

class FormFieldFocused extends FormFieldEvent {}

class FormFieldBlurred extends FormFieldEvent {}

class FormFieldInvalidated extends FormFieldEvent {
  final String errorMessage;

  const FormFieldInvalidated(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// Form field states
abstract class FormFieldState<T> extends Equatable {
  final FormFieldModel<T> model;

  const FormFieldState(this.model);

  @override
  List<Object?> get props => [model];
}

class FormFieldInitial<T> extends FormFieldState<T> {
  FormFieldInitial({required String name, T? initialValue, List<FormWizValidator<T>> validators = const []})
      : super(FormFieldModel<T>(
          name: name,
          initialValue: initialValue,
          value: initialValue,
          validators: validators,
        ));
}

class FormFieldValid<T> extends FormFieldState<T> {
  const FormFieldValid(FormFieldModel<T> model) : super(model);
}

class FormFieldInvalid<T> extends FormFieldState<T> {
  const FormFieldInvalid(FormFieldModel<T> model) : super(model);
}

class FormFieldValidating<T> extends FormFieldState<T> {
  const FormFieldValidating(FormFieldModel<T> model) : super(model);
}

// Form field BLoC
class FormFieldBloc<T> extends Bloc<FormFieldEvent, FormFieldState<T>> {
  final String name;
  final List<FormWizValidator<T>> validators;
  final T? initialValue;

  FormFieldBloc({
    required this.name,
    this.initialValue,
    this.validators = const [],
  }) : super(FormFieldInitial<T>(
          name: name,
          initialValue: initialValue,
          validators: validators,
        )) {
    on<FormFieldInitialized<T>>(_onInitialized);
    on<FormFieldValueChanged<T>>(_onValueChanged);
    on<FormFieldValidationRequested<T>>(_onValidationRequested);
    on<FormFieldReset>(_onReset);
    on<FormFieldFocused>(_onFocused);
    on<FormFieldBlurred>(_onBlurred);
    on<FormFieldInvalidated>(_onInvalidated);
  }

  void _onInitialized(FormFieldInitialized<T> event, Emitter<FormFieldState<T>> emit) {
    emit(FormFieldValid<T>(state.model.copyWith(
      value: event.initialValue,
      initialValue: event.initialValue,
    )));
  }

  void _onValueChanged(FormFieldValueChanged<T> event, Emitter<FormFieldState<T>> emit) {
    // Don't trigger validation if the value hasn't changed
    if (state.model.value == event.value) {
      return;
    }
    
    emit(FormFieldValid<T>(state.model.copyWith(
      value: event.value,
      touched: true,
    )));
    
    // Add validation request with a delay
    Future.microtask(() {
      add(FormFieldValidationRequested<T>(event.value, markAsTouched: false));
    });
  }

  Future<void> _onValidationRequested(
    FormFieldValidationRequested<T> event,
    Emitter<FormFieldState<T>> emit,
  ) async {
    // Skip validation if already validating or if value hasn't changed since last validation
    if (state is FormFieldValidating || 
        (state.model.value == event.value && state.model.errorMessage == null)) {
      return;
    }
    
    if (validators.isEmpty) {
      emit(FormFieldValid<T>(state.model.copyWith(
        value: event.value,
        touched: event.markAsTouched || state.model.touched,
        errorMessage: null,
      )));
      return;
    }

    // First run synchronous validators
    for (final validator in validators) {
      final error = validator.validate(event.value);
      if (error != null) {
        emit(FormFieldInvalid<T>(state.model.copyWith(
          value: event.value,
          touched: event.markAsTouched || state.model.touched,
          errorMessage: error,
        )));
        return;
      }
    }

    // Then run async validators
    final asyncValidators = validators.where((v) => v.asyncValidate != null).toList();
    if (asyncValidators.isNotEmpty) {
      emit(FormFieldValidating<T>(state.model.copyWith(
        value: event.value,
        touched: event.markAsTouched || state.model.touched,
        isValidating: true,
      )));

      for (final validator in asyncValidators) {
        final error = await validator.asyncValidate!(event.value);
        if (error != null) {
          emit(FormFieldInvalid<T>(state.model.copyWith(
            value: event.value,
            touched: event.markAsTouched || state.model.touched,
            errorMessage: error,
            isValidating: false,
          )));
          return;
        }
      }
    }

    // All validations passed
    emit(FormFieldValid<T>(state.model.copyWith(
      value: event.value,
      touched: event.markAsTouched || state.model.touched,
      errorMessage: null,
      isValidating: false,
    )));
  }

  void _onReset(FormFieldReset event, Emitter<FormFieldState<T>> emit) {
    emit(FormFieldValid<T>(state.model.copyWith(
      value: state.model.initialValue,
      touched: false,
      errorMessage: null,
      isValidating: false,
    )));
  }

  void _onFocused(FormFieldFocused event, Emitter<FormFieldState<T>> emit) {
    // No state change needed, but could be used for analytics or other side effects
  }

  void _onBlurred(FormFieldBlurred event, Emitter<FormFieldState<T>> emit) {
    if (!state.model.touched) {
      add(FormFieldValidationRequested<T>(state.model.value));
    }
  }

  void _onInvalidated(FormFieldInvalidated event, Emitter<FormFieldState<T>> emit) {
    emit(FormFieldInvalid<T>(state.model.copyWith(
      errorMessage: event.errorMessage,
      touched: true,
    )));
  }
} 