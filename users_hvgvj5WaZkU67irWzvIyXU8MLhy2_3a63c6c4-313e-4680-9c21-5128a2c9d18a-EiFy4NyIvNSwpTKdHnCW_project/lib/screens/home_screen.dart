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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppBarTheme.of(context).backgroundColor,
        title: Text(widget.title, style: context.textStyles.titleLarge?.semiBold),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.vpn_key, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Welcome to Passage', style: context.textStyles.headlineSmall?.bold),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A modern Flutter starter, production-ready for Android and iOS.',
                style: context.textStyles.bodyMedium,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.blue),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text('You have tapped the button this many times:', style: context.textStyles.bodyMedium),
                      ),
                      Text('$_counter', style: context.textStyles.headlineMedium?.semiBold),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
