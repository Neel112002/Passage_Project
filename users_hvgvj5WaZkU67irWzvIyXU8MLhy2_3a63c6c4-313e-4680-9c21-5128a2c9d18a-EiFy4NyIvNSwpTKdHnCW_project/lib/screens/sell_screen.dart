import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/services/item_service.dart';
import 'package:passage/theme.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key, this.onPosted});

  final VoidCallback? onPosted;

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  ItemCategory? _category;
  ItemCondition _condition = ItemCondition.used;
  bool _hasImage = false; // Placeholder flag only
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Post Listing', style: text.titleLarge?.semiBold)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImagePickerPlaceholder(hasImage: _hasImage, onTap: () => setState(() => _hasImage = !_hasImage)),
                const SizedBox(height: AppSpacing.lg),
                Text('Title', style: text.labelLarge?.medium.withColor(colors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(hintText: 'e.g. IKEA Desk, Calculus Book'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Description', style: text.labelLarge?.medium.withColor(colors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(hintText: 'Add details like condition, pickup, etc.'),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  Expanded(child: _buildPriceField(context)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildCategoryField(context)),
                ]),
                const SizedBox(height: AppSpacing.md),
                Text('Condition', style: text.labelLarge?.medium.withColor(colors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                SegmentedButton<ItemCondition>(
                  segments: const [
                    ButtonSegment(value: ItemCondition.brandNew, label: Text('New'), icon: Icon(Icons.auto_awesome)),
                    ButtonSegment(value: ItemCondition.used, label: Text('Used'), icon: Icon(Icons.handyman_outlined)),
                  ],
                  selected: {_condition},
                  onSelectionChanged: (s) => setState(() => _condition = s.first),
                  showSelectedIcon: false,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_submitting ? 'Posting…' : 'Post Listing'),
                    onPressed: _submitting ? null : _onSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField(BuildContext context) {
    return TextFormField(
      controller: _priceCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+\.?[0-9]{0,2}')),
      ],
      decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Price'),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Price is required';
        final parsed = double.tryParse(v);
        if (parsed == null) return 'Enter a valid number';
        if (parsed <= 0) return 'Price must be greater than 0';
        return null;
      },
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    final items = const [
      DropdownMenuItem(value: ItemCategory.textbooks, child: Text('Textbooks')),
      DropdownMenuItem(value: ItemCategory.furniture, child: Text('Furniture')),
      DropdownMenuItem(value: ItemCategory.electronics, child: Text('Electronics')),
      DropdownMenuItem(value: ItemCategory.bikes, child: Text('Bikes')),
      DropdownMenuItem(value: ItemCategory.clothing, child: Text('Clothing')),
      DropdownMenuItem(value: ItemCategory.sublets, child: Text('Sublets')),
    ];
    return DropdownButtonFormField<ItemCategory>(
      value: _category,
      items: items,
      decoration: const InputDecoration(hintText: 'Category'),
      onChanged: (v) => setState(() => _category = v),
      validator: (v) => v == null ? 'Select a category' : null,
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final priceVal = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      final item = ItemModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        sellerName: 'You',
        university: 'Your Campus',
        price: double.parse(priceVal.toStringAsFixed(2)),
        condition: _condition,
        category: _category!,
        imageUrl: null,
      );
      ItemService.instance.addItemAtTop(item);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing posted')));
        widget.onPosted?.call();
      }
    } catch (e) {
      debugPrint('Failed to post listing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _ImagePickerPlaceholder extends StatelessWidget {
  const _ImagePickerPlaceholder({required this.hasImage, required this.onTap});
  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasImage ? colors.secondaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(hasImage ? Icons.photo_library_rounded : Icons.add_a_photo_rounded,
                  color: hasImage ? colors.onSecondaryContainer : colors.onSurfaceVariant, size: 40),
              const SizedBox(height: AppSpacing.xs),
              Text(hasImage ? 'Photo added (placeholder)' : 'Tap to add photo',
                  style: text.labelLarge?.withColor(colors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
