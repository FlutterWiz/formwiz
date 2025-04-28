# FormWiz Example App

This example app demonstrates how to use the FormWiz package to create forms in Flutter.

## Features

- Form validation with error messages
- Various field types (text, checkbox, switch)
- BLoC-based state management
- Form submission

## Getting Started

1. Ensure you have Flutter installed
2. Clone this repository
3. Run the app:

```bash
cd example
flutter pub get
flutter run
```

## Implementation Details

This example demonstrates:

- How to use FormWiz to create a form
- Using built-in field types (TextField, Checkbox, Switch)
- Form validation with required fields and format validation
- Handling form submission
- Displaying error messages
- Tracking form values in real-time

## Code Structure

- `main.dart` - Entry point of the app
- `screens/form_example_screen.dart` - Example form implementation

## Using FormWiz in Your Project

Add the FormWiz package to your `pubspec.yaml`:

```yaml
dependencies:
  formwiz:
    path: ../  # For local development
    # Or from pub.dev when published
```

Then import and use it in your code:

```dart
import 'package:formwiz/formwiz.dart';

// Use FormWiz widgets in your UI
``` 