import 'package:flutter/material.dart';
import 'package:passage/models/conversation_model.dart';
import 'package:passage/theme.dart';

/// A single conversation preview tile for the Messages inbox
class ConversationCard extends StatelessWidget {
  const ConversationCard({super.key, required this.conversation, this.onTap});
  final ConversationModel conversation;
  final VoidCallback? onTap;

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    // Fallback to date MM/DD
    return '${dt.month}/${dt.day}';
    }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final item = conversation.item;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Avatar
          CircleAvatar(
            backgroundColor: item.avatarColor,
            radius: 22,
            child: Text(item.initials, style: text.labelLarge?.copyWith(color: Colors.white)),
          ),
          const SizedBox(width: AppSpacing.md),
          // Texts
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(conversation.sellerName, style: text.titleMedium?.semiBold, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: AppSpacing.sm),
                Text(_formatTimestamp(conversation.updatedAt), style: text.labelSmall?.withColor(colors.onSurfaceVariant)),
              ]),
              const SizedBox(height: 2),
              Text(item.title, style: text.labelMedium?.withColor(colors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  child: Text(
                    conversation.lastMessage,
                    style: text.bodyMedium?.withColor(colors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (conversation.hasUnread) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                  ),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
