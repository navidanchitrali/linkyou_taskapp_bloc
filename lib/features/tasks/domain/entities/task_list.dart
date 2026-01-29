 
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';

class TaskList {
  final List<Task> tasks;
  final int total;
  final int skip;
  final int limit;

  TaskList({
    required this.tasks,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      tasks: (json['todos'] as List<dynamic>?)
              ?.map((taskJson) => Task.fromJson(taskJson))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todos': tasks.map((task) => task.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }
}