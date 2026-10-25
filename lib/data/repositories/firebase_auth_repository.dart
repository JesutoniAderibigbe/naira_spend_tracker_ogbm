import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';
import 'user_data_copier.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._copier);

  final FirebaseAuth _auth;
  final UserDataCopier _copier;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    final user = _auth.currentUser;
    try {
      if (user != null && user.isAnonymous) {
        await (kIsWeb
            ? user.linkWithPopup(provider)
            : user.linkWithProvider(provider));
      } else {
        await (kIsWeb
            ? _auth.signInWithPopup(provider)
            : _auth.signInWithProvider(provider));
      }
    } on FirebaseAuthException catch (e) {
      // The Google account already exists, so it can't be linked. Sign in
      // to it and copy the guest's data across, so the guest keeps it.
      if (e.code == 'credential-already-in-use' &&
          e.credential != null &&
          user != null) {
        await _switchKeepingData(user.uid, e.credential!);
        return;
      }
      throw AuthException(_message(e));
    }
  }

  Future<void> _switchKeepingData(
    String guestUid,
    AuthCredential credential,
  ) async {
    // Read first: once signed in as Google, the guest's documents belong to
    // someone else.
    final data = await _copier.read(guestUid);
    final UserCredential signedIn;
    try {
      signedIn = await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
    await _copier.writeInto(signedIn.user!.uid, data);
  }

  @override
  Future<void> signInAsGuest() async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          isGuest: user.isAnonymous,
          // A linked guest may have no profile name of its own yet.
          displayName:
              user.displayName ??
              user.providerData.map((p) => p.displayName).nonNulls.firstOrNull,
        );

  static String _message(FirebaseAuthException e) => switch (e.code) {
    'network-request-failed' => 'No internet connection. Try again.',
    'web-context-canceled' ||
    'popup-closed-by-user' ||
    'canceled' => 'Sign-in was cancelled.',
    _ => 'Could not sign in. Try again.',
  };
}
