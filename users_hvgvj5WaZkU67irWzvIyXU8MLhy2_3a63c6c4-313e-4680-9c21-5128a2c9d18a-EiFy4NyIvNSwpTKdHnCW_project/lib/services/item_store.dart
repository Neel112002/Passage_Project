import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:passage/models/item_model.dart';

/// Shared in-memory store for marketplace listings.
/// Uses ChangeNotifier to update all listening screens.
class ItemStore extends ChangeNotifier {
  ItemStore() {
    // Seed with initial mock data
    _items = ItemModel.generateSamples(startIndex: 0, count: 16)
        .map((e) => e.copyWith(
              // Ensure createdAt desc ordering feels natural
              // (newer first; samples will be in ascending index)
              // We'll just assign now for simplicity.
            ))
        .toList();
  }

  late List<ItemModel> _items;

  List<ItemModel> get items => List.unmodifiable(_items);

  /// Adds an item at the top of the feed and notifies listeners
  void addItem(ItemModel item) {
    _items.insert(0, item);
    notifyListeners();
  }

  /// Returns a copy of all items
  List<ItemModel> getAllItems() => List.unmodifiable(_items);

  /// Returns items that belong to the current user.
  /// For now, the mock current user is "You".
  List<ItemModel> getUserItems() => _items.where((e) => e.sellerName == 'You').toList(growable: false);

  /// Toggles bookmark status for an item by id.
  void toggleBookmark(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(isBookmarked: !_items[idx].isBookmarked);
    notifyListeners();
  }
}
