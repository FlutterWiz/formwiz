import 'package:flutter/material.dart';
import 'package:formwiz_example/presentation/views/checkbox/sections/basic_checkbox_section.dart';
import 'package:formwiz_example/presentation/views/checkbox/sections/checkbox_group_section.dart';
import 'package:formwiz_example/presentation/views/checkbox/sections/validation_section.dart';
import 'package:formwiz_example/presentation/views/checkbox/sections/custom_checkbox_section.dart';

/// Body for the checkbox examples view
class CheckboxViewBody extends StatelessWidget {
  /// Creates a new checkbox view body
  const CheckboxViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Checkbox Field Examples',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          
          // Basic checkbox examples
          BasicCheckboxSection(),
          SizedBox(height: 32),
          
          // Checkbox group examples
          CheckboxGroupSection(),
          SizedBox(height: 32),
          
          // Validation examples
          ValidationSection(),
          SizedBox(height: 32),
          
          // Custom styling examples
          CustomCheckboxSection(),
        ],
      ),
    );
  }
}
