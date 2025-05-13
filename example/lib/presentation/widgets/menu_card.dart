import 'package:flutter/material.dart';

/// A card widget for displaying menu items in the home screen
class MenuCard extends StatelessWidget {
  /// Title of the menu item
  final String title;
  
  /// Optional description
  final String? description;
  
  /// Icon to display
  final IconData icon;
  
  /// Whether the card is enabled
  final bool enabled;
  
  /// Callback when tapped
  final VoidCallback? onTap;

  /// Creates a new menu card
  const MenuCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: enabled 
          ? colorScheme.surface 
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      elevation: enabled ? 2 : 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled 
                      ? colorScheme.primary.withAlpha(25)
                      : colorScheme.onSurface.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: enabled 
                      ? colorScheme.primary 
                      : colorScheme.onSurface.withAlpha(102),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: enabled 
                            ? colorScheme.onSurface 
                            : colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: enabled 
                              ? colorScheme.onSurface.withAlpha(179)
                              : colorScheme.onSurface.withAlpha(102),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (enabled)
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
} 