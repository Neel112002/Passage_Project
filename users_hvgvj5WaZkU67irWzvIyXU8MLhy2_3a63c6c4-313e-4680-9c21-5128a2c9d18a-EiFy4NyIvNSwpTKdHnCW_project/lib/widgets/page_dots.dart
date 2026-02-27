import 'package:flutter/material.dart';

/// A lightweight, dependency-free page indicator with smooth expanding dots.
/// - Uses AnimatedContainer for subtle width/opacity transitions
/// - Adapts to current theme colors unless overridden
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.activeIndex, this.dotSize = 8, this.spacing = 8, this.activeFactor = 3, this.dotColor, this.activeDotColor, this.duration = const Duration(milliseconds: 220)});

  final int count;
  final int activeIndex;
  final double dotSize;
  final double spacing;
  final double activeFactor; // how much wider the active dot becomes
  final Color? dotColor;
  final Color? activeDotColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color inactive = dotColor ?? colors.onSurface.withValues(alpha: 0.25);
    final Color active = activeDotColor ?? colors.primary;

    return SizedBox(
      height: dotSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final bool isActive = i == activeIndex;
          return AnimatedContainer(
            duration: duration,
            curve: Curves.easeOut,
            width: isActive ? dotSize * activeFactor : dotSize,
            height: dotSize,
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            decoration: BoxDecoration(
              color: isActive ? active : inactive,
              borderRadius: BorderRadius.circular(dotSize),
            ),
          );
        }),
      ),
    );
  }
}
