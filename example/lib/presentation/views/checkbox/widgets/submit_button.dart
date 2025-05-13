import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';

/// A submit button for the example forms
class SubmitButton extends StatelessWidget {
  /// Creates a new submit button
  const SubmitButton({super.key, this.text = 'Submit Form'});

  /// Button text
  final String text;

  @override
  Widget build(BuildContext context) {
    return FormWizSubmitButton(
      text: text,
      width: double.infinity,
    );
  }
}
