import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passage/models/reel.dart';

class FirestoreReelsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _reelsRef = _firestore.collection('reels');

  // Get all active reels ordered by createdAt desc
  static Future<List<ReelModel>> loadAll() async {
    try {
      final snapshot = await _reelsRef
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs
          .map((doc) => ReelModel.fromMap(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      return <ReelModel>[];
    }
  }

  // Create or update reel
  static Future<void> upsert(ReelModel reel) async {
    try {
      final data = reel.toMap();
      await _reelsRef.doc(reel.id).set(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete reel
  static Future<void> remove(String id) async {
    try {
      await _reelsRef.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Listen to reel changes (real-time)
  static Stream<List<ReelModel>> watchAll() {
    return _reelsRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReelModel.fromMap(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  // Watch reels by seller
  static Stream<List<ReelModel>> watchBySeller(String sellerId) {
    return _reelsRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReelModel.fromMap(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }
}
