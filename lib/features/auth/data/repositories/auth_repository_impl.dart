import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String username, String password) async {
    final user = await remoteDataSource.login(username, password);
    await localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.clear();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<User> validateSession(String token) async {
    return await remoteDataSource.getCurrentUser(token);
  }

  @override
  Future<void> saveUser(User user) async {
    await localDataSource.saveUser(user);
  }

  @override
  Future<bool> hasToken() async {
    return await localDataSource.hasToken();
  }
}