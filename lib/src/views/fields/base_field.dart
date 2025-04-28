import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/validation_model.dart';
import '../../view_models/form_bloc.dart' as formwiz_bloc;
import '../../view_models/form_field_bloc.dart' as formwiz;
import '../form.dart';

/// Base class for all form fields to reduce code duplication.
/// Implements MVVM pattern with the view (Widget) connecting to the
/// view model (FormFieldBloc) which interacts with the model (FormFieldModel).
abstract class FormWizBaseField<T> extends StatefulWidget {
  /// Unique name for the field within the form
  final String name;
  
  /// Initial value for the field
  final T? initialValue;
  
  /// Whether the field is enabled
  final bool? enabled;
  
  /// Decoration for the field
  final InputDecoration decoration;
  
  /// List of validators for the field
  final List<FormWizValidator<T>> validators;
  
  /// Callback when the field value changes
  final void Function(T? value)? onChanged;
  
  /// Focus node for the field
  final FocusNode? focusNode;
  
  /// Whether to auto-validate the field
  final bool? autoValidate;
  
  /// Whether to use an external FormFieldBloc instead of creating one
  final formwiz.FormFieldBloc<T>? fieldBloc;
  
  /// Transform value function
  final T? Function(T?)? valueTransformer;

  /// Condition that determines if this field should be visible
  final bool Function(Map<String, dynamic>)? visibilityCondition;

  const FormWizBaseField({
    super.key,
    required this.name,
    this.initialValue,
    this.enabled,
    this.decoration = const InputDecoration(),
    this.validators = const [],
    this.onChanged,
    this.focusNode,
    this.autoValidate,
    this.fieldBloc,
    this.valueTransformer,
    this.visibilityCondition,
  });
}

/// Base state class for all form field states.
abstract class FormWizBaseFieldState<T, W extends FormWizBaseField<T>> extends State<W> {
  late formwiz.FormFieldBloc<T> _fieldBloc;
  late FocusNode _focusNode;
  bool _didInitializeController = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_didInitializeController) {
      _initializeFieldBloc();
      _didInitializeController = true;
    }
  }
  
  /// Initialize the field bloc and register it with the form
  void _initializeFieldBloc() {
    final formBloc = BlocProvider.of<formwiz_bloc.FormBloc>(context);
    final formScope = FormScope.of(context);
    
    // Use external field bloc or create a new one
    _fieldBloc = widget.fieldBloc ?? formwiz.FormFieldBloc<T>(
      name: widget.name,
      initialValue: widget.initialValue,
      validators: widget.validators,
    );
    
    // Add the field to the form
    formBloc.add(formwiz_bloc.FormFieldAdded(_fieldBloc));
    
    // Subscribe to field bloc changes
    _fieldBloc.stream.listen((state) {
      if (_disposed) return;
      
      // Handle value change
      onFieldStateChanged(state);
      
      // Call onChanged callback if provided
      if (widget.onChanged != null && _didInitializeController) {
        widget.onChanged!(state.model.value);
      }
      
      // Auto validate if needed
      final autoValidate = widget.autoValidate ?? formScope?.autoValidate ?? false;
      if (autoValidate && state is formwiz.FormFieldValid<T>) {
        _fieldBloc.add(formwiz.FormFieldValidationRequested<T>(state.model.value));
      }
    });
    
    // Call initialize method in subclasses
    onFieldBlocInitialized(_fieldBloc);
  }
  
  /// Called when the field bloc is initialized
  void onFieldBlocInitialized(formwiz.FormFieldBloc<T> fieldBloc) {
    // Implementation provided by subclasses
  }
  
  /// Called when the field state changes
  void onFieldStateChanged(formwiz.FormFieldState<T> state) {
    // Implementation provided by subclasses
  }
  
  /// Called when the field value changes
  void onFieldValueChanged(T? value) {
    final transformedValue = widget.valueTransformer != null 
        ? widget.valueTransformer!(value) 
        : value;
    _fieldBloc.add(formwiz.FormFieldValueChanged<T>(transformedValue));
  }
  
  /// Update field focus state
  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _fieldBloc.add(formwiz.FormFieldFocused());
    } else {
      _fieldBloc.add(formwiz.FormFieldBlurred());
    }
  }
  
  @override
  void dispose() {
    _disposed = true;
    
    // Only dispose resources we created
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    
    _focusNode.removeListener(_onFocusChanged);
    
    // We don't dispose the field bloc, as the form will handle that
    super.dispose();
  }
  
  /// Get the current field bloc
  formwiz.FormFieldBloc<T> get fieldBloc => _fieldBloc;
  
  /// Get the current focus node
  FocusNode get focusNode => _focusNode;
  
  /// Get whether the field has been disposed
  bool get isDisposed => _disposed;
  
  @override
  Widget build(BuildContext context) {
    final formScope = FormScope.of(context);
    final enabled = widget.enabled ?? formScope?.enabled ?? true;
    
    // Check visibility condition if provided
    if (widget.visibilityCondition != null) {
      return BlocBuilder<formwiz_bloc.FormBloc, formwiz_bloc.FormState>(
        builder: (context, state) {
          final isVisible = widget.visibilityCondition!(state.values);
          if (!isVisible) {
            return const SizedBox.shrink();
          }
          
          return buildField(context, enabled);
        },
      );
    }
    
    return buildField(context, enabled);
  }
  
  /// Build the field widget
  Widget buildField(BuildContext context, bool enabled) {
    return BlocBuilder<formwiz.FormFieldBloc<T>, formwiz.FormFieldState<T>>(
      bloc: _fieldBloc,
      builder: (context, state) {
        // Build input decoration with error
        final decorationWithError = widget.decoration.copyWith(
          errorText: state.model.touched ? state.model.errorMessage : null,
        );
        
        return buildFieldWidget(context, state, decorationWithError, enabled);
      },
    );
  }
  
  /// Build the actual field widget (to be implemented by subclasses)
  Widget buildFieldWidget(
    BuildContext context, 
    formwiz.FormFieldState<T> state, 
    InputDecoration decoration, 
    bool enabled
  );
} 