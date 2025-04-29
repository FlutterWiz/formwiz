import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form/form_state.dart';

/// Form service utility to manage forms
/// This service helps with form operations like initialization, validation, and submission
class FormService {
  /// Initialize a form cubit with initial values
  static void initializeForm(
    BuildContext context, {
    Map<String, dynamic> initialValues = const {},
  }) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    formCubit.initialize(initialValues: initialValues);
  }

  /// Validate a form and return whether it's valid
  static Future<bool> validateForm(BuildContext context, {bool forceValidation = false}) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.validate(forceValidation: forceValidation);
  }

  /// Submit a form with success and failure callbacks
  static Future<bool> submitForm(
    BuildContext context, {
    void Function(Map<String, dynamic> values)? onSuccess,
    void Function(Map<String, String?> errors)? onFailure,
  }) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.submit(
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }

  /// Reset a form to its initial state
  static void resetForm(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    formCubit.reset();
  }

  /// Update form values for multiple fields at once
  static void updateFormValues(
    BuildContext context,
    Map<String, dynamic> values, {
    bool validateFields = true,
  }) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    formCubit.patchValue(values, validateFields: validateFields);
  }

  /// Get current form values
  static Map<String, dynamic> getFormValues(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.state.values;
  }

  /// Get current form validation errors
  static Map<String, String?> getFormErrors(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    if (formCubit.state is FormValidationFailure) {
      return (formCubit.state as FormValidationFailure).errors;
    }
    return {};
  }

  /// Check if form is valid
  static bool isFormValid(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.state.isValid;
  }

  /// Check if form is submitting
  static bool isFormSubmitting(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.state.isSubmitting;
  }

  /// Check if form has been submitted
  static bool hasFormBeenSubmitted(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.state.hasBeenSubmitted;
  }

  /// Check if form is dirty (values have changed)
  static bool isFormDirty(BuildContext context) {
    final formCubit = BlocProvider.of<FormCubit>(context);
    return formCubit.state.isDirty;
  }
} 