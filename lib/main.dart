import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/firebase_bootstrap.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firestore_budget_repository.dart';
import 'data/repositories/firestore_expense_repository.dart';
import 'data/repositories/user_data_copier.dart';
import 'logic/lagos_time.dart';
import 'logic/spending_controller.dart';
import 'ui/app/app.dart';

/// Composition root: the only place real Firebase is wired to the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();

  final firestore = FirebaseFirestore.instance;
  runApp(
    NairaSpendApp(
      authRepository: FirebaseAuthRepository(
        FirebaseAuth.instance,
        UserDataCopier(firestore),
      ),
      spendingFor: (user) => SpendingController(
        expenses: FirestoreExpenseRepository(firestore, user.uid),
        budgets: FirestoreBudgetRepository(firestore, user.uid),
        clock: systemClock,
      ),
    ),
  );
}
