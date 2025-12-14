import 'package:cloud_firestore/cloud_firestore.dart';

class ReelModel {
  final String id; // productId
  final String productId;
  final String sellerId;
  final String videoUrl;
  final String caption; // product name or description
  final String category;
  final bool isActive;
  final DateTime createdAt;

  const ReelModel({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.videoUrl,
    required this.caption,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });

  ReelModel copyWith({
    String? id,
    String? productId,
    String? sellerId,
    String? videoUrl,
    String? caption,
    String? category,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      ReelModel(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        sellerId: sellerId ?? this.sellerId,
        videoUrl: videoUrl ?? this.videoUrl,
        caption: caption ?? this.caption,
        category: category ?? this.category,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'sellerId': sellerId,
        'videoUrl': videoUrl,
        'caption': caption,
        'category': category,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static ReelModel fromMap(Map<String, dynamic> map) {
    final createdAt = map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : (map['createdAt'] is String
                ? DateTime.tryParse(map['createdAt'] as String)
                : null) ??
            DateTime.now();

    return ReelModel(
      id: (map['id'] ?? '') as String,
      productId: (map['productId'] ?? '') as String,
      sellerId: (map['sellerId'] ?? '') as String,
      videoUrl: (map['videoUrl'] ?? '') as String,
      caption: (map['caption'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      isActive: (map['isActive'] as bool?) ?? true,
      createdAt: createdAt,
    );
  }
}
