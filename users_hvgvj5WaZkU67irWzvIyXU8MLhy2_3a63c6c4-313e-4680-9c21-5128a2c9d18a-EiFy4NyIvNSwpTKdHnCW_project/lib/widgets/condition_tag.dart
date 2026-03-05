import 'package:flutter/material.dart';
import 'package:passage/models/item_model.dart';
import 'package:passage/theme.dart';

/// Public reusable condition tag used across cards and detail screens
class ConditionTag extends StatelessWidget {
  const ConditionTag({super.key, required this.condition});
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
