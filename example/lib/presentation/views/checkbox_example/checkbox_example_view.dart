import 'package:flutter/material.dart';

/// Example showing basic FormWiz checkbox fields usage
class CheckboxExampleView extends StatelessWidget {
  const CheckboxExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormWiz Checkbox Example'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildBasicCheckboxes(context),
      ),
    );
  }

  Widget _buildBasicCheckboxes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Checkboxes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Simple form example with checkboxes
        _ExampleForm(
          name: 'basic_form',
          onSubmit: (values) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Form submitted: $values')),
            );
          },
          child: const Column(
            children: [
              _ExampleCheckbox(
                name: 'terms',
                labelText: '*I agree to the Terms and Conditions',
                required: true,
              ),
              _ExampleCheckbox(
                name: 'newsletter',
                labelText: 'Subscribe to newsletter',
                initialValue: true,
              ),
              _ExampleCheckbox(
                name: 'disabled',
                labelText: 'This checkbox is disabled',
                enabled: false,
              ),
              SizedBox(height: 24),
              _SubmitButton(formName: 'basic_form'),
            ],
          ),
        ),
      ],
    );
  }
}

// Mock classes to demonstrate what would be used from FormWiz package

/// Mock form component (simplified version of FormWiz.Form)
class _ExampleForm extends StatefulWidget {
  final String name;
  final Widget child;
  final void Function(Map<String, dynamic>)? onSubmit;

  const _ExampleForm({
    required this.name,
    required this.child,
    this.onSubmit,
  });

  @override
  State<_ExampleForm> createState() => _ExampleFormState();
}

/// Form state that includes ChangeNotifier to notify listeners of changes
class _ExampleFormState extends State<_ExampleForm> with ChangeNotifier {
  // Static registry to simulate FormWiz's global form management
  static final Map<String, _ExampleFormState> _forms = {};
  
  // Form values and validation state
  final Map<String, dynamic> values = {};
  final Map<String, bool> isValid = {};
  final List<String> requiredFields = [];
  
  @override
  void initState() {
    super.initState();
    _forms[widget.name] = this;
  }
  
  @override
  void dispose() {
    _forms.remove(widget.name);
    // Make sure to call super.dispose() after cleaning up
    notifyListeners();
    super.dispose();
  }
  
  void updateField(String name, dynamic value, {required bool valid, required bool isRequired}) {
    setState(() {
      values[name] = value;
      isValid[name] = valid;
      
      // Track required fields
      if (isRequired && !requiredFields.contains(name)) {
        requiredFields.add(name);
      } else if (!isRequired && requiredFields.contains(name)) {
        requiredFields.remove(name);
      }
    });
    
    // Notify listeners about the change
    notifyListeners();
  }
  
  // Instance method to check if form is valid
  bool checkFormValidity() {
    // Check if all required fields are valid
    for (final field in requiredFields) {
      final fieldValid = isValid[field] ?? false;
      if (!fieldValid) {
        return false;
      }
    }
    return true;
  }
  
  void submit() {
    if (!checkFormValidity()) {
      return; // Don't submit if form is invalid
    }
    
    if (widget.onSubmit != null) {
      widget.onSubmit!(Map<String, dynamic>.from(values));
    }
  }
  
  // Static method to access forms by name
  static void submitForm(String name) {
    final form = _forms[name];
    if (form != null) {
      form.submit();
    }
  }
  
  // Static method to check if a specific form is valid
  static bool checkFormValidityByName(String name) {
    final form = _forms[name];
    if (form != null) {
      return form.checkFormValidity();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Mock checkbox field component (simplified version of FormWiz.CheckboxField)
class _ExampleCheckbox extends StatefulWidget {
  final String name;
  final String? labelText;
  final bool initialValue;
  final bool required;
  final bool enabled;

  const _ExampleCheckbox({
    required this.name,
    this.labelText,
    this.initialValue = false,
    this.required = false,
    this.enabled = true,
  });

  @override
  State<_ExampleCheckbox> createState() => _ExampleCheckboxState();
}

class _ExampleCheckboxState extends State<_ExampleCheckbox> {
  late bool _value;
  bool _touched = false;
  
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    
    // Initialize form value after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormValue();
    });
  }
  
  void _updateFormValue() {
    if (!mounted) return;
    
    final form = context.findAncestorStateOfType<_ExampleFormState>();
    if (form != null) {
      // For required fields, they're only valid if checked
      final isFieldValid = !widget.required || _value;
      form.updateField(
        widget.name, 
        _value,
        valid: isFieldValid,
        isRequired: widget.required,
      );
    }
  }
  
  void _handleValueChange(bool? newValue) {
    if (!widget.enabled) return;
    
    setState(() {
      _value = newValue ?? false;
      _touched = true;
    });
    
    _updateFormValue();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _touched && widget.required && !_value;
    final errorText = hasError ? 'This field is required' : null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _value,
                onChanged: widget.enabled ? _handleValueChange : null,
              ),
              if (widget.labelText != null)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.enabled 
                        ? () => _handleValueChange(!_value) 
                        : null,
                    child: Text(
                      widget.labelText!,
                      style: widget.labelText!.startsWith('*') ? 
                          TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary) : 
                          null,
                    ),
                  ),
                ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 4.0),
              child: Text(
                errorText,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12.0),
              ),
            ),
        ],
      ),
    );
  }
}

/// Submit button that observes form validity
class _SubmitButton extends StatefulWidget {
  final String formName;
  
  const _SubmitButton({
    required this.formName,
  });
  
  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _isValid = false;
  _ExampleFormState? _formState;
  
  @override
  void initState() {
    super.initState();
    // After build is complete, look up the form and add listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupFormListeners();
    });
  }
  
  void _setupFormListeners() {
    // Get the form state
    _formState = _ExampleFormState._forms[widget.formName];
    
    if (_formState != null) {
      // Set initial validity
      _checkFormValidity();
      
      // Tell the form to notify us when it changes
      _formState?.addListener(_onFormChanged);
    }
  }
  
  void _onFormChanged() {
    // When the form changes, update our validity state
    _checkFormValidity();
  }
  
  void _checkFormValidity() {
    final isValid = _ExampleFormState.checkFormValidityByName(widget.formName);
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }
  
  @override
  void dispose() {
    // Remove listener when widget is disposed
    _formState?.removeListener(_onFormChanged);
    _formState = null;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isValid 
            ? () => _ExampleFormState.submitForm(widget.formName)
            : null, // Disable button when form is invalid
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          // When disabled, use a grey color
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.grey.shade700,
        ),
        child: const Text('Submit Form'),
      ),
    );
  }
} 