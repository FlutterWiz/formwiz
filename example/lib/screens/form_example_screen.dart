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
  // Create standalone FormBloc
  late final formwiz.FormBloc _formBloc;
  
  // Use local state for switch and checkbox
  bool notificationsEnabled = true;
  bool termsAccepted = false;
  String? termsError;
  
  @override
  void initState() {
    super.initState();
    _formBloc = formwiz.FormBloc();
  }
  
  @override
  void dispose() {
    _formBloc.close();
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
      value: _formBloc,
      child: formwiz.FormWiz(
        formBloc: _formBloc,
        initialValues: const {
          'name': '',
          'email': '',
        },
        autoValidate: true,
        child: BlocListener<formwiz.FormBloc, formwiz.FormState>(
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
              formwiz.FormWizTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                validators: [
                  formwiz.FormWizValidator.required('Name is required'),
                ],
              ),
              const SizedBox(height: 16),
              
              formwiz.FormWizTextField(
                name: 'email',
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validators: [
                  formwiz.FormWizValidator.required('Email is required'),
                  formwiz.FormWizValidator.email('Invalid email format'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Use a regular SwitchListTile
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
              
              // Use a regular CheckboxListTile
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
              
              ElevatedButton(
                onPressed: () {
                  if (validateForm()) {
                    _formBloc.add(formwiz.FormSubmitted());
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit Form'),
              ),
              const SizedBox(height: 24),
              
              _FormDataDisplay(
                notificationsEnabled: notificationsEnabled,
                termsAccepted: termsAccepted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormDataDisplay extends StatelessWidget {
  final bool notificationsEnabled;
  final bool termsAccepted;
  
  const _FormDataDisplay({
    required this.notificationsEnabled,
    required this.termsAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<formwiz.FormBloc, formwiz.FormState>(
      builder: (context, state) {
        // Include the local state values
        final displayValues = Map<String, dynamic>.from(state.values);
        displayValues['notifications'] = notificationsEnabled;
        displayValues['terms'] = termsAccepted;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Form Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValues.toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        );
      },
    );
  }
} 