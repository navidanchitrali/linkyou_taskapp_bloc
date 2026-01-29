 

import 'package:equatable/equatable.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';


 

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object> get props => [];
}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListLoadingMore extends TaskListState {
  final List<Task> tasks;
  final bool hasMore;
  final int totalTasks;

  const TaskListLoadingMore({
    required this.tasks,
    required this.hasMore,
    required this.totalTasks,
  });

  @override
  List<Object> get props => [tasks, hasMore, totalTasks];
}

class TaskListRefreshing extends TaskListState {
  final List<Task>? tasks;
  final bool hasMore;
  final int totalTasks;

  const TaskListRefreshing({
    this.tasks,
    this.hasMore = true,
    this.totalTasks = 0,
  });

  @override
  List<Object> get props => [
        if (tasks != null) tasks!,
        hasMore,
        totalTasks,
      ];
}

class TaskListLoaded extends TaskListState {
  final List<Task> tasks;
  final bool hasMore;
  final int totalTasks;

  const TaskListLoaded({
    required this.tasks,
    required this.hasMore,
    required this.totalTasks,
  });

  @override
  List<Object> get props => [tasks, hasMore, totalTasks];
}

class TaskListError extends TaskListState {
  final String message;

  const TaskListError({required this.message});

  @override
  List<Object> get props => [message];
}