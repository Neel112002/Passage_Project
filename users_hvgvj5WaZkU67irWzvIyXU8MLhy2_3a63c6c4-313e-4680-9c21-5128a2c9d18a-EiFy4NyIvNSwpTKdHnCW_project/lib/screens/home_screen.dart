import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/theme.dart';
import 'package:passage/widgets/item_card.dart';
import 'package:passage/nav.dart';
import 'package:provider/provider.dart';
import 'package:passage/services/item_store.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _isRefreshing = false;
  ItemCategory? _selectedCategory; // null means all
  String _searchQuery = '';

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
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ItemModel> _filtered(List<ItemModel> source) {
    // First apply category filter
    var list = _selectedCategory == null ? source : source.where((e) => e.category == _selectedCategory).toList();
    // Then apply search filter if any
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((e) {
      final title = e.title.toLowerCase();
      final cat = _categoryLabel(e.category).toLowerCase();
      return title.contains(q) || cat.contains(q);
    }).toList();
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _toggleBookmark(BuildContext context, ItemModel item) => context.read<ItemStore>().toggleBookmark(item.id);

  void _onSearchChanged(String value, {bool immediate = false}) {
    _debounce?.cancel();
    if (immediate) {
      setState(() => _searchQuery = value);
      _scrollToTop();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = value);
      _scrollToTop();
    });
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
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
    final store = context.watch<ItemStore>();
    final visibleItems = _filtered(store.items);

    return Scaffold(
      appBar: AppBar(
        title: Text('Passage', style: Theme.of(context).textTheme.titleLarge?.semiBold),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _searchFocusNode.requestFocus()),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/login')),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (v) {
              setState(() {}); // Update clear icon visibility immediately
              _onSearchChanged(v);
            },
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: colors.onSurfaceVariant),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('', immediate: true);
                      },
                    )
                  : null,
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: BorderSide.none),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
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
