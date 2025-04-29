import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart';

/// Base state for form
@immutable
abstract class FormCubitState extends Equatable {
  final Map<String, FormFieldCubit> fields;
  final Map<String, dynamic> values;
  final bool isValid;
  final bool isSubmitting;
  final bool isValidating;
  final bool hasBeenSubmitted;
  final bool isDirty;

  const FormCubitState({
    required this.fields,
    required this.values,
    required this.isValid,
    required this.isSubmitting,
    required this.isValidating,
    required this.hasBeenSubmitted,
    required this.isDirty,
  });

  @override
  List<Object?> get props => [
    values, 
    isValid, 
    isSubmitting, 
    isValidating, 
    hasBeenSubmitted,
    isDirty,
  ];
  
  @override
  bool get stringify => true;
}

/// Initial state of a form
class FormInitial extends FormCubitState {
  FormInitial()
    : super(
        fields: const {},
        values: const {},
        isValid: false,
        isSubmitting: false,
        isValidating: false,
        hasBeenSubmitted: false,
        isDirty: false,
      );
}

/// State when form validation succeeds
class FormValidationSuccess extends FormCubitState {
  const FormValidationSuccess({
    required super.fields,
    required super.values,
    super.isSubmitting = false,
    super.isValidating = false,
    super.hasBeenSubmitted = false,
    super.isDirty = false,
  }) : super(isValid: true);
}

/// State when form validation fails
class FormValidationFailure extends FormCubitState {
  final Map<String, String?> errors;

  const FormValidationFailure({
    required super.fields,
    required super.values,
    required this.errors,
    super.isSubmitting = false,
    super.isValidating = false,
    super.hasBeenSubmitted = false,
    super.isDirty = false,
  }) : super(isValid: false);

  @override
  List<Object?> get props => [...super.props, errors];
}

/// State when form is submitting
class FormSubmitting extends FormCubitState {
  const FormSubmitting({
    required super.fields,
    required super.values,
    required super.isValid,
    super.isValidating = false,
    super.hasBeenSubmitted = false,
    super.isDirty = false,
  }) : super(isSubmitting: true);
}

/// State when form submission succeeds
class FormSubmissionSuccess extends FormCubitState {
  const FormSubmissionSuccess({
    required super.fields,
    required super.values,
    required super.isValid,
    super.isSubmitting = false,
    super.isValidating = false,
    super.isDirty = false,
  }) : super(hasBeenSubmitted: true);
}

/// State when form submission fails
class FormSubmissionFailure extends FormCubitState {
  final String errorMessage;

  const FormSubmissionFailure({
    required super.fields,
    required super.values,
    required super.isValid,
    required this.errorMessage,
    super.isSubmitting = false,
    super.isValidating = false,
    super.hasBeenSubmitted = true,
    super.isDirty = false,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
} 