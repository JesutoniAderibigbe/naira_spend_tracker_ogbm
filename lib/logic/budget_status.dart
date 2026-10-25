import 'package:flutter/foundation.dart';

import '../data/models/category.dart';
import 'money.dart';

/// Rules from docs/SPEC.md: under 80% fine, 80–99% near, exactly 100% at
/// limit, above 100% over.
enum BudgetStatus {
  fine,
  near,
  atLimit,
  over;

  static BudgetStatus of({required int spentKobo, required int limitKobo}) {
    if (spentKobo > limitKobo) return over;
    if (spentKobo == limitKobo) return atLimit;
    // Integer maths so 79.99% never rounds up to 80%.
    if (spentKobo * 100 >= limitKobo * 80) return near;
    return fine;
  }
}

/// One category's spending against its monthly limit.
@immutable
class BudgetProgress {
  const BudgetProgress({
    required this.category,
    required this.spentKobo,
    required this.limitKobo,
  });

  final ExpenseCategory category;
  final int spentKobo;
  final int limitKobo;

  BudgetStatus get status =>
      BudgetStatus.of(spentKobo: spentKobo, limitKobo: limitKobo);

  /// 0 to 1, for the progress bar.
  double get fraction =>
      limitKobo <= 0 ? 1 : (spentKobo / limitKobo).clamp(0.0, 1.0);

  /// Status in words, so it is never shown by colour alone.
  String get statusText => switch (status) {
    BudgetStatus.fine => '${formatNaira(limitKobo - spentKobo)} left',
    BudgetStatus.near =>
      'Near limit · ${formatNaira(limitKobo - spentKobo)} left',
    BudgetStatus.atLimit => 'At limit',
    BudgetStatus.over => 'Over by ${formatNaira(spentKobo - limitKobo)}',
  };
}
