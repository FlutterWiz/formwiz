import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:formwiz/domain/models/form_field_model.dart';

/// Base state for form field
@immutable
abstract class FormFieldCubitState<T> extends Equatable {
  final FormFieldModel<T> model;

  const FormFieldCubitState(this.model);

  @override
  List<Object?> get props => [model];

  @override
  bool get stringify => true;
}

/// Initial state of a form field
class FormFieldInitial<T> extends FormFieldCubitState<T> {
  const FormFieldInitial(FormFieldModel<T> model) : super(model);
}

/// State when a form field is valid
class FormFieldValid<T> extends FormFieldCubitState<T> {
  const FormFieldValid(FormFieldModel<T> model) : super(model);
}

/// State when a form field is invalid
class FormFieldInvalid<T> extends FormFieldCubitState<T> {
  const FormFieldInvalid(FormFieldModel<T> model) : super(model);
}

/// State when a form field is validating
class FormFieldValidating<T> extends FormFieldCubitState<T> {
  const FormFieldValidating(FormFieldModel<T> model) : super(model);
}
