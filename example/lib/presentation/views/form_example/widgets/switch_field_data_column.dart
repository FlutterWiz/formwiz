import 'package:flutter/material.dart';

/// A stateless widget that displays switch field values
class SwitchFieldDataColumn extends StatelessWidget {
  final bool basicSwitch;
  final bool customColorsSwitch;
  final bool leadingPositionSwitch;
  
  const SwitchFieldDataColumn({
    super.key,
    required this.basicSwitch,
    required this.customColorsSwitch,
    required this.leadingPositionSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Switch Values:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Switch: $basicSwitch'),
              Text('Custom Colors: $customColorsSwitch'),
              Text('Leading Position: $leadingPositionSwitch'),
            ],
          ),
        ),
      ],
    );
  }
} 