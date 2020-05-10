import 'package:flutter/cupertino.dart';

class User {
  String username;
  String password;
  String name;
  String surname;
  String email;
  String birthDate;

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
  });

  @override
  String toString() {
    return "username: $username, password: $password, name: $name, surname: $surname,"
        " email: $email, birthDate: $birthDate";
  }
}
