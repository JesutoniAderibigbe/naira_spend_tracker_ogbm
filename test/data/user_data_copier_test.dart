import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/user_data_copier.dart';

Map<String, dynamic> _expense(String title, int kobo) => {
  'title': title,
  'amountKobo': kobo,
  'category': 'food',
  'date': Timestamp.fromDate(DateTime.utc(2026, 10, 10, 11)),
  'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 10, 11)),
};

void main() {
  late FakeFirebaseFirestore db;
  late UserDataCopier copier;

  setUp(() {
    db = FakeFirebaseFirestore();
    copier = UserDataCopier(db);
  });

  Future<Map<String, Map<String, dynamic>>> docs(String path) async {
    final snap = await db.collection(path).get();
    return {for (final d in snap.docs) d.id: d.data()};
  }

  test('copies expenses with their ids and fields', () async {
    await db.doc('users/guest/expenses/e1').set(_expense('Suya', 250000));
    await db.doc('users/guest/expenses/e2').set(_expense('Danfo', 120000));

    await copier.writeInto('google', await copier.read('guest'));

    final copied = await docs('users/google/expenses');
    expect(copied.keys, unorderedEquals(['e1', 'e2']));
    expect(copied['e1'], _expense('Suya', 250000));
  });

  test('keeps what the account already has; its budgets win', () async {
    await db.doc('users/guest/expenses/e1').set(_expense('Suya', 250000));
    await db.doc('users/guest/budgets/food').set({'monthlyLimitKobo': 100});
    await db.doc('users/guest/budgets/fun').set({'monthlyLimitKobo': 200});
    await db.doc('users/google/expenses/g1').set(_expense('Rent', 9900));
    await db.doc('users/google/budgets/food').set({'monthlyLimitKobo': 999});

    await copier.writeInto('google', await copier.read('guest'));

    expect((await docs('users/google/expenses')).keys, {'g1', 'e1'});
    expect(await docs('users/google/budgets'), {
      'food': {'monthlyLimitKobo': 999},
      'fun': {'monthlyLimitKobo': 200},
    });
  });

  test('running twice adds nothing new', () async {
    await db.doc('users/guest/expenses/e1').set(_expense('Suya', 250000));
    final data = await copier.read('guest');

    await copier.writeInto('google', data);
    await copier.writeInto('google', data);

    expect(await docs('users/google/expenses'), hasLength(1));
  });

  test('a guest with zero expenses and budgets writes nothing', () async {
    final data = await copier.read('guest');
    expect(data.isEmpty, isTrue);

    await copier.writeInto('google', data);
    expect(await docs('users/google/expenses'), isEmpty);
    expect(await docs('users/google/budgets'), isEmpty);
  });

  test('more than one batch of 500 writes is all copied', () async {
    // Seeded one by one: the fake, like Firestore, rejects 501 in a batch.
    for (var i = 0; i < 501; i++) {
      await db.doc('users/guest/expenses/e$i').set(_expense('Item $i', 100));
    }

    await copier.writeInto('google', await copier.read('guest'));
    expect(await docs('users/google/expenses'), hasLength(501));
  });
}
