import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task_list.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_bloc.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_event.dart';
import 'package:linkyou_tasks_app/features/tasks/presentation/bloc/task_list/task_list_state.dart';
 import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'task_list_bloc_test.mocks.dart';
 

@GenerateMocks([TaskRepository])
void main() {
  late MockTaskRepository mockTaskRepository;
  late TaskListBloc taskListBloc;

  final Task mockTask = Task(
    id: '1',
    todo: 'Test Task',
    completed: false,
    userId: 1,
    createdAt: DateTime.now(),
  );

  final TaskList mockTaskList = TaskList(
    tasks: List.generate(10, (index) => Task(
      id: 'task_$index',
      todo: 'Task $index',
      completed: false,
      userId: 1,
      createdAt: DateTime.now().subtract(Duration(hours: index)),
    )),
    total: 30,
    skip: 0,
    limit: 10,
  );

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    taskListBloc = TaskListBloc(taskRepository: mockTaskRepository);
  });

  tearDown(() {
    taskListBloc.close();
  });

  group('TaskListBloc', () {
    blocTest<TaskListBloc, TaskListState>(
      'should emit [TaskListLoading, TaskListLoaded] when LoadTasks is added',
      build: () {
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => mockTaskList);
        return taskListBloc;
      },
      act: (bloc) => bloc.add(LoadTasks()),
      expect: () => [
        isA<TaskListLoading>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'tasks length', 10)
          .having((state) => state.hasMore, 'hasMore', true),
      ],
      verify: (_) {
        verify(mockTaskRepository.getTasks(limit: 10, skip: 0)).called(1);
      },
    );

    blocTest<TaskListBloc, TaskListState>(
      'should emit [TaskListError] when LoadTasks fails',
      build: () {
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenThrow(Exception('Failed to load tasks'));
        return taskListBloc;
      },
      act: (bloc) => bloc.add(LoadTasks()),
      expect: () => [
        isA<TaskListLoading>(),
        isA<TaskListError>()
          .having((state) => state.message, 'message', 'Failed to load tasks'),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'should load more tasks when LoadMoreTasks is added',
      build: () {
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => mockTaskList);
        
        final secondPageTasks = TaskList(
          tasks: List.generate(10, (index) => Task(
            id: 'task_${index + 10}',
            todo: 'Task ${index + 10}',
            completed: false,
            userId: 1,
            createdAt: DateTime.now().subtract(Duration(hours: index + 10)),
          )),
          total: 30,
          skip: 10,
          limit: 10,
        );
        
        when(mockTaskRepository.getTasks(limit: 10, skip: 10))
            .thenAnswer((_) async => secondPageTasks);
        
        return taskListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadTasks());
        await Future.delayed(Duration.zero);
        bloc.add(LoadMoreTasks());
      },
      expect: () => [
        isA<TaskListLoading>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'initial tasks length', 10),
        isA<TaskListLoadingMore>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'total tasks length', 20),
      ],
      verify: (_) {
        verify(mockTaskRepository.getTasks(limit: 10, skip: 0)).called(1);
        verify(mockTaskRepository.getTasks(limit: 10, skip: 10)).called(1);
      },
    );

    blocTest<TaskListBloc, TaskListState>(
      'should not load more tasks when hasMore is false',
      build: () {
        final smallTaskList = TaskList(
          tasks: [mockTask],
          total: 1,
          skip: 0,
          limit: 10,
        );
        
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => smallTaskList);
        
        return taskListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadTasks());
        await Future.delayed(Duration.zero);
        bloc.add(LoadMoreTasks());
      },
      expect: () => [
        isA<TaskListLoading>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'tasks length', 1)
          .having((state) => state.hasMore, 'hasMore', false),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'should toggle task completion',
      build: () {
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => TaskList(
                  tasks: [mockTask],
                  total: 1,
                  skip: 0,
                  limit: 10,
                ));
        
        final updatedTask = mockTask.copyWith(completed: true);
        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async => updatedTask);
        
        return taskListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadTasks());
        await Future.delayed(Duration.zero);
        
        if (bloc.state is TaskListLoaded) {
          final state = bloc.state as TaskListLoaded;
          bloc.add(TaskCompletedToggled(task: state.tasks.first));
        }
      },
      expect: () => [
        isA<TaskListLoading>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.first.completed, 'task completed', false),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.first.completed, 'task completed', true),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'should delete task from list',
      build: () {
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => TaskList(
                  tasks: [mockTask, mockTask.copyWith(id: '2')],
                  total: 2,
                  skip: 0,
                  limit: 10,
                ));
        
        when(mockTaskRepository.deleteTask('1'))
            .thenAnswer((_) async => Future.value());
        
        return taskListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadTasks());
        await Future.delayed(Duration.zero);
        bloc.add(DeleteTaskFromList(taskId: '1'));
      },
      expect: () => [
        isA<TaskListLoading>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'initial tasks length', 2),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'after delete tasks length', 1),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'should refresh tasks',
      build: () {
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => mockTaskList);
        
        return taskListBloc;
      },
      seed: () => TaskListLoaded(
        tasks: [mockTask],
        hasMore: false,
        totalTasks: 1,
      ),
      act: (bloc) => bloc.add(RefreshTasks()),
      expect: () => [
        isA<TaskListRefreshing>(),
        isA<TaskListLoaded>()
          .having((state) => state.tasks.length, 'refreshed tasks length', 10),
      ],
    );

    blocTest<TaskListBloc, TaskListState>(
      'should add task and refresh',
      build: () {
        when(mockTaskRepository.addTask('New Task', false, 1))
            .thenAnswer((_) async => mockTask.copyWith(todo: 'New Task'));
        
        when(mockTaskRepository.getTasks(limit: 10, skip: 0))
            .thenAnswer((_) async => mockTaskList);
        
        return taskListBloc;
      },
      seed: () => TaskListLoaded(
        tasks: [mockTask],
        hasMore: false,
        totalTasks: 1,
      ),
      act: (bloc) => bloc.add(AddTaskToList(todo: 'New Task', userId: 1)),
      expect: () => [
        isA<TaskListRefreshing>(),
        isA<TaskListLoaded>(),
      ],
      verify: (_) {
        verify(mockTaskRepository.addTask('New Task', false, 1)).called(1);
        verify(mockTaskRepository.getTasks(limit: 10, skip: 0)).called(1);
      },
    );
  });
}