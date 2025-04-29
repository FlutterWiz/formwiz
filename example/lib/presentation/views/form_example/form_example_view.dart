import 'package:flutter/material.dart';
import 'package:formwiz_example/presentation/views/form_example/widgets/mini_form_column.dart';
import 'package:formwiz_example/presentation/views/form_example/widgets/switch_field_column.dart';

class FormExampleView extends StatelessWidget {
  const FormExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormWiz Example'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [MiniFormColumn(), Divider(), SwitchFieldColumn()],
          ),
        ),
      ),
    );
  }
}
