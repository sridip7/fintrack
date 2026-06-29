import 'category.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final TransactionType type;
  final bool isEdited;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.isEdited = false,
  });

  // Convert Transaction to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'type': type.name,
      'isEdited': isEdited,
    };
  }

  // Create Transaction from a JSON Map
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TransactionCategory.others,
      ),
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      isEdited: json['isEdited'] == true,
    );
  }

  // Create a copy of the transaction with modified fields (useful for updates/tests)
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionCategory? category,
    TransactionType? type,
    bool? isEdited,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
