import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/services/item_service.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final List<ItemModel> _visibleItems = [];
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  ItemCategory? _selectedCategory; // null means all
  final ItemService _service = ItemService.instance;

  static const _categories = [
    ItemCategory.textbooks,
    ItemCategory.furniture,
    ItemCategory.electronics,
    ItemCategory.bikes,
    ItemCategory.clothing,
    ItemCategory.sublets,
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _scrollController.addListener(_onScroll);
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  Future<void> _initData() async {
    // Seeded by ItemService; just reflect into visible list
    _applyFilter();
    setState(() {});
  }

  void _applyFilter() {
    final source = _service.items;
    _visibleItems
      ..clear()
      ..addAll(_selectedCategory == null ? source : source.where((e) => e.category == _selectedCategory));
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _service.refresh();
    _applyFilter();
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    final more = await _service.loadMore(count: 10);
    final currentCategory = _selectedCategory;
    if (currentCategory == null) {
      _visibleItems.addAll(more);
    } else {
      _visibleItems.addAll(more.where((e) => e.category == currentCategory));
    }
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _toggleBookmark(ItemModel item) {
    _service.toggleBookmark(item.id);
  }

  void _onServiceChanged() {
    // Underlying list changed (e.g., new post or bookmark); reapply filter
    _applyFilter();
    if (mounted) setState(() {});
  }

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
          onSelected: (c) {
            setState(() => _selectedCategory = c == _selectedCategory ? null : c);
            _applyFilter();
            setState(() {});
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: colors.primary,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _visibleItems.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _visibleItems.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: SizedBox(height: 28, width: 28, child: CircularProgressIndicator(strokeWidth: 2.6))),
                  );
                }
                final item = _visibleItems[index];
                return ItemCard(
                  item: item,
                  onBookmarkToggle: () => _toggleBookmark(item),
                  onChatTap: () => context.push('/login'),
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
