import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:linkyou_tasks_app/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:linkyou_tasks_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task_list.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'task_repository_test.mocks.dart';
 

 
@GenerateMocks([TaskRemoteDataSource, TaskLocalDataSource])
void main() {
  late MockTaskRemoteDataSource mockRemoteDataSource;
  late MockTaskLocalDataSource mockLocalDataSource;
  late TaskRepositoryImpl taskRepository;

  final Task mockApiTask = Task(
    id: '1',
    todo: 'Test API Task',
    completed: false,
    userId: 1,
    createdAt: DateTime.now(),
  );

  final Task mockLocalTask = Task(
    id: 'local_1',
    todo: 'Test Local Task',
    completed: true,
    userId: 1,
    createdAt: DateTime.now().subtract(Duration(days: 1)),
    isLocal: true,
    isSynced: false,
    isDeleted: false,
  );

  final TaskList mockApiTaskList = TaskList(
    tasks: [mockApiTask, mockApiTask],
    total: 2,
    skip: 0,
    limit: 10,
  );

  setUp(() {
    mockRemoteDataSource = MockTaskRemoteDataSource();
    mockLocalDataSource = MockTaskLocalDataSource();
    taskRepository = TaskRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('TaskRepositoryImpl - getTasks', () {
    test('should return paginated tasks from cache when skip > 0', () async {
      // Arrange
      final cachedTasks = [mockLocalTask, mockLocalTask];
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => cachedTasks);

      // Act
      final result = await taskRepository.getTasks(limit: 5, skip: 10);

      // Assert
      expect(result.tasks.length, lessThanOrEqualTo(5));
      expect(result.skip, 10);
      expect(result.limit, 5);
      verify(mockLocalDataSource.getCachedTasks()).called(1);
      verifyNever(mockRemoteDataSource.getTasks());
    });

    test('should fetch from API on initial load and merge with local tasks', () async {
      // Arrange
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [mockLocalTask]);
      when(mockRemoteDataSource.getTasks(limit: 30, skip: 0))
          .thenAnswer((_) async => mockApiTaskList);
      when(mockLocalDataSource.cacheTasks(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await taskRepository.getTasks(limit: 10, skip: 0);

      // Assert
      expect(result.tasks.length, greaterThan(0));
      verify(mockRemoteDataSource.getTasks(limit: 30, skip: 0)).called(1);
      verify(mockLocalDataSource.cacheTasks(any)).called(1);
    });

    test('should handle API failure and return cached tasks', () async {
      // Arrange
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [mockLocalTask]);
      when(mockRemoteDataSource.getTasks(limit: 30, skip: 0))
          .thenThrow(Exception('API Error'));

      // Act
      final result = await taskRepository.getTasks(limit: 10, skip: 0);

      // Assert
      expect(result.tasks.length, 1);
      expect(result.tasks.first.id, 'local_1');
      verify(mockRemoteDataSource.getTasks(limit: 30, skip: 0)).called(1);
    });

    test('should remove duplicate tasks when merging API and local data', () async {
      // Arrange
      final duplicateTask = Task(
        id: 'api_1',
        todo: 'Duplicate Task',
        completed: false,
        userId: 1,
        createdAt: DateTime.now(),
        serverId: '1',
        isLocal: false,
        isSynced: true,
        isDeleted: false,
      );

      final duplicateLocalTask = Task(
        id: 'local_1',
        todo: 'Duplicate Task',
        completed: true,
        userId: 1,
        createdAt: DateTime.now(),
        isLocal: true,
        isSynced: false,
        isDeleted: false,
      );

      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [duplicateLocalTask]);
      when(mockRemoteDataSource.getTasks(limit: 30, skip: 0))
          .thenAnswer((_) async => TaskList(
                tasks: [duplicateTask],
                total: 1,
                skip: 0,
                limit: 10,
              ));

      // Act
      final result = await taskRepository.getTasks(limit: 10, skip: 0);

      // Assert
      expect(result.tasks.length, 1);
      verify(mockLocalDataSource.cacheTasks(any)).called(1);
    });
  });

  group('TaskRepositoryImpl - CRUD Operations', () {
    test('should add task and save to cache', () async {
      // Arrange
      final newTodo = 'New Task';
      final userId = 1;
      final cachedTasks = [mockLocalTask];
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => cachedTasks);
      when(mockLocalDataSource.cacheTasks(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await taskRepository.addTask(newTodo, false, userId);

      // Assert
      expect(result.todo, newTodo);
      expect(result.userId, userId);
      expect(result.isLocal, true);
      expect(result.isSynced, false);
      verify(mockLocalDataSource.cacheTasks(any)).called(1);
    });

    test('should update task and update cache', () async {
      // Arrange
      final updatedTask = mockLocalTask.copyWith(
        completed: true,
        updatedAt: DateTime.now(),
      );
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [mockLocalTask]);
      when(mockLocalDataSource.cacheTasks(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await taskRepository.updateTask(updatedTask);

      // Assert
      expect(result.completed, true);
      expect(result.updatedAt, isNotNull);
      verify(mockLocalDataSource.cacheTasks(any)).called(1);
    });

    test('should mark task as deleted in cache', () async {
      // Arrange
      final taskId = 'local_1';
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [mockLocalTask]);
      when(mockLocalDataSource.cacheTasks(any))
          .thenAnswer((_) async => Future.value());

      // Act
      await taskRepository.deleteTask(taskId);

      // Assert
      verify(mockLocalDataSource.cacheTasks(any)).called(1);
    });

    test('should get task by ID', () async {
      // Arrange
      final taskId = 'local_1';
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [mockLocalTask]);

      // Act
      final result = await taskRepository.getTaskById(taskId);

      // Assert
      expect(result.id, taskId);
      verify(mockLocalDataSource.getCachedTasks()).called(1);
    });

    test('should throw error when getting non-existent task', () async {
      // Arrange
      final taskId = 'non_existent';
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [mockLocalTask]);

      // Act & Assert
      expect(
        () => taskRepository.getTaskById(taskId),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('TaskRepositoryImpl - Pagination', () {
    test('should paginate tasks correctly', () async {
      // Arrange
      final List<Task> tasks = List.generate(20, (index) => Task(
        id: 'task_$index',
        todo: 'Task $index',
        completed: false,
        userId: 1,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
      ));
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => tasks);

      // Act
      final page1 = await taskRepository.getTasks(limit: 5, skip: 0);
      final page2 = await taskRepository.getTasks(limit: 5, skip: 5);
      final page3 = await taskRepository.getTasks(limit: 5, skip: 10);

      // Assert
      expect(page1.tasks.length, 5);
      expect(page2.tasks.length, 5);
      expect(page3.tasks.length, 5);
      expect(page1.tasks.first.id, isNot(equals(page2.tasks.first.id)));
    });

    test('should return empty list when skip exceeds total tasks', () async {
      // Arrange
      final List<Task> tasks = List.generate(5, (index) => Task(
        id: 'task_$index',
        todo: 'Task $index',
        completed: false,
        userId: 1,
        createdAt: DateTime.now(),
      ));
      
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => tasks);

      // Act
      final result = await taskRepository.getTasks(limit: 10, skip: 10);

      // Assert
      expect(result.tasks, isEmpty);
      expect(result.total, 5);
    });
  });
}