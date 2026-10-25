import '../models/app_user.dart';

/// Thrown by [AuthRepository] with a message that can be shown to the user.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

abstract interface class AuthRepository {
  AppUser? get currentUser;

  /// Emits on sign in, sign out and when a guest links Google.
  Stream<AppUser?> userChanges();

  /// Signs in with Google. A guest is linked instead, so their data stays.
  Future<void> signInWithGoogle();

  Future<void> signInAsGuest();

  Future<void> signOut();
}
