import 'dart:math';

import 'package:flutter/material.dart';

/// Categories for marketplace items
enum ItemCategory { textbooks, furniture, electronics, bikes, clothing, sublets }

/// Condition states for items
enum ItemCondition { brandNew, used }

/// Marketplace item model for the Passage app
class ItemModel {
  final String id;
  final String title;
  final String sellerName;
  final String university;
  final double price;
  final ItemCondition condition;
  final ItemCategory category;
  final String? imageUrl; // Optional; we use a placeholder in UI
  final Color avatarColor; // Deterministic color based on seller
  final bool isBookmarked;

  const ItemModel({
    required this.id,
    required this.title,
    required this.sellerName,
    required this.university,
    required this.price,
    required this.condition,
    required this.category,
    this.imageUrl,
    this.avatarColor = const Color(0xFF5C6B7A),
    this.isBookmarked = false,
  });

  ItemModel copyWith({
    String? id,
    String? title,
    String? sellerName,
    String? university,
    double? price,
    ItemCondition? condition,
    ItemCategory? category,
    String? imageUrl,
    Color? avatarColor,
    bool? isBookmarked,
  }) => ItemModel(
        id: id ?? this.id,
        title: title ?? this.title,
        sellerName: sellerName ?? this.sellerName,
        university: university ?? this.university,
        price: price ?? this.price,
        condition: condition ?? this.condition,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        avatarColor: avatarColor ?? this.avatarColor,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  String get displayPrice => '\$${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  String get initials {
    final parts = sellerName.trim().split(RegExp(r"\s+"));
    final first = parts.isNotEmpty ? parts.first.characters.first : '';
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  String get conditionLabel => condition == ItemCondition.brandNew ? 'New' : 'Used';

  /// Generates deterministic soft colors from a string seed
  static Color _colorFromSeed(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (prev, e) => prev + e);
    final rand = Random(hash);
    final h = rand.nextDouble() * 360; // hue
    final s = 0.35 + rand.nextDouble() * 0.25; // 0.35..0.60
    final l = 0.55 + rand.nextDouble() * 0.15; // 0.55..0.70
    return HSLColor.fromAHSL(1, h, s, l).toColor();
  }

  /// Generate a list of sample items for mock data
  static List<ItemModel> generateSamples({required int startIndex, required int count, ItemCategory? category}) {
    final rand = Random(startIndex + 42);
    final universities = [
      'Stanford',
      'MIT',
      'Berkeley',
      'UCLA',
      'Harvard',
      'UT Austin',
      'CMU',
      'Columbia',
      'NYU',
      'UW Madison',
    ];

    final titlesByCategory = {
      ItemCategory.textbooks: ['Calculus I', 'Organic Chemistry', 'Intro to CS', 'Linear Algebra', 'Physics 101'],
      ItemCategory.furniture: ['IKEA Desk', 'Ergo Chair', 'Bookshelf', 'Nightstand', 'Lamp'],
      ItemCategory.electronics: ['Mechanical Keyboard', 'Monitor 27"', 'AirPods', 'Raspberry Pi 5', 'SSD 1TB'],
      ItemCategory.bikes: ['Road Bike', 'Mountain Bike', 'Hybrid Bike', 'Fixie', 'Folding Bike'],
      ItemCategory.clothing: ['Hoodie', 'Winter Jacket', 'Sneakers', 'Backpack', 'Jeans'],
      ItemCategory.sublets: ['Studio Sublet', 'Shared Room', '1BR Sublet', 'Summer Sublet', 'Downtown Room'],
    };

    final sellers = [
      'Alex Chen',
      'Priya Singh',
      'Jordan Lee',
      'Maria Garcia',
      'Sam Thompson',
      'Nina Patel',
      'Ethan Brown',
      'Ava Wilson',
      'Leo Martinez',
      'Sofia Rossi',
    ];

    ItemCategory pickCategory() => category ?? ItemCategory.values[rand.nextInt(ItemCategory.values.length)];

    return List.generate(count, (i) {
      final idx = startIndex + i;
      final cat = pickCategory();
      final titlePool = titlesByCategory[cat]!;
      final title = '${titlePool[rand.nextInt(titlePool.length)]} #${100 + idx}';
      final seller = sellers[rand.nextInt(sellers.length)];
      final university = universities[rand.nextInt(universities.length)];
      final price = switch (cat) {
        ItemCategory.textbooks => 10 + rand.nextInt(90) + rand.nextDouble(),
        ItemCategory.furniture => 30 + rand.nextInt(170) + rand.nextDouble(),
        ItemCategory.electronics => 20 + rand.nextInt(300) + rand.nextDouble(),
        ItemCategory.bikes => 60 + rand.nextInt(340) + rand.nextDouble(),
        ItemCategory.clothing => 8 + rand.nextInt(70) + rand.nextDouble(),
        ItemCategory.sublets => 600 + rand.nextInt(1200) + rand.nextDouble(),
      };
      final cond = rand.nextBool() ? ItemCondition.brandNew : ItemCondition.used;
      final seedColor = _colorFromSeed(seller);

      return ItemModel(
        id: 'item_$idx',
        title: title,
        sellerName: seller,
        university: university,
        price: double.parse(price.toStringAsFixed(2)),
        condition: cond,
        category: cat,
        imageUrl: null,
        avatarColor: seedColor,
        isBookmarked: false,
      );
    });
  }
}
