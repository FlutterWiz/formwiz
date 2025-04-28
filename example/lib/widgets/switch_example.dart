import 'package:flutter/material.dart';

/// Example widget to showcase different configurations
/// of the FormWizSwitch field.
class SwitchExamplesWidget extends StatefulWidget {
  const SwitchExamplesWidget({super.key});

  @override
  State<SwitchExamplesWidget> createState() => _SwitchExamplesWidgetState();
}

class _SwitchExamplesWidgetState extends State<SwitchExamplesWidget> {
  // Use local state to manage switches
  bool basicSwitch = false;
  bool customColorsSwitch = true;
  bool leadingPositionSwitch = false;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch Field Examples',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Basic switch with local state
            SwitchListTile(
              title: const Text('Basic Switch'),
              subtitle: const Text('Default styling switch field'),
              value: basicSwitch,
              onChanged: (value) {
                setState(() {
                  basicSwitch = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Custom colors switch with local state
            SwitchListTile(
              title: const Text('Custom Colors'),
              subtitle: const Text('Switch with custom colors'),
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
            const SizedBox(height: 16),
            // Leading position switch with local state
            SwitchListTile(
              title: const Text('Leading Position'),
              subtitle: const Text('Switch positioned on the leading side'),
              value: leadingPositionSwitch,
              onChanged: (value) {
                setState(() {
                  leadingPositionSwitch = value;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Switch Values: {basic_switch: $basicSwitch, custom_colors: $customColorsSwitch, leading_position: $leadingPositionSwitch}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 