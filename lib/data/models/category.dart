/// Spending categories. [id] is the value stored in Firestore.
enum ExpenseCategory {
  food('food', 'Food'),
  transport('transport', 'Transport'),
  data('data', 'Data'),
  bills('bills', 'Bills'),
  fun('fun', 'Fun'),
  other('other', 'Other');

  const ExpenseCategory(this.id, this.label);

  final String id;
  final String label;

  /// Unknown ids fall back to [other] so one bad document can't break a list.
  static ExpenseCategory fromId(String? id) =>
      values.firstWhere((c) => c.id == id, orElse: () => other);
}
