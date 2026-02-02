import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../auth/domain/entities/user.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clear();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    final token = await secureStorage.read(key: _accessTokenKey);
    
    if (token != null && token.isNotEmpty) {
      return token;
    }
    return null;
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    final refreshToken = await secureStorage.read(key: _refreshTokenKey);
    
    if (refreshToken != null && refreshToken.isNotEmpty) {
      return refreshToken;
    }
    return null;
  }

  @override
  Future<void> saveUser(User user) async {
    if (user.token.isNotEmpty) {
      await saveToken(user.token);
    }
    
    if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
      await saveRefreshToken(user.refreshToken!);
    }
    
    final userData = {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'gender': user.gender,
      'image': user.image,
    };
    
    final userJson = json.encode(userData);
    await secureStorage.write(key: _userDataKey, value: userJson);
  }

@override
Future<User?> getUser() async {
  try {
    final userJson = await secureStorage.read(key: _userDataKey);
    
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      
      final token = await getToken();
      
      if (token != null && token.isNotEmpty) {
        final refreshToken = await getRefreshToken();
        
        return User(
          id: userMap['id']?.toString() ?? '0',
          username: userMap['username']?.toString() ?? '',
          email: userMap['email']?.toString() ?? '',
          firstName: userMap['firstName']?.toString() ?? '',
          lastName: userMap['lastName']?.toString() ?? '',
          gender: userMap['gender']?.toString() ?? '',
          image: userMap['image']?.toString() ?? '',
          token: token,
          refreshToken: refreshToken,
        );
      }
    }
  } catch (e) {
    // Handle JSON decoding errors or any other errors
    // Log the error if you have logging set up
    // print('Error getting user from storage: $e');
    
    // Clear invalid data to prevent future errors
    await secureStorage.delete(key: _userDataKey);
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }
  
  return null;
}






// working but commented to avoid issues in tests
  // @override
  // Future<User?> getUser() async {
  //   final userJson = await secureStorage.read(key: _userDataKey);
    
  //   if (userJson != null) {
  //     final userMap = json.decode(userJson) as Map<String, dynamic>;
      
  //     final token = await getToken();
      
  //     if (token != null && token.isNotEmpty) {
  //       final refreshToken = await getRefreshToken();
        
  //       return User(
  //         id: userMap['id']?.toString() ?? '0',
  //         username: userMap['username']?.toString() ?? '',
  //         email: userMap['email']?.toString() ?? '',
  //         firstName: userMap['firstName']?.toString() ?? '',
  //         lastName: userMap['lastName']?.toString() ?? '',
  //         gender: userMap['gender']?.toString() ?? '',
  //         image: userMap['image']?.toString() ?? '',
  //         token: token,
  //         refreshToken: refreshToken,
  //       );
  //     }
  //   }
    
  //   return null;
  // }

  @override
  Future<void> clear() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await secureStorage.delete(key: _userDataKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}