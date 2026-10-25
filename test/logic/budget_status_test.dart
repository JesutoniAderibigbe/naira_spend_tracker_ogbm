import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/data/models/category.dart';
import 'package:naira_spend_tracker_ogbm/logic/budget_status.dart';

BudgetProgress progress(int spentKobo, int limitKobo) => BudgetProgress(
  category: ExpenseCategory.fun,
  spentKobo: spentKobo,
  limitKobo: limitKobo,
);

void main() {
  const limit = 1000000; // ₦10,000

  test('thresholds follow the spec', () {
    expect(progress(0, limit).status, BudgetStatus.fine);
    expect(progress(799999, limit).status, BudgetStatus.fine); // 79.9999%
    expect(progress(800000, limit).status, BudgetStatus.near); // 80%
    expect(progress(999999, limit).status, BudgetStatus.near); // 99.9999%
    expect(progress(limit, limit).status, BudgetStatus.atLimit);
    expect(progress(limit + 1, limit).status, BudgetStatus.over);
  });

  test('status is always written in words', () {
    expect(progress(700000, limit).statusText, '₦3,000 left');
    expect(progress(850000, limit).statusText, 'Near limit · ₦1,500 left');
    expect(progress(limit, limit).statusText, 'At limit');
    expect(progress(1200000, limit).statusText, 'Over by ₦2,000');
  });

  test('bar fraction is clamped to 0..1', () {
    expect(progress(500000, limit).fraction, 0.5);
    expect(progress(3000000, limit).fraction, 1.0);
  });
}
