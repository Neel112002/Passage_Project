import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/theme.dart';
import 'package:passage/nav.dart';

/// Minimal, modern splash screen for Passage
/// - Centered app name
/// - Soft neutral background
/// - Subtle fade/slide-in animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Navigate to main app after a short delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      context.go(AppRoutes.app);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Simple lock/market icon blend
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Icon(Icons.storefront, color: colors.primary, size: 36),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Passage', style: text.headlineLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Buy & Sell Within Your Campus',
                    style: text.bodyLarge?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
