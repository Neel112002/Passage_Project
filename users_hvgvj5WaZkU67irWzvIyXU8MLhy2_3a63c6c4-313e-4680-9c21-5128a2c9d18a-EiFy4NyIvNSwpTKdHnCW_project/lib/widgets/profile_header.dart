import 'package:flutter/material.dart';
import 'package:passage/theme.dart';

/// Modern profile header with avatar, name, university, joined date and stats.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
    required this.joinedText,
    required this.listingsCount,
    required this.soldCount,
    required this.savedCount,
  });

  final String name;
  final String university;
  final String joinedText; // e.g., "Joined Sep 2024"
  final int listingsCount;
  final int soldCount;
  final int savedCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: colors.primaryContainer,
            child: Text(_initials(name), style: text.headlineSmall?.bold.withColor(colors.onPrimaryContainer)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(name, style: text.titleLarge?.semiBold),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.school, size: 16, color: colors.tertiary),
            const SizedBox(width: 6),
            Text(university, style: text.labelMedium?.withColor(colors.onSurfaceVariant)),
          ]),
          const SizedBox(height: 6),
          Text(joinedText, style: text.labelSmall?.withColor(colors.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.lg),
          _StatsRow(listings: listingsCount, sold: soldCount, saved: savedCount),
        ],
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return '';
    final first = parts.first.isNotEmpty ? parts.first.characters.first : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.listings, required this.sold, required this.saved});
  final int listings;
  final int sold;
  final int saved;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget stat(String value, String label) => Expanded(
          child: Column(children: [
            Text(value, style: text.titleLarge?.bold.withColor(colors.primary)),
            const SizedBox(height: 4),
            Text(label, style: text.labelSmall?.withColor(colors.onSurfaceVariant)),
          ]),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline.withValues(alpha: 0.16)),
      ),
      child: Row(children: [
        stat(listings.toString(), 'Listings'),
        _DividerDot(color: colors.outline.withValues(alpha: 0.25)),
        stat(sold.toString(), 'Sold'),
        _DividerDot(color: colors.outline.withValues(alpha: 0.25)),
        stat(saved.toString(), 'Saved'),
      ]),
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(width: 1, height: 24, color: color),
      );
}
