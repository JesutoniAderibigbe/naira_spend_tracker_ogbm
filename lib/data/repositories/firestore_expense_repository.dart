import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import '../models/expense.dart';
import 'expense_repository.dart';

/// `users/{uid}/expenses/{expenseId}`, see docs/DATA_MODEL.md.
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(FirebaseFirestore firestore, String uid)
    : _col = firestore.collection('users').doc(uid).collection('expenses');

  final CollectionReference<Map<String, dynamic>> _col;

  @override
  Stream<List<Expense>> watchSince(DateTime since) => _col
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(_fromDoc).toList());

  @override
  Future<String> add(NewExpense expense, {required DateTime createdAt}) async {
    final doc = _col.doc();
    await doc.set({
      'title': expense.title,
      'amountKobo': expense.amountKobo,
      'category': expense.category.id,
      'date': Timestamp.fromDate(expense.date),
      'createdAt': Timestamp.fromDate(createdAt),
    });
    return doc.id;
  }

  @override
  Future<void> restore(Expense expense) => _col.doc(expense.id).set({
    'title': expense.title,
    'amountKobo': expense.amountKobo,
    'category': expense.category.id,
    'date': Timestamp.fromDate(expense.date),
    'createdAt': Timestamp.fromDate(expense.createdAt),
  });

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  static Expense _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final date = (data['date'] as Timestamp).toDate().toUtc();
    return Expense(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amountKobo: (data['amountKobo'] as num?)?.toInt() ?? 0,
      category: ExpenseCategory.fromId(data['category'] as String?),
      date: date,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate().toUtc() ?? date,
    );
  }
}
