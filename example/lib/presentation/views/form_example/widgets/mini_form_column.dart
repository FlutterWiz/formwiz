import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formwiz/domain/models/validation_model.dart' as formwiz;
import 'package:formwiz/presentation/cubits/form/form_cubit.dart' as formwiz;
import 'package:formwiz/presentation/cubits/form/form_state.dart' as formwiz;
import 'package:formwiz/presentation/cubits/form_field/form_field_cubit.dart' as formwiz;
import 'package:formwiz/presentation/cubits/form_field/form_field_state.dart' as formwiz;
import 'package:formwiz_example/presentation/views/form_example/widgets/form_data_column.dart';

class MiniFormColumn extends StatefulWidget {
  const MiniFormColumn({super.key});

  @override
  State<MiniFormColumn> createState() => MiniFormColumnState();
}

class MiniFormColumnState extends State<MiniFormColumn> {
  // Create FormCubit instance
  late final formwiz.FormCubit _formCubit;

  // Use local state for switch and checkbox
  bool notificationsEnabled = true;
  bool termsAccepted = false;
  String? termsError;

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Form field cubits
  late final formwiz.FormFieldCubit<String> _nameCubit;
  late final formwiz.FormFieldCubit<String> _emailCubit;

  @override
  void initState() {
    super.initState();

    // Initialize form cubit
    _formCubit = formwiz.FormCubit(validateOnChange: true);

    // Create field cubits with proper validators
    _nameCubit = formwiz.FormFieldCubit<String>(
      name: 'name',
      validators: [
        formwiz.FormWizValidator<String>((value) {
          if (value == null || value.isEmpty) {
            return 'Name is required';
          }
          return null;
        }, isRequired: true),
      ],
    );

    _emailCubit = formwiz.FormFieldCubit<String>(
      name: 'email',
      validators: [
        formwiz.FormWizValidator<String>((value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          return null;
        }, isRequired: true),
        formwiz.FormWizValidator<String>((value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Invalid email format';
          }
          return null;
        }),
      ],
    );

    // Add fields to form
    _formCubit.addField(_nameCubit);
    _formCubit.addField(_emailCubit);

    // Initialize form with empty values
    _formCubit.initialize(initialValues: {'name': '', 'email': ''});

    // Listen to field changes to update controllers
    _nameCubit.stream.listen((state) {
      if (_nameController.text != state.model.value?.toString()) {
        _nameController.text = state.model.value?.toString() ?? '';
      }
    });

    _emailCubit.stream.listen((state) {
      if (_emailController.text != state.model.value?.toString()) {
        _emailController.text = state.model.value?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    _formCubit.close();
    _nameCubit.close();
    _emailCubit.close();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Validate all fields before submission
  bool validateForm() {
    // Validate terms
    if (!termsAccepted) {
      setState(() {
        termsError = 'You must agree to the terms and conditions';
      });
      return false;
    } else {
      setState(() {
        termsError = null;
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _formCubit,
      child: BlocListener<formwiz.FormCubit, formwiz.FormCubitState>(
        listener: (context, state) {
          if (state.hasBeenSubmitted && state.isValid) {
            // Include the local state values
            final formData = Map<String, dynamic>.from(state.values);
            formData['notifications'] = notificationsEnabled;
            formData['terms'] = termsAccepted;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Form submitted: $formData'), backgroundColor: Colors.green));
          }

          if (state.hasBeenSubmitted && !state.isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fix the errors in the form'), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            // Name Field
            BlocBuilder<formwiz.FormFieldCubit<String>, formwiz.FormFieldCubitState<String>>(
              bloc: _nameCubit,
              builder: (context, state) {
                return TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    border: const OutlineInputBorder(),
                    errorText: state.model.errorMessage,
                  ),
                  onChanged: (value) {
                    _nameCubit.updateValue(value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            BlocBuilder<formwiz.FormFieldCubit<String>, formwiz.FormFieldCubitState<String>>(
              bloc: _emailCubit,
              builder: (context, state) {
                return TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: const OutlineInputBorder(),
                    errorText: state.model.errorMessage,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    _emailCubit.updateValue(value);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Notifications Switch - Custom implementation with non-clickable row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enable notifications', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'You can toggle this to enable or disable notifications',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Terms Checkbox - Custom implementation with non-clickable row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Expanded(child: const Text('I agree to terms and conditions', style: TextStyle(fontSize: 16))),
                  Checkbox(
                    value: termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        termsAccepted = value ?? false;
                        if (termsAccepted) {
                          termsError = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            if (termsError != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(termsError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (validateForm()) {
                  _formCubit.submit();
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Submit Form'),
            ),
            const SizedBox(height: 24),

            // Form Data Display
            FormDataColumn(
              notificationsEnabled: notificationsEnabled,
              termsAccepted: termsAccepted,
              nameCubit: _nameCubit,
              emailCubit: _emailCubit,
            ),
          ],
        ),
      ),
    );
  }
}
