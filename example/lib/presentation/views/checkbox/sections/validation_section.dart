import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/section_container.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/example_form.dart';

/// Validation examples section
class ValidationSection extends StatelessWidget {
  /// Creates a validation examples section
  const ValidationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Validation Examples',
      description: 'Checkbox fields with validation rules',
      child: ExampleForm(
        description: 'Try submitting the form without accepting the required checkbox:',
        submitButtonText: 'Submit with validation',
        showValidationMessage: true,
        children: [
          // Required checkbox validation
          FormWizCheckboxField(
            name: 'terms_required',
            labelText: 'I accept the terms and conditions (required)',
            validators: [FormWizValidator.required('You must accept the terms and conditions')],
          ),
          
          const SizedBox(height: 16),
          
          // Required checkbox group validation
          FormWizCheckboxGroupField(
            name: 'hobbies_required',
            labelText: 'Select at least one hobby (required):',
            options: const ['Reading', 'Sports', 'Music', 'Cooking', 'Travel'],
            validators: [
              FormWizValidator.required('Please select at least one hobby'),
            ],
          ),
        ],
      ),
    );
  }
} 