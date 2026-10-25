import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/category.dart';
import '../data/models/expense.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/expense_repository.dart';
import 'budget_status.dart';
import 'lagos_time.dart';
import 'spending.dart';

/// Expenses and budgets for the signed-in user, and what is derived from
/// them. One instance per user; dispose it on sign out.
class SpendingController extends ChangeNotifier {
  SpendingController({
    required ExpenseRepository expenses,
    required BudgetRepository budgets,
    required Clock clock,
  }) : _expenseRepo = expenses,
       _budgetRepo = budgets,
       _clock = clock {
    // 31 days covers "last 30 days", "this month" and the 7-day chart.
    final since = LagosDay.of(clock()).addDays(-31).start;
    _expenseSub = _expenseRepo.watchSince(since).listen((list) {
      _expenses = list;
      _loadedExpenses = true;
      notifyListeners();
    }, onError: _onStreamError);
    _budgetSub = _budgetRepo.watchLimits().listen((limits) {
      _limits = limits;
      _loadedBudgets = true;
      notifyListeners();
    }, onError: _onStreamError);
  }

  final ExpenseRepository _expenseRepo;
  final BudgetRepository _budgetRepo;
  final Clock _clock;
  late final StreamSubscription<List<Expense>> _expenseSub;
  late final StreamSubscription<Map<ExpenseCategory, int>> _budgetSub;

  List<Expense> _expenses = const [];
  Map<ExpenseCategory, int> _limits = const {};
  bool _loadedExpenses = false;
  bool _loadedBudgets = false;

  DateTime get now => _clock();

  bool get isLoading => !_loadedExpenses || !_loadedBudgets;

  String? _loadError;
  String? get loadError => _loadError;

  /// A failed write, for the UI to show once. See [clearWriteError].
  String? _writeError;
  String? get writeError => _writeError;

  void clearWriteError() => _writeError = null;

  Map<ExpenseCategory, int> get limits => _limits;

  WeekSummary get week => summarizeWeek(_expenses, now);

  List<Expense> get recent => recentExpenses(_expenses);

  List<BudgetProgress> get budgets => budgetProgress(_expenses, _limits, now);

  PeriodSummary summary(InsightsPeriod period) =>
      summarizePeriod(_expenses, period, now);

  // Writes are not awaited by the UI: Firestore applies them to the local
  // cache at once (so the streams update offline) and only completes the
  // future when the server confirms.

  void addExpense(NewExpense expense) =>
      _write(_expenseRepo.add(expense, createdAt: now));

  void deleteExpense(Expense expense) =>
      _write(_expenseRepo.delete(expense.id));

  void restoreExpense(Expense expense) => _write(_expenseRepo.restore(expense));

  void setLimit(ExpenseCategory category, int? limitKobo) =>
      _write(_budgetRepo.setLimit(category, limitKobo));

  void _write(Future<void> future) {
    unawaited(
      future.then(
        (_) {},
        onError: (Object _) {
          _writeError = 'Could not save your change. Try again.';
          notifyListeners();
        },
      ),
    );
  }

  void _onStreamError(Object error) {
    _loadError = 'Could not load your spending. Check your connection.';
    _loadedExpenses = _loadedBudgets = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _expenseSub.cancel();
    _budgetSub.cancel();
    super.dispose();
  }
}
