import 'package:flutter/material.dart';

enum CategoryType {
  expense,
  income,
  both;

  String get displayName {
    switch (this) {
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.income:
        return 'Income';
      case CategoryType.both:
        return 'Both';
    }
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String iconKey;
  final int colorHex;
  final CategoryType type;
  final bool isDefault;
  final int transactionCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    this.type = CategoryType.both,
    this.isDefault = false,
    this.transactionCount = 0,
  });

  Color get color => Color(colorHex);

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorHex,
    CategoryType? type,
    bool? isDefault,
    int? transactionCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKey,
      'colorHex': colorHex,
      'type': type.name,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {int transactionCount = 0}) {
    CategoryType catType = CategoryType.both;
    final typeStr = map['type'] as String?;
    if (typeStr == 'expense') {
      catType = CategoryType.expense;
    } else if (typeStr == 'income') {
      catType = CategoryType.income;
    }

    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconKey: map['iconKey'] as String? ?? 'category',
      colorHex: (map['colorHex'] as int?) ?? 0xFF3B82F6,
      type: catType,
      isDefault: (map['isDefault'] as int?) == 1,
      transactionCount: transactionCount,
    );
  }

  /// Maps iconKey string to Material Icons
  static IconData getIconData(String key) {
    switch (key) {
      case 'construction':
        return Icons.foundation_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'rent':
        return Icons.home_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'entertainment':
        return Icons.sports_esports_rounded;
      case 'client':
        return Icons.call_made_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'freelance':
        return Icons.laptop_mac_rounded;
      case 'other':
      default:
        return Icons.more_horiz_rounded;
    }
  }

  /// Default categories matching reference screenshot
  static List<CategoryModel> get defaultCategories => const [
    CategoryModel(
      id: 'construction',
      name: 'Construction',
      iconKey: 'construction',
      colorHex: 0xFFEF4444, // Coral Red
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'food',
      name: 'Food',
      iconKey: 'food',
      colorHex: 0xFFF59E0B, // Amber
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      iconKey: 'shopping',
      colorHex: 0xFFEC4899, // Pink
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'rent',
      name: 'Rent',
      iconKey: 'rent',
      colorHex: 0xFF8B5CF6, // Purple
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      iconKey: 'transport',
      colorHex: 0xFF3B82F6, // Blue
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills',
      iconKey: 'bills',
      colorHex: 0xFF6366F1, // Indigo
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'business',
      name: 'Business',
      iconKey: 'business',
      colorHex: 0xFF14B8A6, // Teal
      type: CategoryType.both,
      isDefault: true,
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      iconKey: 'education',
      colorHex: 0xFF06B6D4, // Cyan
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'health',
      name: 'Health',
      iconKey: 'health',
      colorHex: 0xFFF43F5E, // Rose
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      iconKey: 'entertainment',
      colorHex: 0xFFA855F7, // Violet
      type: CategoryType.expense,
      isDefault: true,
    ),
    CategoryModel(
      id: 'client_payment',
      name: 'Client Payment',
      iconKey: 'client',
      colorHex: 0xFF10B981, // Emerald Green
      type: CategoryType.income,
      isDefault: true,
    ),
    CategoryModel(
      id: 'salary',
      name: 'Salary',
      iconKey: 'salary',
      colorHex: 0xFF059669, // Dark Green
      type: CategoryType.income,
      isDefault: true,
    ),
    CategoryModel(
      id: 'investment',
      name: 'Investment',
      iconKey: 'investment',
      colorHex: 0xFF3B82F6, // Blue
      type: CategoryType.income,
      isDefault: true,
    ),
    CategoryModel(
      id: 'other',
      name: 'Other',
      iconKey: 'other',
      colorHex: 0xFF64748B, // Slate Gray
      type: CategoryType.both,
      isDefault: true,
    ),
  ];
}
