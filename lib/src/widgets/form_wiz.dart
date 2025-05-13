import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formwiz/src/presentation/cubits/form/form_cubit.dart';

/// Main form widget that provides the form context for all form fields
class FormWiz extends StatefulWidget {
  /// Form's unique identifier
  final String? id;

  /// Callback for form submission
  final void Function(Map<String, dynamic> values)? onSubmit;

  /// Form's child widgets (including form fields)
  final List<Widget> children;

  /// Optional padding around the form
  final EdgeInsetsGeometry? padding;

  /// Creates a new FormWiz widget
  const FormWiz({
    super.key,
    this.id,
    this.onSubmit,
    required this.children,
    this.padding,
  });

  @override
  State<FormWiz> createState() => _FormWizState();
}

class _FormWizState extends State<FormWiz> {
  late FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit(onSubmit: widget.onSubmit);
  }

  @override
  void dispose() {
    _formCubit.close();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(covariant FormWiz oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onSubmit != widget.onSubmit) {
      _formCubit.close();
      _formCubit = FormCubit(onSubmit: widget.onSubmit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _formCubit,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: widget.children,
        ),
      ),
    );
  }
} 