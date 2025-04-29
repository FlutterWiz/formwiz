import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form/form_state.dart';

/// A responsive form widget that uses FormCubit for state management
class FormWiz extends StatelessWidget {
  /// The form cubit to use
  final FormCubit? cubit;
  
  /// Child widgets to display within the form
  final List<Widget> children;
  
  /// Padding around the form
  final EdgeInsetsGeometry padding;
  
  /// Whether to automatically validate the form when values change
  final bool autoValidate;
  
  /// Callback to execute on form submission
  final void Function(Map<String, dynamic> values)? onSubmit;
  
  /// Callback to execute on validation failure
  final void Function(Map<String, String?> errors)? onError;
  
  /// Creates a new FormWiz instance
  ///
  /// If [cubit] is not provided, a new one will be created
  const FormWiz({
    Key? key,
    this.cubit,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.autoValidate = true,
    this.onSubmit,
    this.onError,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormCubit>(
      create: (context) => cubit ?? FormCubit(validateOnChange: autoValidate),
      child: BlocConsumer<FormCubit, FormCubitState>(
        listener: (context, state) {
          if (state is FormSubmissionSuccess && onSubmit != null) {
            onSubmit!(state.values);
          } else if (state is FormValidationFailure && onError != null) {
            onError!(state.errors);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          );
        },
      ),
    );
  }
} 