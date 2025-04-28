<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# FormWiz

A high-performance, customizable form builder package for Flutter.

## Features

FormWiz is a revolutionary Flutter form package that addresses common pain points in form development:

- **High Performance**: Optimized for speed, even with large forms
- **BLoC Integration**: Built with Flutter BLoC pattern in mind
- **Advanced Validation**: Rich validation system with async support
- **Conditional Logic**: Show/hide fields based on other field values
- **Responsive Design**: Forms that adapt to any screen size
- **Accessibility**: Screen reader and keyboard navigation support
- **Optimized State Management**: Granular rebuilds for maximum performance

## Getting Started

### Installation

```yaml
dependencies:
  formwiz: ^0.0.1
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FormWiz(
      onSubmitted: (values) {
        print('Form submitted: $values');
        // Handle login
      },
      child: Column(
        children: [
          FormWizTextField(
            name: 'email',
            decoration: InputDecoration(labelText: 'Email'),
            validators: [
              FormWizValidators.required('Email is required'),
              FormWizValidators.email('Please enter a valid email'),
            ],
          ),
          SizedBox(height: 16),
          FormWizTextField(
            name: 'password',
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validators: [
              FormWizValidators.required('Password is required'),
              FormWizValidators.minLength(6, 'Password must be at least 6 characters'),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => FormWiz.submit(context),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

## Advanced Features

### Conditional Fields

```dart
FormWizTextField(
  name: 'otherReason',
  decoration: InputDecoration(labelText: 'Please specify'),
  validators: [FormWizValidators.required('Please specify your reason')],
  // Only show this field if the 'reason' field has the value 'other'
  condition: (values) => values['reason'] == 'other',
),
```

### Async Validation

```dart
FormWizTextField(
  name: 'username',
  decoration: InputDecoration(labelText: 'Username'),
  validators: [
    FormWizValidators.required('Username is required'),
    FormWizValidators.async((value) async {
      // Check if username is already taken
      final response = await apiService.checkUsername(value);
      if (response.exists) {
        return 'Username already taken';
      }
      return null;
    }, 'Checking username availability...'),
  ],
),
```

### Form Submit with Validation

```dart
ElevatedButton(
  onPressed: () {
    if (FormWiz.isValid(context)) {
      final data = FormWiz.of(context);
      // Submit the form data
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  },
  child: Text('Submit'),
)
```

## Why FormWiz?

Existing form packages in Flutter have several limitations:

1. **Performance Issues**: Many become sluggish with complex forms
2. **Limited Customization**: Difficult to style beyond basic theming
3. **Verbose Validation**: Require boilerplate code for validation
4. **Poor State Management**: Inefficient rebuilds affect performance
5. **Accessibility Gaps**: Missing screen reader and keyboard support

FormWiz solves these issues with:

- Virtualized rendering for large forms
- Advanced styling system
- Streamlined validation API
- Efficient BLoC-based state management
- Complete accessibility support

## Documentation

For full documentation, visit [formwiz.dev](https://formwiz.dev).

## License

MIT
