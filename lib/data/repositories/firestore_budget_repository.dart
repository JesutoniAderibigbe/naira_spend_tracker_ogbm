import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import 'budget_repository.dart';

/// `users/{uid}/budgets/{category}`, see docs/DATA_MODEL.md.
class FirestoreBudgetRepository implements BudgetRepository {
  FirestoreBudgetRepository(FirebaseFirestore firestore, String uid)
    : _col = firestore.collection('users').doc(uid).collection('budgets');

  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Stream<Map<ExpenseCategory, int>> watchLimits() =>
      _col.snapshots().map((snap) {
        final limits = <ExpenseCategory, int>{};
        for (final doc in snap.docs) {
          final limit = (doc.data()['monthlyLimitKobo'] as num?)?.toInt() ?? 0;
          final category = ExpenseCategory.values.where((c) => c.id == doc.id);
          if (limit > 0 && category.isNotEmpty) limits[category.first] = limit;
        }
        return limits;
      });

  @override
  Future<void> setLimit(ExpenseCategory category, int? limitKobo) {
    final doc = _col.doc(category.id);
    // The rules only allow positive limits, so "no limit" is a delete.
    if (limitKobo == null || limitKobo <= 0) return doc.delete();
    return doc.set({'monthlyLimitKobo': limitKobo});
  }
}
