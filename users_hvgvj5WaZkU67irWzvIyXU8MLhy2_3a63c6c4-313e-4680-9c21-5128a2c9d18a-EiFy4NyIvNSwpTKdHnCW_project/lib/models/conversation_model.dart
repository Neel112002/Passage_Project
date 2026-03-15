// import 'package:flutter/material.dart';
import 'package:passage/models/item_model.dart';

/// Conversation model representing a chat thread between buyer and seller
class ConversationModel {
  final String id;
  final ItemModel item; // The item being discussed
  final String sellerName; // Redundant but handy for quick access
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.item,
    required this.sellerName,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  bool get hasUnread => unreadCount > 0;

  ConversationModel copyWith({
    String? id,
    ItemModel? item,
    String? sellerName,
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) => ConversationModel(
        id: id ?? this.id,
        item: item ?? this.item,
        sellerName: sellerName ?? this.sellerName,
        lastMessage: lastMessage ?? this.lastMessage,
        updatedAt: updatedAt ?? this.updatedAt,
        unreadCount: unreadCount ?? this.unreadCount,
      );

  /// Generate mock conversations based on generated items
  static List<ConversationModel> generateSamples({int count = 12}) {
    final items = ItemModel.generateSamples(startIndex: 1000, count: count);
    final now = DateTime.now();
    final messages = [
      'Is this still available?',
      'Can you do a lower price?',
      'Where can we meet on campus?',
      'Looks great! When are you free?',
      'Can you share more photos?',
      'Is it compatible with Mac?',
      'Any scratches or issues?',
      'I can pick it up today.',
      'Sounds good. Thanks!',
      'What is your final price?',
    ];

    return List.generate(count, (i) {
      final item = items[i];
      final msg = messages[i % messages.length];
      final updated = now.subtract(Duration(minutes: (i + 1) * 7));
      final unread = i % 3 == 0 ? 1 : 0; // some unread
      return ConversationModel(
        id: 'conv_${item.id}',
        item: item,
        sellerName: item.sellerName,
        lastMessage: msg,
        updatedAt: updated,
        unreadCount: unread,
      );
    });
  }
}
