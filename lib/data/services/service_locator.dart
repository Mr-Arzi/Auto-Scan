
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/history_respository.dart';
import 'auth_service.dart';
import 'scan_service.dart';

final fbAuth = fb.FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;

// Auth
final AuthRepository authRepository = FirebaseAuthRepository();
final authService = AuthService(authRepository);

// Scan (ya lo usas en ResultsScreen)
final scanService = ScanService();

// History (lo vamos a implementar abajo)
final historyRepository = HistoryRepository(
  firestore: firestore,
 
  auth: fbAuth,
);
