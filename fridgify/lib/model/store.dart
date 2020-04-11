import 'package:flutter/cupertino.dart';

class Store {
  int storeId;
  String name;

  Store({
   @required this.storeId,
   @required this.name,
  });

  Store.create({
    @required this.name
  });
}