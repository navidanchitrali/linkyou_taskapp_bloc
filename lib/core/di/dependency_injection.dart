import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart'; // Add this
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);
    
    getIt.registerLazySingleton(() => const FlutterSecureStorage());
    
    getIt.registerLazySingleton(() => ApiService());
    getIt.registerLazySingleton<Dio>(() => getIt<ApiService>().dio);
    
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(secureStorage: getIt()),
    );
    
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: getIt()),
    );
    
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(  
        remoteDataSource: getIt(),
        localDataSource: getIt(),
      ),
    );
    
    getIt.registerLazySingleton<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl(sharedPreferences: getIt()),
    );
    
    getIt.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(dio: getIt()),
    );
    
    getIt.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
      ),
    );
  }
}