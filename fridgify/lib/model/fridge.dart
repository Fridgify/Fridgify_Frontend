import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/content_repository.dart';
import 'package:fridgify/model/user.dart';

class Fridge {
  int fridgeId;
  String name;
  String description;
  Map<String, dynamic> content;
  List<User> member = List();

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

  Map<String, double> contentForPieChart() {
    return {
      'Fresh': this.content['fresh'].toDouble(),
      'Due soon': this.content['dueSoon'].toDouble(),
      'Over due': this.content['overDue'].toDouble(),
    };
  }
}
