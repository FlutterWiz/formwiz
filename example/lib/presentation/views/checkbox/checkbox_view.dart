import 'package:flutter/material.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/checkbox_view_body.dart';

/// Example view showcasing FormWiz checkbox fields
class CheckboxView extends StatelessWidget {
  /// Creates a new CheckboxView
  const CheckboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkbox Examples'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const CheckboxViewBody(),
    );
  }
}
