import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> signup(String name, String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();

  // 👇 NUEVO: login con Google
  Future<User?> signInWithGoogle();
}

/// Fake para pruebas sin backend
class FakeAuthRepository implements AuthRepository {
  User? _currentUser;

  // 🔹 Credenciales de prueba:
  // email: demo@autoscan.com
  // pass:  123456

  static const String _demoEmail = 'giovanni@autoscan.com';
  static const String _demoPassword = '123456';

  @override
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (email == _demoEmail && password == _demoPassword) {
      _currentUser = const User(
        id: 'giovanni',
        name: 'giovannidemo',
        email: _demoEmail,
      );
      return _currentUser;
    }

    return null; // credenciales incorrectas
  }

  @override
  Future<User?> signup(String name, String email, String password) async {
    _currentUser = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
    return _currentUser;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  // 👇 Implementación fake del login con Google
  // (solo para que compile, no abre Google)
  @override
  Future<User?> signInWithGoogle() async {
    // Retorna un usuario "falso" para pruebas
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = const User(
      id: 'google_fake',
      name: 'Google User',
      email: 'google.fake@autoscan.com',
    );
    return _currentUser;
  }
}
