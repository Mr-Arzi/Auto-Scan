// lib/data/repositories/history_respository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/scan_result.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _auth;

  HistoryRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  /// Guarda un escaneo SOLO como texto (sin foto)
  Future<void> saveScan(ScanResult result) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    // 👇 Leemos el perfil del usuario para obtener el "name"
    final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final userName =
        (userData['name'] as String?) ?? user.displayName ?? 'Sin nombre';

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'label': result.label,
      'confidence': result.confidence,
      'createdAt': FieldValue.serverTimestamp(), // fecha + HORA
      'name': userName, // 👈 aquí guardamos el nombre
    });
  }

  /// Stream del historial del usuario
  Stream<QuerySnapshot<Map<String, dynamic>>> historyStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
    Future<void> deleteScan(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .doc(docId)
        .delete();
  }
}
