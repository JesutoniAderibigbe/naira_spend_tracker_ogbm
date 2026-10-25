import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/data/models/category.dart';
import 'package:naira_spend_tracker_ogbm/logic/budget_status.dart';
import 'package:naira_spend_tracker_ogbm/logic/date_labels.dart';
import 'package:naira_spend_tracker_ogbm/logic/spending.dart';

import '../helpers/fakes.dart';

void main() {
  final expenses = [
    expense('a', 'Jollof rice', 4500, ExpenseCategory.food),
    expense('b', 'Danfo', 1200, ExpenseCategory.transport),
    expense('c', 'Data bundle', 5000, ExpenseCategory.data, daysAgo: 1),
    expense(
      'd',
      'Prepaid electricity',
      20000,
      ExpenseCategory.bills,
      daysAgo: 4,
    ),
    expense('e', 'Cinema', 15100, ExpenseCategory.fun, daysAgo: 6),
    expense('f', 'Old', 9999, ExpenseCategory.other, daysAgo: 7),
    expense('g', 'Last month', 3000, ExpenseCategory.food, daysAgo: 12),
  ];

  group('summarizeWeek', () {
    final week = summarizeWeek(expenses, fixedNow);

    test('covers the last 7 Lagos days ending today', () {
      expect(week.days.map((d) => weekdayShort(d.day)), [
        'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', //
      ]);
    });

    test('totals exclude older expenses', () {
      expect(week.totalKobo, 4580000); // ₦45,800
      expect(week.days.last.totalKobo, 570000);
    });

    test('daily average rounds to the nearest kobo', () {
      expect(week.dailyAverageKobo, 654286); // ₦6,542.857…
    });

    test('peak is the biggest day', () {
      expect(weekdayShort(week.days[week.peakIndex!].day), 'Tue');
      expect(summarizeWeek(const [], fixedNow).peakIndex, isNull);
    });
  });

  test('recentExpenses is newest first', () {
    final ids = recentExpenses(expenses, limit: 3).map((e) => e.id).toList();
    // a and b share a timestamp, so their order is not specified.
    expect(ids.take(2), unorderedEquals(['a', 'b']));
    expect(ids.last, 'c');
  });

  group('summarizePeriod', () {
    test('this month starts on the 1st', () {
      final s = summarizePeriod(expenses, InsightsPeriod.thisMonth, fixedNow);
      expect(s.count, 6);
      expect(s.totalKobo, 5579900);
    });

    test('shares are largest first and the biggest expense is found', () {
      final s = summarizePeriod(expenses, InsightsPeriod.last7Days, fixedNow);
      expect(s.byCategory.first.category, ExpenseCategory.bills);
      expect(s.byCategory.first.share, closeTo(20000 / 45800, 1e-9));
      expect(s.biggest!.id, 'd');
    });

    test('empty period', () {
      final s = summarizePeriod(const [], InsightsPeriod.last30Days, fixedNow);
      expect(s.count, 0);
      expect(s.byCategory, isEmpty);
      expect(s.biggest, isNull);
    });
  });

  test('budgetProgress uses this month only, most used first', () {
    final budgets = budgetProgress(expenses, {
      ExpenseCategory.food: 5000 * 100,
      ExpenseCategory.bills: 18000 * 100,
    }, fixedNow);
    expect(budgets.map((b) => b.category), [
      ExpenseCategory.bills,
      ExpenseCategory.food,
    ]);
    expect(budgets.first.status, BudgetStatus.over);
    // Last month's ₦3,000 food is not counted.
    expect(budgets.last.spentKobo, 4500 * 100);
    expect(budgets.last.status, BudgetStatus.near);
  });
}
