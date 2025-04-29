import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart';
import 'package:formwiz/presentation/cubits/form/form_state.dart';


/// A button that submits a FormWiz form
class FormWizSubmitButton extends StatelessWidget {
  /// Label for the button
  final String label;
  
  /// Style for the button
  final ButtonStyle? style;
  
  /// Callback to execute on successful submission
  final void Function(Map<String, dynamic> values)? onSuccess;
  
  /// Callback to execute on validation failure
  final void Function(Map<String, String?> errors)? onFailure;
  
  /// Widget to display when the form is submitting
  final Widget? loadingWidget;
  
  /// Creates a new FormWizSubmitButton
  const FormWizSubmitButton({
    Key? key,
    this.label = 'Submit',
    this.style,
    this.onSuccess,
    this.onFailure,
    this.loadingWidget,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormCubit, FormCubitState>(
      builder: (context, state) {
        final formCubit = context.read<FormCubit>();
        
        if (state.isSubmitting) {
          return loadingWidget ?? 
            const Center(
              child: CircularProgressIndicator(),
            );
        }
        
        return ElevatedButton(
          style: style,
          onPressed: state.isValid || state is FormInitial
            ? () => formCubit.submit(onSuccess: onSuccess, onFailure: onFailure)
            : null,
          child: Text(label),
        );
      },
    );
  }
} 