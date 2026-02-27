import 'package:flutter/material.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/theme.dart';

/// Instagram-style marketplace card for an item
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.onBookmarkToggle, required this.onChatTap});

  final ItemModel item;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline.withValues(alpha: 0.16), width: 1),
        boxShadow: [
          BoxShadow(color: colors.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            CircleAvatar(backgroundColor: item.avatarColor, radius: 18, child: Text(item.initials, style: text.labelLarge?.copyWith(color: Colors.white))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.sellerName, style: text.titleSmall?.semiBold),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.school, size: 14, color: colors.tertiary),
                  const SizedBox(width: 6),
                  Text(item.university, style: text.labelSmall?.withColor(colors.onSurfaceVariant)),
                ]),
              ]),
            ),
            _ConditionTag(condition: item.condition),
          ]),
        ),
        _ImagePlaceholder(item: item),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: text.titleMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(item.displayPrice, style: text.headlineSmall?.bold?.withColor(colors.primary)),
              ]),
            ),
            IconButton(
              isSelected: item.isBookmarked,
              icon: const Icon(Icons.bookmark_outline),
              selectedIcon: const Icon(Icons.bookmark),
              color: colors.primary,
              onPressed: onBookmarkToggle,
              tooltip: 'Save',
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          child: Row(children: [
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onChatTap,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppRadius.lg),
        topRight: Radius.circular(AppRadius.lg),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              colors.primary.withValues(alpha: 0.12),
              colors.secondary.withValues(alpha: 0.12),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Center(
            child: Icon(Icons.image_outlined, size: 64, color: colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _ConditionTag extends StatelessWidget {
  const _ConditionTag({required this.condition});
  final ItemCondition condition;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = condition == ItemCondition.brandNew ? colors.secondaryContainer : colors.surfaceContainerHighest;
    final fg = condition == ItemCondition.brandNew ? colors.onSecondaryContainer : colors.onSurfaceVariant;
    final label = condition == ItemCondition.brandNew ? 'New' : 'Used';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.semiBold.withColor(fg)),
    );
  }
}
