import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/item_card.dart';
import 'package:passage/nav.dart';
import 'package:provider/provider.dart';
import 'package:passage/services/item_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isRefreshing = false;
  ItemCategory? _selectedCategory; // null means all

  static const _categories = [
    ItemCategory.textbooks,
    ItemCategory.furniture,
    ItemCategory.electronics,
    ItemCategory.bikes,
    ItemCategory.clothing,
    ItemCategory.sublets,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ItemModel> _filtered(List<ItemModel> source) =>
      _selectedCategory == null ? source : source.where((e) => e.category == _selectedCategory).toList();

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _toggleBookmark(BuildContext context, ItemModel item) => context.read<ItemStore>().toggleBookmark(item.id);

  String _categoryLabel(ItemCategory c) => switch (c) {
        ItemCategory.textbooks => 'Textbooks',
        ItemCategory.furniture => 'Furniture',
        ItemCategory.electronics => 'Electronics',
        ItemCategory.bikes => 'Bikes',
        ItemCategory.clothing => 'Clothing',
        ItemCategory.sublets => 'Sublets',
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final store = context.watch<ItemStore>();
    final visibleItems = _filtered(store.items);

    return Scaffold(
      appBar: AppBar(
        title: Text('Passage', style: Theme.of(context).textTheme.titleLarge?.semiBold),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _showSnack('Search coming soon')),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/login')),
        ],
      ),
      body: Column(children: [
        _CategoriesBar(
          categories: _categories,
          selected: _selectedCategory,
          labelBuilder: _categoryLabel,
          onSelected: (c) => setState(() => _selectedCategory = c == _selectedCategory ? null : c),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: colors.primary,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: visibleItems.length,
              itemBuilder: (context, index) {
                final item = visibleItems[index];
                return ItemCard(
                  item: item,
                  onBookmarkToggle: () => _toggleBookmark(context, item),
                  onChatTap: () => context.push('/login'),
                  onTap: () => context.push(AppRoutes.product, extra: item),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _CategoriesBar extends StatelessWidget {
  const _CategoriesBar({required this.categories, required this.selected, required this.labelBuilder, required this.onSelected});

  final List<ItemCategory> categories;
  final ItemCategory? selected;
  final String Function(ItemCategory) labelBuilder;
  final void Function(ItemCategory) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final c = categories[index];
          final isSelected = c == selected;
          return ChoiceChip(
            selected: isSelected,
            label: Text(labelBuilder(c), style: text.labelLarge?.medium.withColor(isSelected ? colors.onSecondaryContainer : colors.onSurface)),
            selectedColor: colors.secondaryContainer,
            backgroundColor: colors.surface,
            side: BorderSide(color: isSelected ? colors.secondary.withValues(alpha: 0.6) : colors.outline.withValues(alpha: 0.3)),
            showCheckmark: false,
            onSelected: (_) => onSelected(c),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: categories.length,
      ),
    );
  }
}
