import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/content_repository.dart';

class Fridge {
  int fridgeId;
  String name;
  String description;
  Map<String, dynamic> content;

  ContentRepository contentRepository;

  Fridge({
    @required this.fridgeId,
    @required this.name,
    @required this.description,
    @required this.content,
  });

  Fridge.create({
    this.fridgeId,
    @required this.name,
    this.description = "",
  });
}