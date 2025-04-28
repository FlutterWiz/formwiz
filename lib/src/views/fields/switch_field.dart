import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../view_models/form_field_bloc.dart' as formwiz;
import 'base_field.dart';

/// A switch field for forms
class FormWizSwitch extends FormWizBaseField<bool> {
  /// Color when the switch is on
  final Color? activeColor;
  
  /// Track color when the switch is on
  final Color? activeTrackColor;
  
  /// Color when the switch is off
  final Color? inactiveThumbColor;
  
  /// Track color when the switch is off
  final Color? inactiveTrackColor;
  
  /// Color for the thumb when disabled
  final Color? thumbColor;
  
  /// Color for the track when disabled
  final Color? trackColor;
  
  /// Material design's thumb image
  final ImageProvider? activeThumbImage;
  
  /// Material design's thumb image
  final ImageProvider? inactiveThumbImage;
  
  /// Material design's thumb image
  final MaterialStateProperty<Color?>? thumbColorProperty;
  
  /// Material design's track overlay color
  final MaterialStateProperty<Color?>? trackColorProperty;
  
  /// Drag start behavior
  final DragStartBehavior dragStartBehavior;
  
  /// Position of the switch relative to the label
  final ListTileControlAffinity controlAffinity;
  
  /// Content padding for the list tile
  final EdgeInsetsGeometry? contentPadding;
  
  /// Text to display in the switch
  final String? label;

  const FormWizSwitch({
    super.key,
    required super.name,
    super.initialValue = false,
    super.enabled,
    super.decoration = const InputDecoration(),
    super.validators = const [],
    super.onChanged,
    super.focusNode,
    super.autoValidate,
    super.fieldBloc,
    super.valueTransformer,
    super.visibilityCondition,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.trackColor,
    this.activeThumbImage,
    this.inactiveThumbImage,
    this.thumbColorProperty,
    this.trackColorProperty,
    this.dragStartBehavior = DragStartBehavior.start,
    this.controlAffinity = ListTileControlAffinity.trailing,
    this.contentPadding,
    this.label,
  });

  @override
  State<FormWizSwitch> createState() => _FormWizSwitchState();
}

class _FormWizSwitchState extends FormWizBaseFieldState<bool, FormWizSwitch> {
  @override
  Widget buildFieldWidget(
    BuildContext context, 
    formwiz.FormFieldState<bool> state, 
    InputDecoration decoration, 
    bool enabled
  ) {
    return InputDecorator(
      decoration: decoration,
      child: SwitchListTile(
        title: widget.label != null ? Text(widget.label!) : null,
        value: state.model.value ?? false,
        onChanged: enabled
            ? (value) => onFieldValueChanged(value)
            : null,
        activeColor: widget.activeColor,
        activeTrackColor: widget.activeTrackColor,
        inactiveThumbColor: widget.inactiveThumbColor,
        inactiveTrackColor: widget.inactiveTrackColor,
        thumbColor: widget.thumbColorProperty,
        trackColor: widget.trackColorProperty,
        activeThumbImage: widget.activeThumbImage,
        inactiveThumbImage: widget.inactiveThumbImage,
        controlAffinity: widget.controlAffinity,
        contentPadding: widget.contentPadding,
      ),
    );
  }
} 