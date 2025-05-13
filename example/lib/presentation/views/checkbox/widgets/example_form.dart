import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';

/// Example form wrapper for demonstration
class ExampleForm extends StatefulWidget {
  /// Optional description text
  final String? description;
  
  /// Form fields to display
  final List<Widget> children;
  
  /// Text to display on submit button
  final String submitButtonText;
  
  /// Whether to show a validation message
  final bool showValidationMessage;

  /// Creates a new example form
  const ExampleForm({
    super.key,
    this.description,
    required this.children,
    this.submitButtonText = 'Submit Form',
    this.showValidationMessage = false,
  });

  @override
  State<ExampleForm> createState() => _ExampleFormState();
}

class _ExampleFormState extends State<ExampleForm> {
  bool _submitted = false;
  Map<String, dynamic>? _formValues;

  void _handleSubmit(Map<String, dynamic> values) {
    setState(() {
      _submitted = true;
      _formValues = values;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form submitted: $values'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.description != null) ...[
          Text(widget.description!),
          const SizedBox(height: 16),
        ],
        
        FormWiz(
          onSubmit: _handleSubmit,
          padding: EdgeInsets.zero,
          children: [
            ...widget.children,
            
            const SizedBox(height: 24),
            
            if (widget.showValidationMessage && _submitted && _formValues != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Values:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formValues.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            FormWizSubmitButton(
              text: widget.submitButtonText,
              width: double.infinity,
            ),
          ],
        ),
      ],
    );
  }
} 