import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final String productId;
  final String sellerId;
  final String buyerId;
  // Stored as 'participants' historically; new schema uses 'members'.
  final List<String> participants; // [buyerId, sellerId]
  final String lastMessage;
  // Stored as 'lastAt' historically; new schema uses 'updatedAt'.
  final DateTime lastAt;
  final String productName;
  final String productImageUrl;
  // Unread counts per user: { userId: count }
  final Map<String, int> unreadCounts;

  const ChatConversation({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.buyerId,
    required this.participants,
    required this.lastMessage,
    required this.lastAt,
    required this.productName,
    required this.productImageUrl,
    this.unreadCounts = const {},
  });

  ChatConversation copyWith({
    String? lastMessage,
    DateTime? lastAt,
    Map<String, int>? unreadCounts,
  }) => ChatConversation(
        id: id,
        productId: productId,
        sellerId: sellerId,
        buyerId: buyerId,
        participants: participants,
        lastMessage: lastMessage ?? this.lastMessage,
        lastAt: lastAt ?? this.lastAt,
        productName: productName,
        productImageUrl: productImageUrl,
        unreadCounts: unreadCounts ?? this.unreadCounts,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'sellerId': sellerId,
        'buyerId': buyerId,
        // Write under the new schema while keeping backward compatibility in reads.
        'members': participants,
        'lastMessage': lastMessage,
        'updatedAt': Timestamp.fromDate(lastAt),
        'productName': productName,
        'productImageUrl': productImageUrl,
        if (unreadCounts.isNotEmpty) 'unreadCounts': unreadCounts,
      };

  static ChatConversation fromMap(Map<String, dynamic> map) {
    final ts = map['updatedAt'] ?? map['lastAt'];
    final lastAt = ts is Timestamp
        ? ts.toDate()
        : (ts is String ? DateTime.tryParse(ts) : null) ?? DateTime.now();
    final partsRaw = (map['members'] ?? map['participants']) as List?;
    final parts = partsRaw?.whereType<String>().toList() ?? const <String>[];
    // Parse unreadCounts map
    final unreadRaw = map['unreadCounts'];
    final unreadCounts = <String, int>{};
    if (unreadRaw is Map) {
      unreadRaw.forEach((k, v) {
        if (k is String && v is int) {
          unreadCounts[k] = v;
        }
      });
    }
    return ChatConversation(
      id: (map['id'] ?? '') as String,
      productId: (map['productId'] ?? '') as String,
      sellerId: (map['sellerId'] ?? '') as String,
      buyerId: (map['buyerId'] ?? '') as String,
      participants: parts,
      lastMessage: (map['lastMessage'] ?? '') as String,
      lastAt: lastAt,
      productName: (map['productName'] ?? '') as String,
      productImageUrl: (map['productImageUrl'] ?? '') as String,
      unreadCounts: unreadCounts,
    );
  }

  /// Get unread count for a specific user
  int getUnreadFor(String userId) => unreadCounts[userId] ?? 0;
}
