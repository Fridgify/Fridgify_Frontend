import 'package:fridgify/controller/auth.controller.dart';

class Fridges {
  int id;
  String name;
  String description;
  String content;
  Auth auth;

  Fridges(int id, String name, String description, String content, this.auth) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.content = content;
  }
}