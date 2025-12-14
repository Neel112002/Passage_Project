import 'package:cloud_firestore/cloud_firestore.dart';

class ReelComment {
  final String id;
  final String reelId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String text;
  final DateTime createdAt;

  const ReelComment({
    required this.id,
    required this.reelId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.text,
    required this.createdAt,
  });

  ReelComment copyWith({
    String? id,
    String? reelId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? text,
    DateTime? createdAt,
  }) =>
      ReelComment(
        id: id ?? this.id,
        reelId: reelId ?? this.reelId,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
        text: text ?? this.text,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'reelId': reelId,
        'userId': userId,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'text': text,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static ReelComment fromMap(Map<String, dynamic> map) {
    final createdAt = map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : (map['createdAt'] is String
                ? DateTime.tryParse(map['createdAt'] as String)
                : null) ??
            DateTime.now();

    return ReelComment(
      id: (map['id'] ?? '') as String,
      reelId: (map['reelId'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      userAvatarUrl: (map['userAvatarUrl'] ?? '') as String,
      text: (map['text'] ?? '') as String,
      createdAt: createdAt,
    );
  }
}
