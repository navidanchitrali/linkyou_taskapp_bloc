import '../entities/user.dart';

 

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<User> validateSession(String token);
  Future<void> saveUser(User user);
  Future<bool> hasToken(); 
}