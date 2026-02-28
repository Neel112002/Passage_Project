import 'package:flutter/material.dart';
import 'package:passage/screens/home_screen.dart';
import 'package:passage/screens/messages_screen.dart';
import 'package:passage/screens/profile_screen.dart';
import 'package:passage/screens/sell_screen.dart';
// import 'package:passage/theme.dart';

/// MainApp is the tab scaffold shown after splash
/// Uses IndexedStack to preserve each tab's state
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box_rounded), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      SellScreen(onPosted: () => setState(() => _currentIndex = 0)),
      const MessagesScreen(),
      const ProfileScreen(),
    ];
  }
}
