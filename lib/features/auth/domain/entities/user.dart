// class User {
//   final String id;
//   final String username;
//   final String email;
//   final String firstName;
//   final String lastName;
//   final String gender;
//   final String image;
//   final String token; // access token
//   final String? refreshToken;  

//   User({
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//     required this.gender,
//     required this.image,
//     required this.token,
//     this.refreshToken,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'].toString(),
//       username: json['username'] ?? '',
//       email: json['email'] ?? '',
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//       gender: json['gender'] ?? '',
//       image: json['image'] ?? '',
//       token: json['accessToken'] ?? json['token'] ?? '',
//       refreshToken: json['refreshToken'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'email': email,
//       'firstName': firstName,
//       'lastName': lastName,
//       'gender': gender,
//       'image': image,
//       'token': token,
//       'refreshToken': refreshToken,
//       'accessToken': token,  
//     };
//   }

//   copyWith({required String firstName, required String lastName, required String token}) {}
// }





import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String token; // access token
  final String? refreshToken;  

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      image: json['image'] ?? '',
      token: json['accessToken'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'token': token,
      'refreshToken': refreshToken,
      'accessToken': token,  
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? token,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    gender,
    image,
    token,
    refreshToken,
  ];
  
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, token: ${token.substring(0, 10)}..., refreshToken: ${refreshToken?.substring(0, 10)}...)';
  }
}