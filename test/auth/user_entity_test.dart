import 'package:flutter_test/flutter_test.dart';
import 'package:linkyou_tasks_app/features/auth/domain/entities/user.dart';
 
void main() {
  group('User Entity', () {
    test('should create User from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'gender': 'male',
        'image': 'image_url',
        'token': 'access_token_123',
        'refreshToken': 'refresh_token_123',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, '1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'Test');
      expect(user.lastName, 'User');
      expect(user.gender, 'male');
      expect(user.image, 'image_url');
      expect(user.token, 'access_token_123');
      expect(user.refreshToken, 'refresh_token_123');
    });

    test('should handle null refreshToken in JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'gender': 'male',
        'image': 'image_url',
        'token': 'access_token_123',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.refreshToken, isNull);
    });

    test('should convert User to JSON', () {
      // Arrange
      final user = User(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'image_url',
        token: 'access_token_123',
        refreshToken: 'refresh_token_123',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'Test');
      expect(json['lastName'], 'User');
      expect(json['gender'], 'male');
      expect(json['image'], 'image_url');
    });

    test('should copy User with new values', () {
      // Arrange
      final original = User(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'image_url',
        token: 'access_token_123',
        refreshToken: 'refresh_token_123',
      );

      // Act
      final copied = original.copyWith(
        firstName: 'Updated',
        lastName: 'Name',
        token: 'new_token_456',
      );

      // Assert
      expect(copied.id, original.id);
      expect(copied.username, original.username);
      expect(copied.firstName, 'Updated');
      expect(copied.lastName, 'Name');
      expect(copied.token, 'new_token_456');
      expect(copied.refreshToken, original.refreshToken);
    });

    test('should compare Users for equality', () {
      // Arrange
      final user1 = User(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'image_url',
        token: 'access_token_123',
        refreshToken: 'refresh_token_123',
      );

      final user2 = User(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'image_url',
        token: 'access_token_123',
        refreshToken: 'refresh_token_123',
      );

      final user3 = User(
        id: '2',
        username: 'different',
        email: 'different@example.com',
        firstName: 'Different',
        lastName: 'User',
        gender: 'female',
        image: 'different_url',
        token: 'different_token',
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should have valid toString representation', () {
      // Arrange
      final user = User(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'image_url',
        token: 'access_token_123',
      );

      // Act
      final stringRep = user.toString();

      // Assert
      expect(stringRep, contains('User'));
      expect(stringRep, contains('testuser'));
      expect(stringRep, contains('Test User'));
    });
  });
}