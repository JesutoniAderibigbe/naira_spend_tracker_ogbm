import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../logic/auth_controller.dart';
import '../screens/add_expense_screen.dart';
import '../screens/budgets_screen.dart';
import '../screens/home_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/sign_in_screen.dart';
import 'app_scope.dart';
import 'home_shell.dart';

abstract final class Routes {
  static const signIn = '/sign-in';
  static const home = '/home';
  static const addExpense = '/home/add';
  static const budgets = '/budgets';
  static const insights = '/insights';
}

GoRouter buildRouter(AuthController auth) {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final signedIn = auth.user != null;
      final onSignIn = state.matchedLocation == Routes.signIn;
      if (!signedIn) return onSignIn ? null : Routes.signIn;
      if (onSignIn) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      StatefulShellRoute.indexedStack(
        // On sign out the controllers go before the redirect to sign in
        // lands, so the tabs must not build for that one frame.
        builder: (context, state, shell) =>
            AppScope.of(context).spending == null
            ? const SizedBox.shrink()
            : HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    // Full screen, above the bottom navigation.
                    parentNavigatorKey: rootKey,
                    pageBuilder: (context, state) => const MaterialPage(
                      fullscreenDialog: true,
                      child: AddExpenseScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.budgets,
                builder: (context, state) => const BudgetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.insights,
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
