import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/data/models/app_user.dart';
import 'package:naira_spend_tracker_ogbm/data/models/category.dart';
import 'package:naira_spend_tracker_ogbm/data/models/expense.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/auth_repository.dart';
import 'package:naira_spend_tracker_ogbm/logic/spending_controller.dart';
import 'package:naira_spend_tracker_ogbm/ui/app/app.dart';

import 'helpers/fakes.dart';

const _guest = AppUser(uid: 'guest-1', isGuest: true);

class _Harness {
  _Harness({
    AppUser? user,
    List<Expense> expenses = const [],
    Map<ExpenseCategory, int> limits = const {},
  }) : auth = FakeAuthRepository(user),
       expenseRepo = InMemoryExpenseRepository(expenses),
       budgetRepo = InMemoryBudgetRepository(limits);

  final FakeAuthRepository auth;
  final InMemoryExpenseRepository expenseRepo;
  final InMemoryBudgetRepository budgetRepo;

  Future<void> pump(WidgetTester tester) async {
    // A phone-sized screen, like the designs.
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NairaSpendApp(
        authRepository: auth,
        spendingFor: (_) => SpendingController(
          expenses: expenseRepo,
          budgets: budgetRepo,
          clock: fixedClock,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('signed out shows sign in; guest lands on Home', (tester) async {
    final h = _Harness();
    await h.pump(tester);

    expect(find.text('Know where every naira goes.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('signIn.guest')));
    await tester.pumpAndSettle();

    expect(find.text('Your money'), findsOneWidget);
    expect(
      find.text('No expenses yet. Tap Add expense to log your first one.'),
      findsOneWidget,
    );
  });

  testWidgets('sign-in errors are shown', (tester) async {
    final h = _Harness()
      ..auth.failWith = const AuthException(
        'No internet connection. Try again.',
      );
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('signIn.google')));
    await tester.pumpAndSettle();
    expect(find.text('No internet connection. Try again.'), findsOneWidget);
  });

  testWidgets('a guest who links Google keeps their expenses', (tester) async {
    final h = _Harness(
      user: _guest,
      expenses: [expense('a', 'Suya', 2500, ExpenseCategory.food)],
    );
    await h.pump(tester);
    expect(find.text('G'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home.account')));
    await tester.pumpAndSettle();
    expect(find.text('You are using a guest account'), findsOneWidget);
    await tester.tap(find.byKey(const Key('account.linkGoogle')));
    await tester.pumpAndSettle();

    expect(h.auth.currentUser?.uid, _guest.uid);
    expect(h.auth.currentUser?.isGuest, isFalse);
    expect(find.text('JA'), findsOneWidget);
    expect(find.text('Suya'), findsOneWidget);
  });

  testWidgets('sign out returns to the sign-in screen', (tester) async {
    final h = _Harness(user: _guest);
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('home.account')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account.signOut')));
    await tester.pumpAndSettle();

    expect(h.auth.currentUser, isNull);
    expect(find.byKey(const Key('signIn.google')), findsOneWidget);
  });

  testWidgets('Home shows the week and recent expenses', (tester) async {
    final h = _Harness(
      user: _guest,
      expenses: [
        expense('a', 'Jollof rice and chicken', 4500, ExpenseCategory.food),
        expense('b', 'Danfo to Ojota', 1200, ExpenseCategory.transport),
        expense(
          'c',
          'Prepaid electricity',
          40100,
          ExpenseCategory.bills,
          daysAgo: 4,
        ),
      ],
    );
    await h.pump(tester);

    expect(find.text('₦45,800'), findsOneWidget);
    expect(find.text('Daily average ₦6,542.86'), findsOneWidget);
    expect(find.text('Food · Today'), findsOneWidget);
    expect(find.text('Bills · Tue 6 Oct'), findsOneWidget);
  });

  testWidgets('delete removes a row and Undo brings it back', (tester) async {
    final h = _Harness(
      user: _guest,
      expenses: [expense('a', 'Suya', 2500, ExpenseCategory.food)],
    );
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('expense.delete.a')));
    await tester.pumpAndSettle();
    expect(find.text('Suya'), findsNothing);
    expect(h.expenseRepo.expenses, isEmpty);

    await tester.tap(find.byKey(const Key('home.undoDelete')));
    await tester.pumpAndSettle();
    expect(find.text('Suya'), findsOneWidget);
  });

  testWidgets('Add expense validates, then saves', (tester) async {
    final h = _Harness(user: _guest);
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('home.addExpense')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add.save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('Say what you bought'), findsOneWidget);
    expect(find.text('Choose a category'), findsOneWidget);
    expect(h.expenseRepo.expenses, isEmpty);

    await tester.enterText(find.byKey(const Key('add.amount')), '2500');
    expect(find.text('2,500'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('add.title')), 'Suya');
    await tester.tap(find.byKey(const Key('add.category.food')));
    await tester.tap(find.byKey(const Key('add.save')));
    await tester.pumpAndSettle();

    final saved = h.expenseRepo.expenses.single;
    expect(saved.amountKobo, 250000);
    expect(saved.category, ExpenseCategory.food);
    expect(saved.date, fixedNow);
    expect(find.text('Your money'), findsOneWidget);
    expect(find.text('Suya'), findsOneWidget);
  });

  testWidgets('Budgets shows status in words and the over-budget alert', (
    tester,
  ) async {
    final h = _Harness(
      user: _guest,
      expenses: [
        expense('a', 'NEPA', 22000, ExpenseCategory.bills),
        expense('b', 'Cinema', 7000, ExpenseCategory.fun),
      ],
      limits: {
        ExpenseCategory.bills: 20000 * 100,
        ExpenseCategory.fun: 10000 * 100,
      },
    );
    await h.pump(tester);

    await tester.tap(find.byKey(const Key('nav.budgets')));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Bills is ₦2,000 over budget'), findsOneWidget);
    expect(find.text('Over by ₦2,000'), findsOneWidget);
    expect(find.text('₦3,000 left'), findsOneWidget);
  });

  testWidgets('Budgets edit sheet saves a limit', (tester) async {
    final h = _Harness(user: _guest);
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('nav.budgets')));
    await tester.pumpAndSettle();

    expect(find.text('No budgets yet'), findsOneWidget);
    await tester.tap(find.byKey(const Key('budgets.edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('budgets.limit.food')),
      '15000',
    );
    await tester.tap(find.byKey(const Key('budgets.save')));
    await tester.pumpAndSettle();

    expect(h.budgetRepo.limits, {ExpenseCategory.food: 1500000});
    expect(find.text('₦15,000 left'), findsOneWidget);
  });

  testWidgets('Insights switches period', (tester) async {
    final h = _Harness(
      user: _guest,
      expenses: [
        expense('a', 'Suya', 2500, ExpenseCategory.food),
        expense(
          'b',
          'Prepaid electricity',
          20000,
          ExpenseCategory.bills,
          daysAgo: 20,
        ),
      ],
    );
    await h.pump(tester);
    await tester.tap(find.byKey(const Key('nav.insights')));
    await tester.pumpAndSettle();

    expect(find.text('Spent in the last 30 days'), findsOneWidget);
    expect(find.text('₦22,500'), findsOneWidget);
    expect(find.text('Across 2 expenses'), findsOneWidget);

    await tester.tap(find.byKey(const Key('insights.period.last7Days')));
    await tester.pumpAndSettle();
    expect(find.text('Spent in the last 7 days'), findsOneWidget);
    expect(find.text('Across 1 expense'), findsOneWidget);
  });
}
