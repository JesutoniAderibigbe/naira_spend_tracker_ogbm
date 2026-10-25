import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/auth_repository.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/firebase_auth_repository.dart';
import 'package:naira_spend_tracker_ogbm/data/repositories/user_data_copier.dart';

// MockUser.linkWithProvider asserts the user is not anonymous, so it can't
// stand in for a guest. These subclasses model what Firebase does instead.

class _Credential implements UserCredential {
  _Credential(this.user);

  @override
  final User? user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A guest whose link succeeds (keeping the uid) or throws [linkError].
// MockUser itself has mutable fields, so its subclasses can't be immutable.
// ignore: must_be_immutable
class _Guest extends MockUser {
  _Guest({this.linkError}) : super(uid: 'guest-1', isAnonymous: true);

  final FirebaseAuthException? linkError;
  final linkedProviders = <String>[];

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    if (linkError case final e?) throw e;
    linkedProviders.add(provider.providerId);
    return _Credential(this);
  }
}

/// Signing in with a credential switches to the existing [google] account.
class _Auth extends MockFirebaseAuth {
  _Auth({super.mockUser, super.signedIn, this.google});

  final MockUser? google;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) {
    if (google case final g?) mockUser = g;
    return super.signInWithCredential(credential);
  }
}

final _googleUser = MockUser(uid: 'google-1', displayName: 'Ada Obi');

FirebaseAuthException _alreadyInUse() => FirebaseAuthException(
  code: 'credential-already-in-use',
  credential: GoogleAuthProvider.credential(idToken: 'token'),
);

Map<String, dynamic> _expense(String title) => {
  'title': title,
  'amountKobo': 250000,
  'category': 'food',
  'date': Timestamp.fromDate(DateTime.utc(2026, 10, 10, 11)),
  'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 10, 11)),
};

void main() {
  late FakeFirebaseFirestore db;

  setUp(() => db = FakeFirebaseFirestore());

  FirebaseAuthRepository repo(FirebaseAuth auth) =>
      FirebaseAuthRepository(auth, UserDataCopier(db));

  Future<List<String>> expenseIds(String uid) async =>
      (await db.collection('users/$uid/expenses').get()).docs
          .map((d) => d.id)
          .toList();

  test('signInAsGuest signs in anonymously', () async {
    final r = repo(
      MockFirebaseAuth(mockUser: MockUser(uid: 'g', isAnonymous: true)),
    );
    expect(r.currentUser, isNull);

    await r.signInAsGuest();
    expect(r.currentUser?.uid, 'g');
    expect(r.currentUser?.isGuest, isTrue);
  });

  test('signInWithGoogle when signed out signs in to Google', () async {
    final r = repo(MockFirebaseAuth(mockUser: _googleUser));

    await r.signInWithGoogle();
    expect(r.currentUser?.uid, 'google-1');
    expect(r.currentUser?.isGuest, isFalse);
    expect(r.currentUser?.displayName, 'Ada Obi');
  });

  test('a guest is linked, keeping the uid and their expenses', () async {
    final guest = _Guest();
    await db.doc('users/guest-1/expenses/e1').set(_expense('Suya'));
    final r = repo(_Auth(mockUser: guest, signedIn: true));

    await r.signInWithGoogle();

    expect(guest.linkedProviders, ['google.com']);
    expect(r.currentUser?.uid, 'guest-1');
    expect(await expenseIds('guest-1'), ['e1']);
  });

  test('when Google already has an account, the guest data is copied into '
      'it', () async {
    await db.doc('users/guest-1/expenses/e1').set(_expense('Suya'));
    await db.doc('users/guest-1/budgets/fun').set({'monthlyLimitKobo': 500});
    await db.doc('users/google-1/expenses/g1').set(_expense('Rent'));
    final r = repo(
      _Auth(
        mockUser: _Guest(linkError: _alreadyInUse()),
        signedIn: true,
        google: _googleUser,
      ),
    );

    await r.signInWithGoogle();

    expect(r.currentUser?.uid, 'google-1');
    expect(r.currentUser?.isGuest, isFalse);
    expect(await expenseIds('google-1'), unorderedEquals(['g1', 'e1']));
    final fun = await db.doc('users/google-1/budgets/fun').get();
    expect(fun.data(), {'monthlyLimitKobo': 500});
  });

  test('a cancelled link leaves the guest signed in', () async {
    final r = repo(
      _Auth(
        mockUser: _Guest(linkError: FirebaseAuthException(code: 'canceled')),
        signedIn: true,
      ),
    );

    await expectLater(
      r.signInWithGoogle(),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Sign-in was cancelled.',
        ),
      ),
    );
    expect(r.currentUser?.uid, 'guest-1');
    expect(r.currentUser?.isGuest, isTrue);
  });
}
