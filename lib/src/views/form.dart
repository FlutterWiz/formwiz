import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_models/form_bloc.dart';

/// A highly customizable and performant form widget for Flutter.
class FormWiz extends StatefulWidget {
  /// Child widgets to be displayed within the form
  final Widget child;
  
  /// Optional form bloc to use instead of creating a new one
  final FormBloc? formBloc;
  
  /// Initial values for the form fields
  final Map<String, dynamic> initialValues;
  
  /// Callback when the form is submitted successfully
  final void Function(Map<String, dynamic> values)? onSubmitted;
  
  /// Callback when the form validation fails on submission
  final void Function(Map<String, String?> errors)? onInvalid;
  
  /// Callback when the form values change
  final void Function(Map<String, dynamic> values)? onChanged;
  
  /// Whether to automatically validate the form on changes
  final bool autoValidate;
  
  /// Whether to enable the form
  final bool enabled;

  const FormWiz({
    super.key,
    required this.child,
    this.formBloc,
    this.initialValues = const {},
    this.onSubmitted,
    this.onInvalid,
    this.onChanged,
    this.autoValidate = false,
    this.enabled = true,
  });
  
  /// Static method to get form data from the context
  static Map<String, dynamic> of(BuildContext context) {
    final formBloc = BlocProvider.of<FormBloc>(context);
    return formBloc.state.values;
  }
  
  /// Static method to get form validity from the context
  static bool isValid(BuildContext context) {
    final formBloc = BlocProvider.of<FormBloc>(context);
    return formBloc.state.isValid;
  }
  
  /// Static method to get form errors from the context
  static Map<String, String?> getErrors(BuildContext context) {
    final formBloc = BlocProvider.of<FormBloc>(context);
    if (formBloc.state is FormValidationFailure) {
      return (formBloc.state as FormValidationFailure).errors;
    }
    return {};
  }
  
  /// Static method to submit the form from anywhere in the widget tree
  static void submit(BuildContext context) {
    final formBloc = BlocProvider.of<FormBloc>(context);
    formBloc.add(FormSubmitted());
  }
  
  /// Static method to reset the form from anywhere in the widget tree
  static void reset(BuildContext context) {
    final formBloc = BlocProvider.of<FormBloc>(context);
    formBloc.add(FormReset());
  }
  
  /// Static method to patch form values from anywhere in the widget tree
  static void patchValues(BuildContext context, Map<String, dynamic> values) {
    final formBloc = BlocProvider.of<FormBloc>(context);
    formBloc.add(FormValuePatched(values));
  }

  @override
  State<FormWiz> createState() => _FormWizState();
}

class _FormWizState extends State<FormWiz> {
  late FormBloc _formBloc;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _formBloc = widget.formBloc ?? FormBloc();
    
    _formBloc.add(FormInitialized(initialValues: widget.initialValues));
    
    // Listen to form changes
    _formBloc.stream.listen((state) {
      if (_disposed) return;
      
      if (widget.onChanged != null) {
        widget.onChanged!(state.values);
      }
      
      if (state is FormSubmissionSuccess && widget.onSubmitted != null) {
        widget.onSubmitted!(state.values);
      }
      
      if (state is FormValidationFailure && 
          state.hasBeenSubmitted && 
          widget.onInvalid != null) {
        widget.onInvalid!(state.errors);
      }
    });
  }
  
  @override
  void didUpdateWidget(FormWiz oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the formBloc was provided externally and it changed
    if (widget.formBloc != null && widget.formBloc != oldWidget.formBloc) {
      _formBloc = widget.formBloc!;
    }
    
    // If initialValues changed, reinitialize
    if (widget.initialValues != oldWidget.initialValues) {
      _formBloc.add(FormInitialized(initialValues: widget.initialValues));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (widget.formBloc == null) {
      // Only close the bloc if we created it
      _formBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the form bloc to descendant widgets
    return BlocProvider<FormBloc>.value(
      value: _formBloc,
      child: FormScope(
        enabled: widget.enabled,
        autoValidate: widget.autoValidate,
        child: widget.child,
      ),
    );
  }
}

/// A widget that provides form functionality to its descendants
class FormScope extends InheritedWidget {
  final bool enabled;
  final bool autoValidate;

  const FormScope({
    super.key,
    required super.child,
    required this.enabled,
    required this.autoValidate,
  });

  static FormScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FormScope>();
  }

  @override
  bool updateShouldNotify(FormScope oldWidget) {
    return oldWidget.enabled != enabled || oldWidget.autoValidate != autoValidate;
  }
} 