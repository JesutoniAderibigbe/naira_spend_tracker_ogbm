import 'dart:async';

import 'package:naira_spend_tracker_ogbm/data/models/app_user.dart';
import 'package:naira_spend_tracker_ogbm/data/models/category.dart';
import 'package:naira_spend_tracker_ogbm/data/models/expense.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/auth_repository.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/budget_repository.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/expense_repository.dart';

/// Saturday 10 Oct 2026, 14:00 in Lagos.
final fixedNow = DateTime.utc(2026, 10, 10, 13);
DateTime fixedClock() => fixedNow;

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository([this._user]);

  final _changes = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  /// When set, the next sign-in throws this.
  AuthException? failWith;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> userChanges() => _changes.stream;

  void _set(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Future<void> signInAsGuest() async {
    if (failWith case final e?) throw e;
    _set(const AppUser(uid: 'guest-1', isGuest: true));
  }

  @override
  Future<void> signInWithGoogle() async {
    if (failWith case final e?) throw e;
    // Linking keeps the uid, like Firebase.
    _set(
      AppUser(
        uid: _user?.uid ?? 'google-1',
        isGuest: false,
        displayName: 'Jesutoni Aderibigbe',
      ),
    );
  }

  @override
  Future<void> signOut() async => _set(null);
}

class InMemoryExpenseRepository implements ExpenseRepository {
  InMemoryExpenseRepository([List<Expense> initial = const []])
    : expenses = [...initial];

  final List<Expense> expenses;
  final _changes = StreamController<void>.broadcast();
  var _nextId = 1;

  List<Expense> _since(DateTime since) =>
      expenses.where((e) => !e.date.isBefore(since)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Stream<List<Expense>> watchSince(DateTime since) async* {
    yield _since(since);
    yield* _changes.stream.map((_) => _since(since));
  }

  @override
  Future<String> add(NewExpense e, {required DateTime createdAt}) async {
    final id = 'e${_nextId++}';
    expenses.add(
      Expense(
        id: id,
        title: e.title,
        amountKobo: e.amountKobo,
        category: e.category,
        date: e.date,
        createdAt: createdAt,
      ),
    );
    _changes.add(null);
    return id;
  }

  @override
  Future<void> restore(Expense expense) async {
    expenses.add(expense);
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    expenses.removeWhere((e) => e.id == id);
    _changes.add(null);
  }
}

class InMemoryBudgetRepository implements BudgetRepository {
  InMemoryBudgetRepository([Map<ExpenseCategory, int> initial = const {}])
    : limits = {...initial};

  final Map<ExpenseCategory, int> limits;
  final _changes = StreamController<void>.broadcast();

  @override
  Stream<Map<ExpenseCategory, int>> watchLimits() async* {
    yield {...limits};
    yield* _changes.stream.map((_) => {...limits});
  }

  @override
  Future<void> setLimit(ExpenseCategory category, int? limitKobo) async {
    if (limitKobo == null || limitKobo <= 0) {
      limits.remove(category);
    } else {
      limits[category] = limitKobo;
    }
    _changes.add(null);
  }
}

/// An expense [daysAgo] Lagos days before [fixedNow], at 12:00 Lagos.
Expense expense(
  String id,
  String title,
  int naira,
  ExpenseCategory category, {
  int daysAgo = 0,
}) {
  final date = DateTime.utc(2026, 10, 10 - daysAgo, 11);
  return Expense(
    id: id,
    title: title,
    amountKobo: naira * 100,
    category: category,
    date: date,
    createdAt: date,
  );
}
