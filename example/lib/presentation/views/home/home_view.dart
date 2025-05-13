import 'package:flutter/material.dart';
import 'package:formwiz_example/presentation/widgets/menu_card.dart';
import 'package:formwiz_example/presentation/views/checkbox/checkbox_view.dart';

/// Home screen with navigation to different form field examples
class HomeView extends StatelessWidget {
  /// Creates a new HomeView
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormWiz Examples'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Form Field Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            MenuCard(
              title: 'Checkbox Field',
              description: 'Single checkbox and checkbox group examples',
              icon: Icons.check_box,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckboxView()),
              ),
            ),
            
            // Additional field pages will be added here
            
            const SizedBox(height: 24),
            const Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            const MenuCard(
              title: 'Text Field',
              description: 'Text input examples (coming soon)',
              icon: Icons.text_fields,
              enabled: false,
            ),
            
            const MenuCard(
              title: 'Radio Field',
              description: 'Radio button examples (coming soon)',
              icon: Icons.radio_button_checked,
              enabled: false,
            ),
            
            const MenuCard(
              title: 'Dropdown Field',
              description: 'Dropdown selection examples (coming soon)',
              icon: Icons.arrow_drop_down_circle,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
} 