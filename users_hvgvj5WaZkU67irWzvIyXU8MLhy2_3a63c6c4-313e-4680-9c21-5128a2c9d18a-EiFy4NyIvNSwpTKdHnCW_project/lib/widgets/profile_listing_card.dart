import 'package:flutter/material.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/theme.dart';

/// Compact card for a user's listing inside the profile screen grid
class ProfileListingCard extends StatelessWidget {
  const ProfileListingCard({super.key, required this.item, required this.onTap});

  final ItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.outline.withValues(alpha: 0.16)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary.withValues(alpha: 0.12), colors.secondary.withValues(alpha: 0.12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(child: Icon(Icons.image_outlined, size: 40, color: colors.onSurfaceVariant)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall?.semiBold),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 4, AppSpacing.md, AppSpacing.sm),
            child: Text(item.displayPrice, style: text.titleMedium?.bold.withColor(colors.primary)),
          ),
        ]),
      ),
    );
  }
}
