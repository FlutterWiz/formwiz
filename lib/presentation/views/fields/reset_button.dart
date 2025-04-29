import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart';

/// A button that resets a FormWiz form
class FormWizResetButton extends StatelessWidget {
  /// Label for the button
  final String label;
  
  /// Style for the button
  final ButtonStyle? style;
  
  /// Callback to execute after form reset
  final VoidCallback? onReset;
  
  /// Creates a new FormWizResetButton
  const FormWizResetButton({
    Key? key,
    this.label = 'Reset',
    this.style,
    this.onReset,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<FormCubit>();
    
    return TextButton(
      style: style,
      onPressed: () {
        formCubit.reset();
        if (onReset != null) {
          onReset!();
        }
      },
      child: Text(label),
    );
  }
} 