import 'package:flutter/cupertino.dart';

class Store {
  int storeId;
  String name;

  Store({
    @required this.storeId,
    @required this.name,
  });

  factory Store.fromJson(dynamic json) {
    return Store(storeId: json['store_id'], name: json['name']);
  }

  Store.create({@required this.name});
}
