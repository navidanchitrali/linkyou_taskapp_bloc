import 'package:dio/dio.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_list.dart';

abstract class TaskRemoteDataSource {
  Future<TaskList> getTasks({int limit = 10, int skip = 0});
  Future<Task> getTaskById(String id);
  Future<Task> addTask(String todo, bool completed, int userId);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<TaskList> getTasks({int limit = 10, int skip = 0}) async {
    try {
      final response = await dio.get(
        '/todos',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return TaskList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> getTaskById(String id) async {
    try {
      final response = await dio.get('/todos/$id');
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> addTask(String todo, bool completed, int userId) async {
    try {
      final response = await dio.post(
        '/todos/add',
        data: {'todo': todo, 'completed': completed, 'userId': userId},
      );
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      final response = await dio.put(
        '/todos/${task.id}',
        data: task.toJson(),
      );
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await dio.delete('/todos/$id');
    } catch (e) {
      rethrow;
    }
  }
}