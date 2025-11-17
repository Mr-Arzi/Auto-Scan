import '../repositories/auth_repository.dart';
import '../repositories/history_respository.dart';
import 'auth_service.dart';
import 'scan_service.dart';

final authService = AuthService(FakeAuthRepository());

