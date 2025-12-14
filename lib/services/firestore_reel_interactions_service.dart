import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:passage/models/reel_comment.dart';
import 'package:passage/services/firebase_auth_service.dart';

class FirestoreReelInteractionsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== LIKES ==========

  /// Toggle like on a reel
  static Future<void> toggleLike(String reelId) async {
    final userId = FirebaseAuthService.currentUserId;
    if (userId == null) return;

    try {
      final likeRef = _firestore
          .collection('reels')
          .doc(reelId)
          .collection('likes')
          .doc(userId);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        // Unlike
        await likeRef.delete();
      } else {
        // Like
        await likeRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  /// Check if current user liked a reel
  static Future<bool> isLiked(String reelId) async {
    final userId = FirebaseAuthService.currentUserId;
    if (userId == null) return false;

    try {
      final likeDoc = await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('likes')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      debugPrint('Error checking like: $e');
      return false;
    }
  }

  /// Get like count for a reel
  static Future<int> getLikeCount(String reelId) async {
    try {
      final likesSnapshot = await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('likes')
          .count()
          .get();
      return likesSnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting like count: $e');
      return 0;
    }
  }

  /// Watch if current user liked a reel (real-time)
  static Stream<bool> watchIsLiked(String reelId) {
    final userId = FirebaseAuthService.currentUserId;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('reels')
        .doc(reelId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Watch like count for a reel (real-time)
  static Stream<int> watchLikeCount(String reelId) {
    return _firestore
        .collection('reels')
        .doc(reelId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ========== COMMENTS ==========

  /// Add a comment to a reel
  static Future<void> addComment({
    required String reelId,
    required String text,
    required String userName,
    required String userAvatarUrl,
  }) async {
    final userId = FirebaseAuthService.currentUserId;
    if (userId == null) return;

    try {
      final commentRef = _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc();

      final comment = ReelComment(
        id: commentRef.id,
        reelId: reelId,
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        text: text,
        createdAt: DateTime.now(),
      );

      await commentRef.set(comment.toMap());
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  /// Delete a comment
  static Future<void> deleteComment({
    required String reelId,
    required String commentId,
  }) async {
    try {
      await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      rethrow;
    }
  }

  /// Get comments for a reel
  static Future<List<ReelComment>> getComments(String reelId) async {
    try {
      final snapshot = await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReelComment.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting comments: $e');
      return [];
    }
  }

  /// Get comment count for a reel
  static Future<int> getCommentCount(String reelId) async {
    try {
      final commentsSnapshot = await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .count()
          .get();
      return commentsSnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting comment count: $e');
      return 0;
    }
  }

  /// Watch comments for a reel (real-time)
  static Stream<List<ReelComment>> watchComments(String reelId) {
    return _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReelComment.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Watch comment count for a reel (real-time)
  static Stream<int> watchCommentCount(String reelId) {
    return _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
