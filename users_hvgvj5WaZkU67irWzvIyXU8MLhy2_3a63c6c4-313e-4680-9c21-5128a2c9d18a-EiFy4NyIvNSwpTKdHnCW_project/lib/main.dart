import 'package:flutter/material.dart';
import 'package:passage/theme.dart';
import 'package:passage/nav.dart';
import 'package:provider/provider.dart';
import 'package:passage/services/item_store.dart';

/// Main entry point for the application
///
/// This sets up:
/// - go_router navigation
/// - Material 3 theming with light/dark modes
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemStore>(
      create: (_) => ItemStore(),
      child: MaterialApp.router(
        title: 'Passage',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
