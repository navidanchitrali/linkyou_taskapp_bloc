import '../../domain/entities/task_list.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<TaskList> getTasks({int limit = 10, int skip = 0});
  Future<Task> getTaskById(String id);
  Future<Task> addTask(String todo, bool completed, int userId);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);  
  Future<List<Task>> getCachedTasks();
  Future<void> cacheTasks(List<Task> tasks);
}