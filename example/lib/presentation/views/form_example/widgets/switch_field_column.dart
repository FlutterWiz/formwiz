import 'package:flutter/material.dart';

import 'package:formwiz_example/presentation/views/form_example/widgets/switch_field_data_column.dart';

/// Example widget to showcase different configurations
/// of the FormWizSwitch field.
class SwitchFieldColumn extends StatefulWidget {
  const SwitchFieldColumn({super.key});

  @override
  State<SwitchFieldColumn> createState() => _SwitchFieldColumnState();
}

class _SwitchFieldColumnState extends State<SwitchFieldColumn> {
  // Use local state to manage switches
  bool basicSwitch = false;
  bool customColorsSwitch = true;
  bool leadingPositionSwitch = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Basic Switch', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Default styling switch field',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: basicSwitch,
                    onChanged: (value) {
                      setState(() {
                        basicSwitch = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Custom colors switch with local state
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Custom Colors', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Switch with custom colors', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Switch(
                    value: customColorsSwitch,
                    onChanged: (value) {
                      setState(() {
                        customColorsSwitch = value;
                      });
                    },
                    activeColor: Colors.green,
                    activeTrackColor: Colors.lightGreen.shade200,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Leading position switch with local state
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Switch(
                    value: leadingPositionSwitch,
                    onChanged: (value) {
                      setState(() {
                        leadingPositionSwitch = value;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Leading Position', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Switch positioned on the leading side',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Use the new SwitchFieldDataColumn widget
            SwitchFieldDataColumn(
              basicSwitch: basicSwitch,
              customColorsSwitch: customColorsSwitch,
              leadingPositionSwitch: leadingPositionSwitch,
            ),
          ],
        ),
      ),
    );
  }
}
