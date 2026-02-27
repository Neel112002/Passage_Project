import 'package:flutter/material.dart';
import 'package:passage/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppBarTheme.of(context).backgroundColor,
        title:
            Text(widget.title, style: context.textStyles.titleLarge?.semiBold),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront, size: 64, color: colors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Welcome to Passage',
                  style: context.textStyles.headlineSmall?.bold),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Buy & Sell Within Your Campus — coming soon.',
                style: context.textStyles.bodyMedium,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(),
            ],
          ),
        ),
      ),
    );
  }
}

