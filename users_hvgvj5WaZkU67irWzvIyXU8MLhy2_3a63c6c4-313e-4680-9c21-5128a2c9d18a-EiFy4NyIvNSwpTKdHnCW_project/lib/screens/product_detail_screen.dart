import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/services/item_service.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/condition_tag.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.item});
  final ItemModel item;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ItemModel _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    // Listen to service updates to reflect bookmark changes made elsewhere
    ItemService.instance.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    ItemService.instance.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    final updated = ItemService.instance.items.where((e) => e.id == _item.id).toList();
    if (updated.isNotEmpty && mounted) setState(() => _item = updated.first);
  }

  void _toggleBookmark() => ItemService.instance.toggleBookmark(_item.id);

  String _fallbackDescription(ItemModel item) {
    final base = 'Great ${item.conditionLabel.toLowerCase()} ${_categoryLabel(item.category)}.';
    return '$base Well-kept by ${item.sellerName}. Available near ${item.university} campus. DM to learn more!';
  }

  String _categoryLabel(ItemCategory c) => switch (c) {
        ItemCategory.textbooks => 'textbook',
        ItemCategory.furniture => 'furniture',
        ItemCategory.electronics => 'electronics item',
        ItemCategory.bikes => 'bike',
        ItemCategory.clothing => 'clothing',
        ItemCategory.sublets => 'sublet',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          child: Row(children: [
            IconButton(
              isSelected: _item.isBookmarked,
              icon: const Icon(Icons.bookmark_outline),
              selectedIcon: const Icon(Icons.bookmark),
              color: colors.primary,
              onPressed: _toggleBookmark,
              tooltip: 'Save',
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat with Seller'),
              ),
            ),
          ]),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image header
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  colors.primary.withValues(alpha: 0.12),
                  colors.secondary.withValues(alpha: 0.12),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Center(child: Icon(Icons.image_outlined, size: 96, color: colors.onSurfaceVariant)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(_item.title, style: text.headlineSmall?.bold, softWrap: true)),
                const SizedBox(width: AppSpacing.md),
                ConditionTag(condition: _item.condition),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Text(_item.displayPrice, style: text.headlineMedium?.bold?.withColor(colors.primary)),
              const SizedBox(height: AppSpacing.lg),
              // Seller section
              Row(children: [
                CircleAvatar(backgroundColor: _item.avatarColor, radius: 22, child: Text(_item.initials, style: text.labelLarge?.copyWith(color: Colors.white))),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_item.sellerName, style: text.titleMedium?.semiBold),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.school, size: 16, color: colors.tertiary),
                      const SizedBox(width: 6),
                      Text(_item.university, style: text.labelMedium?.withColor(colors.onSurfaceVariant)),
                    ]),
                  ]),
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Divider(color: colors.outline.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: AppSpacing.lg),
              Text('Description', style: text.titleLarge?.semiBold),
              const SizedBox(height: AppSpacing.sm),
              Text(_fallbackDescription(_item), style: text.bodyLarge),
            ]),
          ),
        ]),
      ),
    );
  }
}
