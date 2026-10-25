import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Raw `users/{uid}` documents, keyed by document id.
@immutable
class UserData {
  const UserData({required this.expenses, required this.budgets});

  final Map<String, Map<String, dynamic>> expenses;
  final Map<String, Map<String, dynamic>> budgets;

  bool get isEmpty => expenses.isEmpty && budgets.isEmpty;
}

/// Moves a guest's data into a Google account that could not be linked
/// because it already existed. [read] runs while signed in as the guest,
/// [writeInto] after switching, so each side only touches its own documents.
class UserDataCopier {
  UserDataCopier(this._db);

  final FirebaseFirestore _db;

  /// Firestore allows 500 writes per batch.
  static const _batchLimit = 500;

  CollectionReference<Map<String, dynamic>> _col(String uid, String name) =>
      _db.collection('users').doc(uid).collection(name);

  Future<UserData> read(String uid) async {
    final [expenses, budgets] = await Future.wait([
      _col(uid, 'expenses').get(),
      _col(uid, 'budgets').get(),
    ]);
    return UserData(expenses: _byId(expenses), budgets: _byId(budgets));
  }

  /// Expenses keep their ids, so running this twice adds nothing new.
  /// Budgets the account already has win over the guest's.
  Future<void> writeInto(String uid, UserData data) async {
    if (data.isEmpty) return;
    final existingBudgets = data.budgets.isEmpty
        ? const <String>{}
        : (await _col(uid, 'budgets').get()).docs.map((d) => d.id).toSet();

    final writes = [
      for (final MapEntry(:key, :value) in data.expenses.entries)
        (_col(uid, 'expenses').doc(key), value),
      for (final MapEntry(:key, :value) in data.budgets.entries)
        if (!existingBudgets.contains(key))
          (_col(uid, 'budgets').doc(key), value),
    ];
    for (var i = 0; i < writes.length; i += _batchLimit) {
      final batch = _db.batch();
      for (final (doc, value) in writes.skip(i).take(_batchLimit)) {
        batch.set(doc, value);
      }
      await batch.commit();
    }
  }

  static Map<String, Map<String, dynamic>> _byId(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) => {for (final doc in snap.docs) doc.id: doc.data()};
}
