import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/auth_controller.dart';
import '../../logic/spending_controller.dart';
import '../theme/app_theme.dart';
import 'app_scope.dart';
import 'router.dart';

/// Builds the per-user spending controller. Tests pass one backed by fakes.
typedef SpendingControllerFactory = SpendingController Function(AppUser user);

class NairaSpendApp extends StatefulWidget {
  const NairaSpendApp({
    super.key,
    required this.authRepository,
    required this.spendingFor,
  });

  final AuthRepository authRepository;
  final SpendingControllerFactory spendingFor;

  @override
  State<NairaSpendApp> createState() => _NairaSpendAppState();
}

class _NairaSpendAppState extends State<NairaSpendApp> {
  late final AuthController _auth = AuthController(widget.authRepository);
  late final GoRouter _router = buildRouter(_auth);
  SpendingController? _spending;
  String? _spendingUid;

  @override
  void initState() {
    super.initState();
    _syncSpending();
    _auth.addListener(_syncSpending);
  }

  /// One SpendingController per uid. Linking a guest keeps the uid, so the
  /// data and controller survive the upgrade.
  void _syncSpending() {
    final user = _auth.user;
    if (user?.uid == _spendingUid) return;
    final old = _spending;
    setState(() {
      _spendingUid = user?.uid;
      _spending = user == null ? null : widget.spendingFor(user);
    });
    // Dispose after the frame so nothing still listening sees a dead object.
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_syncSpending);
    _router.dispose();
    _spending?.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: _auth,
      spending: _spending,
      child: MaterialApp.router(
        title: 'Naira Spend Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: _router,
      ),
    );
  }
}
