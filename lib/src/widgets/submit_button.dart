import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/core/form/form.dart' as form_wiz;
import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// A button that submits a FormWiz form
class FormWizSubmitButton extends StatelessWidget {
  /// Text to display on the button
  final String text;
  
  /// Button style
  final ButtonStyle? style;
  
  /// Widget to show when form is submitting
  final Widget? loadingIndicator;
  
  /// Width of the button, if specified
  final double? width;
  
  /// Custom builder for advanced styling
  final Widget Function(
    BuildContext context,
    form_wiz.FormState state,
    VoidCallback? onPressed,
  )? builder;

  /// Creates a submit button for FormWiz forms
  const FormWizSubmitButton({
    super.key,
    this.text = 'Submit',
    this.style,
    this.loadingIndicator,
    this.width,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormCubit, form_wiz.FormState>(
      builder: (context, state) {
        final formCubit = context.read<FormCubit>();
        final isValid = state.isValid;
        final isSubmitting = state.status.isSubmitting;
        
        final onPressed = isValid && !isSubmitting
          ? () => formCubit.submit()
          : null;
        
        // Use custom builder if provided
        if (builder != null) {
          return builder!(context, state, onPressed);
        }
        
        // Default button implementation
        return SizedBox(
          width: width ?? double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: isSubmitting
              ? loadingIndicator ?? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(text),
          ),
        );
      },
    );
  }
} 