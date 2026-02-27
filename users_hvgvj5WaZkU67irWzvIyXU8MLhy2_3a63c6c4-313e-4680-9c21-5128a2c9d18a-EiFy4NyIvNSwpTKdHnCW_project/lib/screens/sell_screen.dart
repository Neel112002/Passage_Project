import 'package:flutter/material.dart';
import 'package:passage/theme.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Sell', style: text.titleLarge?.semiBold)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(Icons.add_box_rounded, color: colors.onSecondaryContainer, size: 48),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Create a new listing', style: text.titleMedium?.medium),
            const SizedBox(height: AppSpacing.xs),
            Text('Coming soon', style: text.bodyMedium?.withColor(colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
