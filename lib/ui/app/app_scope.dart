import 'package:flutter/widgets.dart';

import '../../logic/auth_controller.dart';
import '../../logic/spending_controller.dart';

/// Hands controllers to the widget tree. The controllers hold the state;
/// widgets listen to them with ListenableBuilder.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.spending,
    required super.child,
  });

  final AuthController auth;

  /// Null while signed out.
  final SpendingController? spending;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  /// For screens that only exist while signed in.
  static SpendingController spendingOf(BuildContext context) =>
      of(context).spending!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      auth != oldWidget.auth || spending != oldWidget.spending;
}
