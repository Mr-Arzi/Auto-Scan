// lib/data/repositories/firebase_auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user.dart' as model;
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<model.User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fb.User? user = cred.user;
    if (user == null) return null;

    // Leer datos extra desde Firestore
    final doc = await _firestore.collection('users').doc(user.uid).get();

    final data = doc.data() ?? {
      'name': user.displayName ?? '',
      'email': user.email ?? email,
      'avatarUrl': user.photoURL,
    };

    return model.User(
      id: user.uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? email,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  @override
  Future<model.User?> signup(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fb.User? user = cred.user;
    if (user == null) return null;

    await user.updateDisplayName(name);

    // Crear documento de perfil
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'avatarUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });

    return model.User(
      id: user.uid,
      name: name,
      email: email,
      avatarUrl: user.photoURL,
    );
  }

  @override
  Future<model.User?> getCurrentUser() async {
    final fb.User? user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data == null) {
      return model.User(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        avatarUrl: user.photoURL,
      );
    }

    return model.User(
      id: user.uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
