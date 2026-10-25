import '../models/expense.dart';

/// Expenses for one signed-in user.
abstract interface class ExpenseRepository {
  /// Expenses dated on or after [since], newest first.
  Stream<List<Expense>> watchSince(DateTime since);

  /// Adds an expense and returns its id.
  Future<String> add(NewExpense expense, {required DateTime createdAt});

  /// Writes [expense] back with its original id (used for undo).
  Future<void> restore(Expense expense);

  Future<void> delete(String id);
}
