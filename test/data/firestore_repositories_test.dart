import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/data/models/category.dart';
import 'package:naira_spend_tracker_ogbm/data/models/expense.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/firestore_budget_repository.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/firestore_expense_repository.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() => db = FakeFirebaseFirestore());

  group('FirestoreExpenseRepository', () {
    test('writes the documented shape under the user', () async {
      final repo = FirestoreExpenseRepository(db, 'u1');
      final id = await repo.add(
        NewExpense(
          title: 'Suya',
          amountKobo: 250000,
          category: ExpenseCategory.food,
          date: DateTime.utc(2026, 10, 10, 11),
        ),
        createdAt: DateTime.utc(2026, 10, 10, 12),
      );

      final doc = await db.doc('users/u1/expenses/$id').get();
      expect(doc.data()!['title'], 'Suya');
      expect(doc.data()!['amountKobo'], 250000);
      expect(doc.data()!['category'], 'food');
    });

    test(
      'watchSince filters by date, newest first, and sees deletes',
      () async {
        final repo = FirestoreExpenseRepository(db, 'u1');
        Future<String> add(String title, int day) => repo.add(
          NewExpense(
            title: title,
            amountKobo: 100,
            category: ExpenseCategory.other,
            date: DateTime.utc(2026, 10, day, 11),
          ),
          createdAt: DateTime.utc(2026, 10, day, 11),
        );
        await add('old', 1);
        final mid = await add('mid', 5);
        await add('new', 9);

        Future<List<String>> titles() async =>
            (await repo.watchSince(DateTime.utc(2026, 10, 4)).first)
                .map((e) => e.title)
                .toList();
        expect(await titles(), ['new', 'mid']);

        await repo.delete(mid);
        expect(await titles(), ['new']);
      },
    );

    test('restore keeps the original id', () async {
      final repo = FirestoreExpenseRepository(db, 'u1');
      final original = Expense(
        id: 'keep-me',
        title: 'Danfo',
        amountKobo: 120000,
        category: ExpenseCategory.transport,
        date: DateTime.utc(2026, 10, 10, 8),
        createdAt: DateTime.utc(2026, 10, 10, 8),
      );
      await repo.restore(original);
      final list = await repo.watchSince(DateTime.utc(2026)).first;
      expect(list.single, original);
    });
  });

  group('FirestoreBudgetRepository', () {
    test('sets, reads and clears limits', () async {
      final repo = FirestoreBudgetRepository(db, 'u1');
      await repo.setLimit(ExpenseCategory.food, 1500000);
      await repo.setLimit(ExpenseCategory.fun, 1000000);
      expect(await repo.watchLimits().first, {
        ExpenseCategory.food: 1500000,
        ExpenseCategory.fun: 1000000,
      });

      await repo.setLimit(ExpenseCategory.fun, null);
      expect(await repo.watchLimits().first, {ExpenseCategory.food: 1500000});
      expect((await db.doc('users/u1/budgets/fun').get()).exists, isFalse);
    });
  });
}
