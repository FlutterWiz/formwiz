import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/section_container.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/example_form.dart';

/// Basic checkbox examples section
class BasicCheckboxSection extends StatelessWidget {
  /// Creates a basic checkbox examples section
  const BasicCheckboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionContainer(
      title: 'Basic Checkboxes',
      description: 'Simple checkbox field examples showing the basic usage',
      child: ExampleForm(
        description: 'These checkboxes demonstrate the basic functionality:',
        children: [
          // Default checkbox (unchecked)
          FormWizCheckboxField(
            name: 'basic_checkbox',
            labelText: 'Basic checkbox',
          ),
          
          // Checkbox with initial value set to true
          FormWizCheckboxField(
            name: 'checked_by_default', 
            labelText: 'Checked by default',
            initialValue: true,
          ),
          
          // Disabled checkbox (can't be changed)
          FormWizCheckboxField(
            name: 'disabled_checkbox',
            labelText: 'Disabled checkbox (can\'t be changed)',
            disabled: true,
          ),
          
          // Disabled and checked checkbox
          FormWizCheckboxField(
            name: 'disabled_checked',
            labelText: 'Disabled and checked checkbox',
            initialValue: true,
            disabled: true,
          ),
        ],
      ),
    );
  }
} 