import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formwiz/formwiz.dart' as formwiz;

import '../widgets/switch_example.dart';

class FormExampleScreen extends StatelessWidget {
  const FormExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormWiz Example'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Example',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const _ExampleForm(),
              const SizedBox(height: 32),
              const Text(
                'Switch Field Showcase',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const SwitchExamplesWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleForm extends StatefulWidget {
  const _ExampleForm();

  @override
  State<_ExampleForm> createState() => _ExampleFormState();
}

class _ExampleFormState extends State<_ExampleForm> {
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
    _formCubit.initialize(initialValues: {
      'name': '',
      'email': '',
    });
    
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
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Form submitted: $formData'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          if (state.hasBeenSubmitted && !state.isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fix the errors in the form'),
                backgroundColor: Colors.red,
              ),
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
            
            // Notifications Switch
            SwitchListTile(
              title: const Text('Enable notifications'),
              subtitle: const Text('You can toggle this to enable or disable notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                side: BorderSide(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            
            // Terms Checkbox
            CheckboxListTile(
              title: const Text('I agree to terms and conditions'),
              value: termsAccepted,
              onChanged: (value) {
                setState(() {
                  termsAccepted = value ?? false;
                  if (termsAccepted) {
                    termsError = null;
                  }
                });
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                side: BorderSide(color: Colors.grey),
              ),
            ),
            if (termsError != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  termsError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            
            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (validateForm()) {
                  _formCubit.submit();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit Form'),
            ),
            const SizedBox(height: 24),
            
            // Form Data Display
            _FormDataDisplay(
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

class _FormDataDisplay extends StatelessWidget {
  final bool notificationsEnabled;
  final bool termsAccepted;
  final formwiz.FormFieldCubit<String> nameCubit;
  final formwiz.FormFieldCubit<String> emailCubit;
  
  const _FormDataDisplay({
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
            const Text(
              'Form Data:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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