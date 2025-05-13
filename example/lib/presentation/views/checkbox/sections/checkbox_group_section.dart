import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/section_container.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/example_form.dart';

/// Checkbox group examples section
class CheckboxGroupSection extends StatelessWidget {
  /// Creates a checkbox group examples section
  const CheckboxGroupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionContainer(
      title: 'Checkbox Groups',
      description: 'Examples of checkbox group fields for multiple selections',
      child: ExampleForm(
        description: 'Select one or more options:',
        children: [
          // Basic checkbox group
          FormWizCheckboxGroupField(
            name: 'favorite_fruits',
            labelText: 'Select your favorite fruits:',
            options: ['Apple', 'Banana', 'Orange', 'Strawberry', 'Mango'],
            initialValues: ['Apple', 'Mango'],
          ),
          
          SizedBox(height: 24),
          
          // Checkbox group with custom labels
          FormWizCheckboxGroupField(
            name: 'notifications',
            labelText: 'Notification preferences:',
            options: ['email', 'push', 'sms', 'in_app'],
            optionLabels: {
              'email': 'Email notifications',
              'push': 'Push notifications',
              'sms': 'SMS notifications',
              'in_app': 'In-app notifications',
            },
            initialValues: ['email', 'in_app'],
          ),
          
          SizedBox(height: 24),
          
          // Disabled checkbox group
          FormWizCheckboxGroupField(
            name: 'disabled_group',
            labelText: 'Disabled group (can\'t be changed):',
            options: ['Option 1', 'Option 2', 'Option 3'],
            initialValues: ['Option 2'],
            disabled: true,
          ),
        ],
      ),
    );
  }
} 