import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repo;

  AuthService(this._repo);

  Future<User?> login(String email, String password) {
    return _repo.login(email, password);
  }

  Future<User?> signup(String name, String email, String password) {
    return _repo.signup(name, email, password);
  }

  Future<User?> getCurrentUser() => _repo.getCurrentUser();

  Future<void> logout() => _repo.logout();
}
