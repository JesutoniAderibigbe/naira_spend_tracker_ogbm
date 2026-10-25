import 'package:flutter/foundation.dart';

/// The signed-in person, independent of Firebase types.
@immutable
class AppUser {
  const AppUser({required this.uid, required this.isGuest, this.displayName});

  final String uid;
  final bool isGuest;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.isGuest == isGuest &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(uid, isGuest, displayName);
}
