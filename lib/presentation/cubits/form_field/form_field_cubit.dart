import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/domain/models/form_field_model.dart';
import 'package:formwiz/domain/models/validation_model.dart';
import 'package:formwiz/presentation/cubits/form_field/form_field_state.dart';

/// Form field Cubit that manages the state of a single form field
///
/// Follows MVVM architecture as the ViewModel layer for form fields
class FormFieldCubit<T> extends Cubit<FormFieldCubitState<T>> {
  /// Unique identifier for the field
  final String name;

  /// Validators for the field
  final List<FormWizValidator<T>> validators;

  /// Initial value for the field
  final T? initialValue;

  /// Whether to validate on blur
  final bool validateOnBlur;

  /// Whether to validate immediately on value change
  final bool validateOnChange;

  /// Optional decoration for the field
  final InputDecoration? decoration;

  /// Optional debounce duration for validation
  final Duration? validationDebounce;

  /// Cancellable timer for debounced validation
  Timer? _debounceTimer;

  FormFieldCubit({
    required this.name,
    this.initialValue,
    this.validators = const [],
    this.validateOnBlur = true,
    this.validateOnChange = false,
    this.decoration,
    this.validationDebounce,
  }) : super(
         FormFieldInitial<T>(
           FormFieldModel<T>(
             name: name,
             initialValue: initialValue,
             value: initialValue,
             validators: validators,
             decoration: decoration,
           ),
         ),
       );

  @override
  Future<void> close() {
    _cancelDebounce();
    return super.close();
  }

  /// Initialize the field with a value
  void initialize(T? value) {
    emit(
      FormFieldValid<T>(
        state.model.copyWith(value: value, initialValue: value, errorMessage: null, touched: false, wasFocused: false),
      ),
    );
  }

  /// Update the field value
  void updateValue(T? value, {bool validateImmediately = false}) {
    // Don't trigger validation if the value hasn't changed
    if (state.model.value == value && !validateImmediately) {
      return;
    }

    emit(
      FormFieldValid<T>(
        state.model.copyWith(
          value: value,
          touched: true,
          // Clear error message on typing if there was an error
          errorMessage: state.model.errorMessage != null ? null : state.model.errorMessage,
        ),
      ),
    );

    // Cancel any pending validation
    _cancelDebounce();

    // Validate immediately if requested or configured
    if (validateImmediately || validateOnChange) {
      validate(value, markAsTouched: false);
    } else if (validationDebounce != null) {
      // Otherwise debounce validation if a debounce duration is set
      _debounceTimer = Timer(validationDebounce!, () {
        if (!isClosed) {
          validate(value, markAsTouched: false);
        }
      });
    }
  }

  /// Validate the field value
  Future<void> validate(T? value, {bool markAsTouched = true, bool forceValidation = false}) async {
    // Skip validation if already validating or if value hasn't changed since last validation
    // and we're not forcing validation
    if ((state is FormFieldValidating) ||
        (!forceValidation && state.model.value == value && state.model.errorMessage == null)) {
      return;
    }

    final updatedModel = state.model.copyWith(value: value, touched: markAsTouched || state.model.touched);

    if (validators.isEmpty) {
      emit(FormFieldValid<T>(updatedModel.copyWith(errorMessage: null)));
      return;
    }

    try {
      // First run synchronous validators
      for (final validator in validators) {
        final error = validator.validate(value);
        if (error != null) {
          emit(FormFieldInvalid<T>(updatedModel.copyWith(errorMessage: error)));
          return;
        }
      }

      // Then run async validators
      final asyncValidators = validators.where((v) => v.asyncValidate != null).toList();
      if (asyncValidators.isNotEmpty) {
        emit(FormFieldValidating<T>(updatedModel.copyWith(isValidating: true)));

        for (final validator in asyncValidators) {
          final error = await validator.asyncValidate!(value);
          if (error != null) {
            emit(FormFieldInvalid<T>(updatedModel.copyWith(errorMessage: error, isValidating: false)));
            return;
          }
        }
      }

      emit(FormFieldValid<T>(updatedModel.copyWith(errorMessage: null, isValidating: false)));
    } catch (e) {
      // In case of any exception during validation, mark as invalid
      emit(FormFieldInvalid<T>(updatedModel.copyWith(errorMessage: e.toString(), isValidating: false)));
    }
  }

  /// Reset the field to its initial state
  void reset() {
    emit(FormFieldValid<T>(state.model.reset()));
  }

  /// Mark the field as focused
  void focus() {
    emit(FormFieldValid<T>(state.model.focus()));
  }

  /// Mark the field as blurred and validate if needed
  void blur({bool validateOnBlur = true}) {
    if (this.validateOnBlur && validateOnBlur) {
      validate(state.model.value);
    }
  }

  /// Manually set an error message
  void setError(String errorMessage) {
    emit(FormFieldInvalid<T>(state.model.copyWith(errorMessage: errorMessage, touched: true)));
  }

  /// Update validators for this field
  void updateValidators(List<FormWizValidator<T>> validators) {
    // Only update if validators changed
    if (validators != this.validators) {
      emit(
        FormFieldValid<T>(
          state.model.copyWith(
            validators: validators,
            // Clear error message to trigger revalidation if needed
            errorMessage: null,
          ),
        ),
      );
      
      // Validate with new validators if validation on change is enabled
      if (validateOnChange) {
        validate(state.model.value, forceValidation: true);
      }
    }
  }

  /// Cancel any debounce timer
  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
