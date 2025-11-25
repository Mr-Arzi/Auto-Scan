// lib/data/repositories/history_respository.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';

import '../models/scan_result.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final fb.FirebaseAuth _auth;

  HistoryRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required fb.FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  /// Guarda la imagen en Storage y el registro en Firestore
  Future<void> saveScan(ScanResult result) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final file = File(result.imagePath);

    final ref = _storage
        .ref()
        .child('scans')
        .child(user.uid)
        .child('${result.scannedAt.millisecondsSinceEpoch}.jpg');

    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'imageUrl': url,
      'label': result.label,
      'confidence': result.confidence,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream para la pantalla de History
  Stream<QuerySnapshot<Map<String, dynamic>>> historyStream() {
    final user = _auth.currentUser;
    if (user == null) {
      // Si no hay usuario, devolvemos un stream vacío
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
