import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> signup(String name, String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
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

    // credenciales incorrectas
    return null;
  }

  @override
  Future<User?> signup(String name, String email, String password) async {
    // por ahora solo devolvemos un user fake
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
}
