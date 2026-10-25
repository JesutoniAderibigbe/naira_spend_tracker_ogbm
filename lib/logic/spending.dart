/// Pure calculations behind Home, Budgets and Insights.
library;

import 'package:flutter/foundation.dart';

import '../data/models/category.dart';
import '../data/models/expense.dart';
import 'budget_status.dart';
import 'lagos_time.dart';

@immutable
class DaySpend {
  const DaySpend(this.day, this.totalKobo);

  final LagosDay day;
  final int totalKobo;
}

@immutable
class WeekSummary {
  const WeekSummary(this.days);

  /// The last 7 Lagos days, oldest first; the last one is today.
  final List<DaySpend> days;

  int get totalKobo => days.fold(0, (sum, d) => sum + d.totalKobo);

  /// Rounded to the nearest kobo.
  int get dailyAverageKobo => (totalKobo / days.length).round();

  /// The day with the most spending, or null when nothing was spent.
  int? get peakIndex {
    if (totalKobo == 0) return null;
    var peak = 0;
    for (var i = 1; i < days.length; i++) {
      if (days[i].totalKobo > days[peak].totalKobo) peak = i;
    }
    return peak;
  }
}

WeekSummary summarizeWeek(List<Expense> expenses, DateTime now) {
  final today = LagosDay.of(now);
  final totals = {for (var i = 6; i >= 0; i--) today.addDays(-i): 0};
  for (final e in expenses) {
    final day = LagosDay.of(e.date);
    if (totals.containsKey(day)) totals[day] = totals[day]! + e.amountKobo;
  }
  return WeekSummary([
    for (final entry in totals.entries) DaySpend(entry.key, entry.value),
  ]);
}

/// Newest first: by date, then by when it was logged.
List<Expense> recentExpenses(List<Expense> expenses, {int limit = 10}) {
  final sorted = [...expenses]
    ..sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
  return sorted.take(limit).toList();
}

enum InsightsPeriod {
  last7Days('7 days', 'Spent in the last 7 days'),
  last30Days('30 days', 'Spent in the last 30 days'),
  thisMonth('This month', 'Spent this month');

  const InsightsPeriod(this.label, this.heading);

  final String label;
  final String heading;

  /// First Lagos day included in the period.
  LagosDay firstDay(DateTime now) {
    final today = LagosDay.of(now);
    return switch (this) {
      last7Days => today.addDays(-6),
      last30Days => today.addDays(-29),
      thisMonth => today.firstOfMonth,
    };
  }
}

@immutable
class CategoryShare {
  const CategoryShare(this.category, this.totalKobo, this.share);

  final ExpenseCategory category;
  final int totalKobo;

  /// 0 to 1 of the period total.
  final double share;
}

@immutable
class PeriodSummary {
  const PeriodSummary({
    required this.totalKobo,
    required this.count,
    required this.byCategory,
    required this.biggest,
  });

  final int totalKobo;
  final int count;

  /// Categories with spending, largest first.
  final List<CategoryShare> byCategory;
  final Expense? biggest;
}

PeriodSummary summarizePeriod(
  List<Expense> expenses,
  InsightsPeriod period,
  DateTime now,
) {
  final from = period.firstDay(now).start;
  final inPeriod = expenses.where((e) => !e.date.isBefore(from)).toList();
  final total = inPeriod.fold(0, (sum, e) => sum + e.amountKobo);

  final totals = <ExpenseCategory, int>{};
  Expense? biggest;
  for (final e in inPeriod) {
    totals[e.category] = (totals[e.category] ?? 0) + e.amountKobo;
    if (biggest == null || e.amountKobo > biggest.amountKobo) biggest = e;
  }
  final byCategory = [
    for (final MapEntry(:key, :value) in totals.entries)
      CategoryShare(key, value, total == 0 ? 0 : value / total),
  ]..sort((a, b) => b.totalKobo.compareTo(a.totalKobo));

  return PeriodSummary(
    totalKobo: total,
    count: inPeriod.length,
    byCategory: byCategory,
    biggest: biggest,
  );
}

/// Budgets for this Lagos month, most used first.
List<BudgetProgress> budgetProgress(
  List<Expense> expenses,
  Map<ExpenseCategory, int> limits,
  DateTime now,
) {
  final from = LagosDay.of(now).firstOfMonth.start;
  final spent = <ExpenseCategory, int>{};
  for (final e in expenses) {
    if (!e.date.isBefore(from)) {
      spent[e.category] = (spent[e.category] ?? 0) + e.amountKobo;
    }
  }
  return [
    for (final MapEntry(:key, :value) in limits.entries)
      BudgetProgress(
        category: key,
        spentKobo: spent[key] ?? 0,
        limitKobo: value,
      ),
  ]..sort(
    (a, b) => (b.spentKobo / b.limitKobo).compareTo(a.spentKobo / a.limitKobo),
  );
}
