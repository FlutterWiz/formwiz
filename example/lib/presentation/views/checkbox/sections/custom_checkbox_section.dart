import 'package:flutter/material.dart';
import 'package:formwiz/formwiz.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/section_container.dart';
import 'package:formwiz_example/presentation/views/checkbox/widgets/example_form.dart';

/// Custom checkbox styling examples section
class CustomCheckboxSection extends StatelessWidget {
  /// Creates a custom checkbox styling examples section
  const CustomCheckboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SectionContainer(
      title: 'Custom Styling',
      description: 'Examples of custom styled checkbox fields',
      child: ExampleForm(
        description: 'Checkboxes with custom styling:',
        children: [
          // Checkbox with custom theme
          FormWizCheckboxField(
            name: 'custom_theme',
            labelText: 'Checkbox with custom theme',
            initialValue: true,
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.secondary;
                }
                return null;
              }),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Custom builder for checkbox
          FormWizCheckboxField(
            name: 'custom_builder',
            labelText: 'Custom builder checkbox',
            builder: (context, value, isValid, errorText, onChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => onChanged(!value),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: value 
                                ? colorScheme.tertiary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: value
                                  ? colorScheme.tertiary
                                  : colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: value
                              ? Icon(
                                  Icons.check,
                                  size: 20,
                                  color: colorScheme.onTertiary,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Custom styled checkbox'),
                    ],
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Custom group option builder
          FormWizCheckboxGroupField(
            name: 'custom_group',
            labelText: 'Custom checkbox group:',
            options: const ['Option A', 'Option B', 'Option C'],
            initialValues: const ['Option A'],
            optionBuilder: (context, option, label, isSelected, onToggle) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 