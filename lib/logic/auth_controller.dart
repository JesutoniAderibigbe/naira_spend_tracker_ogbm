import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';

/// Who is signed in, plus the sign-in actions the UI can trigger.
class AuthController extends ChangeNotifier {
  AuthController(this._repository) : _user = _repository.currentUser {
    _sub = _repository.userChanges().listen((user) {
      if (user == _user) return;
      _user = user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _sub;

  AppUser? _user;
  AppUser? get user => _user;

  bool _busy = false;
  bool get isBusy => _busy;

  /// Last sign-in error, for the UI to show. Cleared on the next attempt.
  String? _error;
  String? get error => _error;

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> signInAsGuest() => _run(_repository.signInAsGuest);

  Future<void> signOut() => _run(_repository.signOut);

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on AuthException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong. Try again.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
