import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final TaskRepository taskRepository;
  final int itemsPerPage = 10;

  List<Task> _loadedTasks = [];
  bool _hasMore = true;
  int _totalTasks = 0;

  TaskListBloc({required this.taskRepository}) : super(TaskListInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadMoreTasks>(_onLoadMoreTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<TaskCompletedToggled>(_onTaskCompletedToggled);
    on<DeleteTaskFromList>(_onDeleteTaskFromList);
    on<AddTaskToList>(_onAddTaskToList);
    on<UpdateTaskInList>(_onUpdateTaskInList);
     on<EditTaskInList>(_onEditTaskInList);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoading) {
      return;
    }

    emit(TaskListLoading());

    try {
      _loadedTasks.clear();
      _hasMore = true;
      _totalTasks = 0;

      final taskList = await taskRepository.getTasks(
        limit: itemsPerPage,
        skip: 0,
      );

      _loadedTasks = taskList.tasks;
      _totalTasks = taskList.total;
      _hasMore = _loadedTasks.length < _totalTasks;

      emit(
        TaskListLoaded(
          tasks: _loadedTasks,
          hasMore: _hasMore,
          totalTasks: _totalTasks,
        ),
      );
    } catch (e) {
      emit(TaskListError(message: 'Failed to load tasks'));
    }
  }

  Future<void> _onLoadMoreTasks(
    LoadMoreTasks event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;

      if (!_hasMore) return;

      emit(
        TaskListLoadingMore(
          tasks: currentState.tasks,
          hasMore: currentState.hasMore,
          totalTasks: currentState.totalTasks,
        ),
      );

      try {
        final skip = currentState.tasks.length;
        final taskList = await taskRepository.getTasks(
          limit: itemsPerPage,
          skip: skip,
        );

        if (taskList.tasks.isNotEmpty) {
          final List<Task> allTasks = [
            ...currentState.tasks,
            ...taskList.tasks,
          ];
          _loadedTasks = allTasks;
          _totalTasks = taskList.total;
          _hasMore = allTasks.length < _totalTasks;

          emit(
            TaskListLoaded(
              tasks: allTasks,
              hasMore: _hasMore,
              totalTasks: _totalTasks,
            ),
          );
        } else {
          _hasMore = false;
          emit(
            TaskListLoaded(
              tasks: currentState.tasks,
              hasMore: false,
              totalTasks: currentState.totalTasks,
            ),
          );
        }
      } catch (e) {
        emit(
          TaskListLoaded(
            tasks: currentState.tasks,
            hasMore: currentState.hasMore,
            totalTasks: currentState.totalTasks,
          ),
        );
      }
    }
  }

  
  Future<void> _onEditTaskInList(EditTaskInList event, Emitter<TaskListState> emit) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;
      
      try {
        // Find the task to update
        final taskToUpdate = currentState.tasks.firstWhere((task) => task.id == event.taskId);
        
        // Create updated task
        final updatedTask = taskToUpdate.copyWith(
          todo: event.newTodo,
          updatedAt: DateTime.now(),
        );
        
        // Update in repository
        await taskRepository.updateTask(updatedTask);
        
        // Update in local list
        final updatedTasks = currentState.tasks.map((task) {
          return task.id == event.taskId ? updatedTask : task;
        }).toList();
        
        _loadedTasks = updatedTasks;
        
        emit(TaskListLoaded(
          tasks: updatedTasks,
          hasMore: currentState.hasMore,
          totalTasks: currentState.totalTasks,
        ));
      } catch (e) {
        emit(TaskListError(message: 'Failed to edit task'));
        emit(currentState);
      }
    }}

  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;
      emit(
        TaskListRefreshing(
          tasks: currentState.tasks,
          hasMore: currentState.hasMore,
          totalTasks: currentState.totalTasks,
        ),
      );
    }

    try {
      _loadedTasks.clear();
      _hasMore = true;
      _totalTasks = 0;

      final taskList = await taskRepository.getTasks(
        limit: itemsPerPage,
        skip: 0,
      );

      _loadedTasks = taskList.tasks;
      _totalTasks = taskList.total;
      _hasMore = _loadedTasks.length < _totalTasks;

      emit(
        TaskListLoaded(
          tasks: _loadedTasks,
          hasMore: _hasMore,
          totalTasks: _totalTasks,
        ),
      );
    } catch (e) {
      if (state is TaskListRefreshing) {
        final currentState = state as TaskListRefreshing;
        if (currentState.tasks != null) {
          emit(
            TaskListLoaded(
              tasks: currentState.tasks!,
              hasMore: currentState.hasMore,
              totalTasks: currentState.totalTasks,
            ),
          );
        }
      }
    }
  }

  Future<void> _onTaskCompletedToggled(
    TaskCompletedToggled event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;

      try {
        final updatedTask = event.task.copyWith(
          completed: !event.task.completed,
        );

        await taskRepository.updateTask(updatedTask);

        final updatedTasks = currentState.tasks.map((task) {
          return task.id == event.task.id ? updatedTask : task;
        }).toList();

        _loadedTasks = updatedTasks;

        emit(
          TaskListLoaded(
            tasks: updatedTasks,
            hasMore: currentState.hasMore,
            totalTasks: currentState.totalTasks,
          ),
        );
      } catch (e) {
        emit(TaskListError(message: 'Failed to toggle task completion'));
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteTaskFromList(
    DeleteTaskFromList event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;

      final updatedTasks = currentState.tasks
          .where((task) => task.id != event.taskId)
          .toList();
      _loadedTasks = updatedTasks;
      _totalTasks = updatedTasks.length;

      emit(
        TaskListLoaded(
          tasks: updatedTasks,
          hasMore: currentState.hasMore,
          totalTasks: updatedTasks.length,
        ),
      );

      try {
        await taskRepository.deleteTask(event.taskId);
      } catch (e) {
        add(RefreshTasks());
      }
    }
  }

  Future<void> _onAddTaskToList(
    AddTaskToList event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;

      try {
        await taskRepository.addTask(event.todo, false, event.userId);
        add(RefreshTasks());
      } catch (e) {
        emit(TaskListError(message: 'Failed to add task'));
        emit(currentState);
      }
    } else {
      add(LoadTasks());
    }
  }

  Future<void> _onUpdateTaskInList(
    UpdateTaskInList event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is TaskListLoaded) {
      final currentState = state as TaskListLoaded;

      try {
        await taskRepository.updateTask(event.task);
        add(RefreshTasks());
      } catch (e) {
        emit(TaskListError(message: 'Failed to update task'));
        emit(currentState);
      }
    }
  }

  List<Task> get allTasks => List.unmodifiable(_loadedTasks);
  bool get hasMore => _hasMore;
}