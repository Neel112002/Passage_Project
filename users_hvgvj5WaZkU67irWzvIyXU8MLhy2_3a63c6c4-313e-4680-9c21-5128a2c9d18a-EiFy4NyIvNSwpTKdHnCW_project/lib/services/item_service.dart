import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:passage/models/item_model.dart';

/// In-memory data source for marketplace items.
/// Temporary local state until backend integration.
class ItemService extends ChangeNotifier {
  ItemService._internal() {
    // Seed with initial mock data
    _items = ItemModel.generateSamples(startIndex: 0, count: 12);
  }
  static final ItemService instance = ItemService._internal();

  late List<ItemModel> _items;

  List<ItemModel> get items => List.unmodifiable(_items);

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _items = ItemModel.generateSamples(startIndex: 0, count: 14);
    notifyListeners();
  }

  Future<List<ItemModel>> loadMore({int count = 10}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final start = _items.length;
    final more = ItemModel.generateSamples(startIndex: start, count: count);
    _items.addAll(more);
    notifyListeners();
    return more;
  }

  void addItemAtTop(ItemModel item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void toggleBookmark(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(isBookmarked: !_items[idx].isBookmarked);
      notifyListeners();
    }
  }
}
