// lib/data/repositories/firebase_auth_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart' as model;
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ---------------------------
  // LOGIN CON CORREO / PASSWORD
  // ---------------------------
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

  // ---------------------------
  // REGISTRO CON CORREO / PASSWORD
  // ---------------------------
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

  // ---------------------------
  // LOGIN CON GOOGLE
  // ---------------------------
  @override
  Future<model.User?> signInWithGoogle() async {
    // 1. Abrir selector de cuenta
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // usuario canceló

    // 2. Obtener tokens de Google
    final googleAuth = await googleUser.authentication;

    // 3. Crear credencial para Firebase
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Iniciar sesión en Firebase
    final userCred = await _auth.signInWithCredential(credential);
    final fb.User? user = userCred.user;
    if (user == null) return null;

    // 5. Crear/actualizar documento en Firestore
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'avatarUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }

    // 6. Devolver modelo de la app
    return model.User(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
    );
  }

  // ---------------------------
  // OBTENER USUARIO ACTUAL
  // ---------------------------
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

  // ---------------------------
  // LOGOUT
  // ---------------------------
  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
