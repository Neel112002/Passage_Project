import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalSavedReelsStore {
  static const String _key = 'saved_reels_v1';

  // Live saved reels set notifier
  static final ValueNotifier<Set<String>> savedReelsNotifier =
      ValueNotifier<Set<String>>({});

  // Call once on app start to populate initial saved reels
  static Future<void> bootstrap() async {
    final saved = await loadAll();
    savedReelsNotifier.value = saved;
  }

  static Future<Set<String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return {};
    try {
      final list = jsonDecode(s) as List<dynamic>;
      return list.cast<String>().toSet();
    } catch (e) {
      debugPrint('Error loading saved reels: $e');
      return {};
    }
  }

  static Future<void> saveAll(Set<String> reelIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(reelIds.toList()));
    savedReelsNotifier.value = reelIds;
  }

  static Future<void> add(String reelId) async {
    final saved = await loadAll();
    saved.add(reelId);
    await saveAll(saved);
  }

  static Future<void> remove(String reelId) async {
    final saved = await loadAll();
    saved.remove(reelId);
    await saveAll(saved);
  }

  static Future<void> toggle(String reelId) async {
    final saved = await loadAll();
    if (saved.contains(reelId)) {
      saved.remove(reelId);
    } else {
      saved.add(reelId);
    }
    await saveAll(saved);
  }

  static Future<bool> isSaved(String reelId) async {
    final saved = await loadAll();
    return saved.contains(reelId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    savedReelsNotifier.value = {};
  }
}
