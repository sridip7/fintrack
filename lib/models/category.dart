import 'package:flutter/material.dart';

enum TransactionCategory {
  food,
  travel,
  shopping,
  bills,
  entertainment,
  others,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.travel:
        return 'Travel & Transport';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.bills:
        return 'Bills & Utilities';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.travel:
        return Icons.directions_car;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.bills:
        return Icons.receipt_long;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.others:
        return Icons.miscellaneous_services;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return const Color(0xFFFF9F43); // Orange
      case TransactionCategory.travel:
        return const Color(0xFF00D2D3); // Cyan
      case TransactionCategory.shopping:
        return const Color(0xFFEA2027); // Red
      case TransactionCategory.bills:
        return const Color(0xFF5758BB); // Purple
      case TransactionCategory.entertainment:
        return const Color(0xFFED4C67); // Pink
      case TransactionCategory.others:
        return const Color(0xFF8395A7); // Slate gray
    }
  }
}
