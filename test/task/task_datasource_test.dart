import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:linkyou_tasks_app/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../auth/auth_repository_test.dart';
 

@GenerateMocks([Dio])
void main() {
  group('TaskLocalDataSourceImpl', () {
    late SharedPreferences sharedPreferences;
    late TaskLocalDataSourceImpl localDataSource;

    final Task testTask = Task(
      id: '1',
      todo: 'Test Task',
      completed: false,
      userId: 1,
      createdAt: DateTime.now(),
      isLocal: true,
      isSynced: false,
      isDeleted: false,
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = SharedPreferences.getInstance() as SharedPreferences;
      localDataSource = TaskLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    });

    test('should cache tasks successfully', () async {
      // Act
      await localDataSource.cacheTasks([testTask]);

      // Assert
      final cached = sharedPreferences.getStringList('cached_tasks');
      expect(cached, isNotNull);
      expect(cached!.length, 1);
    });

    test('should get cached tasks successfully', () async {
      // Arrange
      final taskJson = [testTask.toJson()];
      await sharedPreferences.setStringList('cached_tasks', 
          taskJson.map((json) => json.toString()).toList());

      // Act
      final tasks = await localDataSource.getCachedTasks();

      // Assert
      expect(tasks.length, 1);
      expect(tasks.first.id, testTask.id);
    });

    test('should return empty list when no cached tasks', () async {
      // Act
      final tasks = await localDataSource.getCachedTasks();

      // Assert
      expect(tasks, isEmpty);
    });

    test('should handle JSON parsing errors gracefully', () async {
      // Arrange
      await sharedPreferences.setStringList('cached_tasks', ['invalid_json']);

      // Act
      final tasks = await localDataSource.getCachedTasks();

      // Assert
      expect(tasks, isEmpty);
    });

    test('should filter out deleted tasks', () async {
      // Arrange
      final deletedTask = testTask.copyWith(isDeleted: true);
      final tasks = [testTask, deletedTask];
      await localDataSource.cacheTasks(tasks);

      // Act
      final cachedTasks = await localDataSource.getCachedTasks();

      // Assert
      expect(cachedTasks.length, 1);
      expect(cachedTasks.first.isDeleted, false);
    });
  });

  group('TaskRemoteDataSourceImpl', () {
    late MockDio mockDio;
    late TaskRemoteDataSourceImpl remoteDataSource;

    final Task testTask = Task(
      id: '1',
      todo: 'Test Task',
      completed: false,
      userId: 1,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockDio = MockDio();
      remoteDataSource = TaskRemoteDataSourceImpl(dio: mockDio);
    });

    test('should get tasks from API', () async {
      // Arrange
      final responseData = {
        'todos': [testTask.toJson()],
        'total': 1,
        'skip': 0,
        'limit': 10,
      };
      
      when(mockDio.get(
        '/todos',
        queryParameters: {'limit': 10, 'skip': 0},
      )).thenAnswer((_) async => Response(
        data: responseData,
        requestOptions: RequestOptions(path: '/todos'),
      ));

      // Act
      final taskList = await remoteDataSource.getTasks(limit: 10, skip: 0);

      // Assert
      expect(taskList.tasks.length, 1);
      expect(taskList.total, 1);
      verify(mockDio.get(
        '/todos',
        queryParameters: {'limit': 10, 'skip': 0},
      )).called(1);
    });

    test('should get task by ID', () async {
      // Arrange
      when(mockDio.get('/todos/1')).thenAnswer((_) async => Response(
        data: testTask.toJson(),
        requestOptions: RequestOptions(path: '/todos/1'),
      ));

      // Act
      final task = await remoteDataSource.getTaskById('1');

      // Assert
      expect(task.id, '1');
      verify(mockDio.get('/todos/1')).called(1);
    });

    test('should add task via API', () async {
      // Arrange
      final todo = 'New Task';
      final completed = false;
      final userId = 1;
      
      when(mockDio.post(
        '/todos/add',
        data: {'todo': todo, 'completed': completed, 'userId': userId},
      )).thenAnswer((_) async => Response(
        data: testTask.copyWith(todo: todo).toJson(),
        requestOptions: RequestOptions(path: '/todos/add'),
      ));

      // Act
      final task = await remoteDataSource.addTask(todo, completed, userId);

      // Assert
      expect(task.todo, todo);
      verify(mockDio.post(
        '/todos/add',
        data: {'todo': todo, 'completed': completed, 'userId': userId},
      )).called(1);
    });

    test('should update task via API', () async {
      // Arrange
      final updatedTask = testTask.copyWith(completed: true);
      
      when(mockDio.put(
        '/todos/${testTask.id}',
        data: updatedTask.toJson(),
      )).thenAnswer((_) async => Response(
        data: updatedTask.toJson(),
        requestOptions: RequestOptions(path: '/todos/${testTask.id}'),
      ));

      // Act
      final task = await remoteDataSource.updateTask(updatedTask);

      // Assert
      expect(task.completed, true);
      verify(mockDio.put(
        '/todos/${testTask.id}',
        data: updatedTask.toJson(),
      )).called(1);
    });

    test('should delete task via API', () async {
      // Arrange
      when(mockDio.delete('/todos/1')).thenAnswer((_) async => Response(
        data: {},
        requestOptions: RequestOptions(path: '/todos/1'),
      ));

      // Act
      await remoteDataSource.deleteTask('1');

      // Assert
      verify(mockDio.delete('/todos/1')).called(1);
    });

    test('should propagate Dio errors', () async {
      // Arrange
      when(mockDio.get('/todos')).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/todos'),
        error: 'Network error',
      ));

      // Act & Assert
      expect(() => remoteDataSource.getTasks(), throwsA(isA<Exception>()));
    });
  });
}