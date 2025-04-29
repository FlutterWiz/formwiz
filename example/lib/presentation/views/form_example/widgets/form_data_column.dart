import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formwiz/presentation/cubits/form/form_cubit.dart' as formwiz;
import 'package:formwiz/presentation/cubits/form/form_state.dart' as formwiz;
import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart' as formwiz;

class FormDataColumn extends StatelessWidget {
  final bool notificationsEnabled;
  final bool termsAccepted;
  final formwiz.FormFieldCubit<String> nameCubit;
  final formwiz.FormFieldCubit<String> emailCubit;

  const FormDataColumn({
    super.key,
    required this.notificationsEnabled,
    required this.termsAccepted,
    required this.nameCubit,
    required this.emailCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<formwiz.FormCubit, formwiz.FormCubitState>(
      builder: (context, state) {
        // Include the local state values
        final displayValues = Map<String, dynamic>.from(state.values);
        displayValues['notifications'] = notificationsEnabled;
        displayValues['terms'] = termsAccepted;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Form Data:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${displayValues['name'] ?? ''}'),
                  Text('Email: ${displayValues['email'] ?? ''}'),
                  Text('Notifications Enabled: $notificationsEnabled'),
                  Text('Terms Accepted: $termsAccepted'),
                  const SizedBox(height: 8),
                  Text('Valid: ${state.isValid}'),
                  Text('Dirty: ${state.isDirty}'),
                  Text('Submitted: ${state.hasBeenSubmitted}'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
