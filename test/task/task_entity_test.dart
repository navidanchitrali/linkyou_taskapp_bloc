import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task.dart';
import 'package:linkyou_tasks_app/features/tasks/domain/entities/task_list.dart';
 

void main() {
  group('Task Entity', () {
    test('should create Task from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'todo': 'Test Task',
        'completed': false,
        'userId': 1,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Act
      final task = Task.fromJson(json);

      // Assert
      expect(task.id, '1');
      expect(task.todo, 'Test Task');
      expect(task.completed, false);
      expect(task.userId, 1);
    });

    test('should convert Task to JSON', () {
      // Arrange
      final task = Task(
        id: '1',
        todo: 'Test Task',
        completed: false,
        userId: 1,
        createdAt: DateTime.now(),
      );

      // Act
      final json = task.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['todo'], 'Test Task');
      expect(json['completed'], false);
      expect(json['userId'], 1);
    });

    test('should copy Task with new values', () {
      // Arrange
      final original = Task(
        id: '1',
        todo: 'Original Task',
        completed: false,
        userId: 1,
        createdAt: DateTime.now(),
      );

      // Act
      final copied = original.copyWith(
        todo: 'Updated Task',
        completed: true,
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(copied.id, original.id);
      expect(copied.todo, 'Updated Task');
      expect(copied.completed, true);
      expect(copied.userId, original.userId);
      expect(copied.createdAt, original.createdAt);
      expect(copied.updatedAt, isNotNull);
    });

    test('should compare Tasks for equality', () {
      // Arrange
      final task1 = Task(
        id: '1',
        todo: 'Task',
        completed: false,
        userId: 1,
        createdAt: DateTime.now(),
      );

      final task2 = Task(
        id: '1',
        todo: 'Task',
        completed: false,
        userId: 1,
        createdAt: task1.createdAt,
      );

      final task3 = Task(
        id: '2',
        todo: 'Different Task',
        completed: true,
        userId: 2,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(task1, equals(task2));
      expect(task1, isNot(equals(task3)));
      expect(task1.hashCode, equals(task2.hashCode));
    });
  });

  group('TaskList Entity', () {
    test('should create TaskList from JSON', () {
      // Arrange
      final json = {
        'todos': [
          {
            'id': '1',
            'todo': 'Task 1',
            'completed': false,
            'userId': 1,
          },
          {
            'id': '2',
            'todo': 'Task 2',
            'completed': true,
            'userId': 1,
          },
        ],
        'total': 2,
        'skip': 0,
        'limit': 10,
      };

      // Act
      final taskList = TaskList.fromJson(json);

      // Assert
      expect(taskList.tasks.length, 2);
      expect(taskList.total, 2);
      expect(taskList.skip, 0);
      expect(taskList.limit, 10);
    });

    test('should convert TaskList to JSON', () {
      // Arrange
      final tasks = [
        Task(
          id: '1',
          todo: 'Task 1',
          completed: false,
          userId: 1,
          createdAt: DateTime.now(),
        ),
        Task(
          id: '2',
          todo: 'Task 2',
          completed: true,
          userId: 1,
          createdAt: DateTime.now(),
        ),
      ];

      final taskList = TaskList(
        tasks: tasks,
        total: 2,
        skip: 0,
        limit: 10,
      );

      // Act
      final json = taskList.toJson();

      // Assert
      expect(json['todos'], isA<List>());
      expect(json['total'], 2);
      expect(json['skip'], 0);
      expect(json['limit'], 10);
    });
  });
}