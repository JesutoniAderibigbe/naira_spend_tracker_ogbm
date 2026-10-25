import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Ports must match the `emulators` block in firebase.json.
const int authEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;

/// Host of the machine running `firebase emulators:start`.
///
/// The Android emulator reaches the host machine at 10.0.2.2. For a physical
/// device, pass the machine's LAN IP:
/// `flutter run --dart-define=EMULATOR_HOST=192.168.x.x`.
String emulatorHost() {
  const override = String.fromEnvironment('EMULATOR_HOST');
  if (override.isNotEmpty) return override;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return '10.0.2.2';
  }
  return 'localhost';
}

/// Initializes Firebase. Debug builds talk to the local Emulator Suite;
/// profile and release builds talk to the real project.
Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    final host = emulatorHost();
    await FirebaseAuth.instance.useAuthEmulator(host, authEmulatorPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      firestoreEmulatorPort,
    );
  }
}
