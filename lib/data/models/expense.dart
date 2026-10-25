import 'package:flutter/foundation.dart';

import 'category.dart';

/// One logged expense. Money is in kobo (100 kobo = ₦1).
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amountKobo,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int amountKobo;
  final ExpenseCategory category;

  /// When the money was spent (a UTC instant).
  final DateTime date;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is Expense &&
      other.id == id &&
      other.title == title &&
      other.amountKobo == amountKobo &&
      other.category == category &&
      other.date == date &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, title, amountKobo, category, date, createdAt);
}

/// What the Add expense form produces; the repository assigns the id.
@immutable
class NewExpense {
  const NewExpense({
    required this.title,
    required this.amountKobo,
    required this.category,
    required this.date,
  });

  final String title;
  final int amountKobo;
  final ExpenseCategory category;
  final DateTime date;
}
