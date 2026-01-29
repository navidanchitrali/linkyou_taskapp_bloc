import 'package:shared_preferences/shared_preferences.dart';
import '../../../tasks/domain/entities/task.dart';
import 'dart:convert';

abstract class TaskLocalDataSource {
  Future<List<Task>> getCachedTasks();
  Future<void> cacheTasks(List<Task> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Task>> getCachedTasks() async {
    try {
      final tasksJson = sharedPreferences.getStringList('cached_tasks') ?? [];
      final List<Task> tasks = [];
      
      for (final jsonString in tasksJson) {
        try {
          final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
          final task = Task.fromJson(jsonMap);
          
          if (!task.isDeleted) {
            tasks.add(task);
          }
        } catch (e) {
          continue;
        }
      }
      
      return tasks;
    } catch (e) {
      return <Task>[];
    }
  }

  @override
  Future<void> cacheTasks(List<Task> tasks) async {
    try {
      final List<Task> tasksToSave = tasks.where((task) => !task.isDeleted).toList();
      
      final List<String> tasksJson = tasksToSave.map((task) {
        try {
          return json.encode(task.toJson());
        } catch (e) {
          return '{}';
        }
      }).where((jsonStr) => jsonStr != '{}').toList();
      
      await sharedPreferences.setStringList('cached_tasks', tasksJson);
    } catch (e) {
    }
  }
}