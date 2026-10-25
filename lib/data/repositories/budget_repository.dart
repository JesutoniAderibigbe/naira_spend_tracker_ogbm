import '../models/category.dart';

/// Monthly limits (in kobo) for one signed-in user.
abstract interface class BudgetRepository {
  /// Categories without a limit are absent from the map.
  Stream<Map<ExpenseCategory, int>> watchLimits();

  /// Sets the limit, or removes it when [limitKobo] is null or not positive.
  Future<void> setLimit(ExpenseCategory category, int? limitKobo);
}
