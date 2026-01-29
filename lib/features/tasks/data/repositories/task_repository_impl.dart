import 'dart:async';
import 'dart:math';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_list.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  
  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<TaskList> getTasks({int limit = 10, int skip = 0}) async {
    try {
      final List<Task> localTasks = await getCachedTasks();
      
      if (skip == 0) {
        return await _getInitialTasks(localTasks, limit: limit);
      } else {
        return await _getApiTasksWithPagination(limit: limit, skip: skip);
      }
    } catch (e) {
      final List<Task> localTasks = await getCachedTasks();
      final List<Task> paginatedTasks = _paginateTasks(localTasks, limit: limit, skip: skip);
      
      return TaskList(
        tasks: paginatedTasks,
        total: localTasks.length,
        skip: skip,
        limit: limit,
      );
    }
  }

  Future<TaskList> _getInitialTasks(List<Task> localTasks, {int limit = 10}) async {
    final List<Task> initialLocalTasks = _paginateTasks(localTasks, limit: limit, skip: 0);
    
    try {
      final TaskList apiTaskList = await remoteDataSource.getTasks(limit: limit, skip: 0);
      
      final List<Task> apiAsLocal = apiTaskList.tasks.map((apiTask) {
        return Task(
          id: 'api_${apiTask.id}',
          todo: apiTask.todo,
          completed: apiTask.completed,
          userId: apiTask.userId,
          createdAt: DateTime.now(),
          serverId: apiTask.id,
          isLocal: false,
          isSynced: true,
          isDeleted: false,
        );
      }).toList();
      
      final List<Task> allTasks = _mergeTasks(apiAsLocal, localTasks);
      await cacheTasks(allTasks);
      
      return TaskList(
        tasks: initialLocalTasks,
        total: allTasks.length,
        skip: 0,
        limit: limit,
      );
    } catch (e) {
      return TaskList(
        tasks: initialLocalTasks,
        total: localTasks.length,
        skip: 0,
        limit: limit,
      );
    }
  }

  Future<TaskList> _getApiTasksWithPagination({int limit = 10, int skip = 0}) async {
    try {
      final TaskList apiTaskList = await remoteDataSource.getTasks(limit: limit, skip: skip);
      
      final List<Task> apiAsLocal = apiTaskList.tasks.map((apiTask) {
        return Task(
          id: 'api_${apiTask.id}',
          todo: apiTask.todo,
          completed: apiTask.completed,
          userId: apiTask.userId,
          createdAt: DateTime.now(),
          serverId: apiTask.id,
          isLocal: false,
          isSynced: true,
          isDeleted: false,
        );
      }).toList();
      
      final List<Task> localTasks = await getCachedTasks();
      final List<Task> mergedTasks = _mergeTasks(apiAsLocal, localTasks);
      await cacheTasks(mergedTasks);
      
      return TaskList(
        tasks: apiAsLocal,
        total: apiTaskList.total + localTasks.length,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      final List<Task> localTasks = await getCachedTasks();
      final List<Task> paginatedTasks = _paginateTasks(localTasks, limit: limit, skip: skip);
      
      return TaskList(
        tasks: paginatedTasks,
        total: localTasks.length,
        skip: skip,
        limit: limit,
      );
    }
  }

  List<Task> _mergeTasks(List<Task> newTasks, List<Task> existingTasks) {
    final Map<String, Task> merged = {};
    
    for (final task in existingTasks) {
      final key = '${task.todo}_${task.userId}';
      merged[key] = task;
    }
    
    for (final task in newTasks) {
      final key = '${task.todo}_${task.userId}';
      merged[key] = task;
    }
    
    return merged.values.toList();
  }

  List<Task> _paginateTasks(List<Task> tasks, {int limit = 10, int skip = 0}) {
    final int start = skip;
    final int end = min(skip + limit, tasks.length);
    
    if (start >= tasks.length) {
      return <Task>[];
    }
    
    return tasks.sublist(start, end);
  }

  @override
  Future<List<Task>> getCachedTasks() async {
    final allTasks = await localDataSource.getCachedTasks();
    return allTasks.where((task) => !task.isDeleted).toList();
  }

  @override
  Future<void> cacheTasks(List<Task> tasks) async {
    await localDataSource.cacheTasks(tasks);
  }

  @override
  Future<Task> addTask(String todo, bool completed, int userId) async {
    final localId = _generateLocalId();
    
    final task = Task(
      id: localId,
      todo: todo,
      completed: completed,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isLocal: true,
      isSynced: false,
      isDeleted: false,
    );
    
    final List<Task> cachedTasks = await getCachedTasks();
    final List<Task> updatedTasks = [task, ...cachedTasks];
    await cacheTasks(updatedTasks);
    
    return task;
  }

@override
Future<Task> updateTask(Task task) async {
  final updatedTask = task.copyWith(
    updatedAt: DateTime.now(),
  );
  
  final List<Task> cachedTasks = await getCachedTasks();
  final List<Task> updatedTasks = cachedTasks.map((t) => 
      t.id == task.id ? updatedTask : t).toList();
  
  await cacheTasks(updatedTasks);
  
  return updatedTask;
}

  @override
  Future<void> deleteTask(String id) async {
    final List<Task> cachedTasks = await getCachedTasks();
    final taskIndex = cachedTasks.indexWhere((t) => t.id == id);
    
    if (taskIndex != -1) {
      final Task task = cachedTasks[taskIndex];
      final Task deletedTask = task.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      
      final List<Task> updatedTasks = List<Task>.from(cachedTasks);
      updatedTasks[taskIndex] = deletedTask;
      
      await cacheTasks(updatedTasks);
    }
  }

  String _generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
  }

  @override
  Future<Task> getTaskById(String id) async {
    final List<Task> cachedTasks = await getCachedTasks();
    return cachedTasks.firstWhere((task) => task.id == id);
  }
}