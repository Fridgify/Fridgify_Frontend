import 'package:flutter/cupertino.dart';

class User {
  String username;
  String password;
  String name;
  String surname;
  String email;
  String birthDate;
  int userId;

  User.newUser({
    @required this.username,
    @required this.password,
    @required this.name,
    @required this.surname,
    @required this.email,
    @required this.birthDate,
  });

  User.loginUser({
    @required this.username,
    @required this.password,
    this.name = "",
    this.surname = "",
    this.email = "",
    this.birthDate = "",
  });

  User.noPassword({
    @required this.username,
    this.password = "",
    @required this.name,
    @required this.surname,
    @required this.email,
    @required this.birthDate,
    this.userId,
  });

  factory User.fromJson(dynamic json) {
    return User.noPassword(
      username: json['username'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      birthDate: json['birth_date'],
      userId: json['user_id'],
    );
  }

  @override
  String toString() {
    return "username: $username, password: $password, name: $name, surname: $surname,"
        " email: $email, birthDate: $birthDate, id $userId";
  }
}
