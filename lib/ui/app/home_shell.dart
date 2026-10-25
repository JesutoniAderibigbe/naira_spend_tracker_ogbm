import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../logic/auth_controller.dart';
import '../../logic/spending_controller.dart';
import 'app_scope.dart';

/// Bottom navigation around Home, Budgets and Insights. Also shows write
/// and Google sign-in errors from any tab.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  SpendingController? _spending;
  AuthController? _auth;
  String? _shownAuthError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    if (scope.auth != _auth) {
      _auth?.removeListener(_showAuthError);
      _auth = scope.auth..addListener(_showAuthError);
    }
    if (scope.spending != _spending) {
      _spending?.removeListener(_showWriteError);
      _spending = scope.spending?..addListener(_showWriteError);
    }
  }

  void _showAuthError() {
    final error = _auth?.error;
    if (error != null && error != _shownAuthError) _show(error);
    _shownAuthError = error;
  }

  void _showWriteError() {
    final message = _spending?.writeError;
    if (message == null) return;
    _spending!.clearWriteError();
    _show(message);
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    _spending?.removeListener(_showWriteError);
    _auth?.removeListener(_showAuthError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              key: Key('nav.home'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              key: Key('nav.budgets'),
              icon: Icon(Icons.donut_large_rounded),
              label: 'Budgets',
            ),
            NavigationDestination(
              key: Key('nav.insights'),
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
