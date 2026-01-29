 

import 'package:equatable/equatable.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskListEvent {}

class LoadMoreTasks extends TaskListEvent {}

class RefreshTasks extends TaskListEvent {}

class TaskCompletedToggled extends TaskListEvent {
  final Task task;

  const TaskCompletedToggled({required this.task});

  @override
  List<Object> get props => [task];
}

class DeleteTaskFromList extends TaskListEvent {
  final String taskId;

  const DeleteTaskFromList({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class AddTaskToList extends TaskListEvent {
  final String todo;
  final int userId;

  const AddTaskToList({required this.todo, required this.userId});

  @override
  List<Object> get props => [todo, userId];
}

class UpdateTaskInList extends TaskListEvent {
  final Task task;

  const UpdateTaskInList({required this.task});

  @override
  List<Object> get props => [task];
}

class ClearAllTasks extends TaskListEvent {}

class EditTaskInList extends TaskListEvent {
  final String taskId;
  final String newTodo;

  EditTaskInList({required this.taskId, required this.newTodo});

  @override
  List<Object> get props => [taskId, newTodo];
}