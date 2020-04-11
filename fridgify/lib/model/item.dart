import 'package:flutter/cupertino.dart';
import 'package:fridgify/model/store.dart';

class Item {
  int itemId;
  String barcode;
  String name;
  String description;
  Store store;

  Item({
    @required this.itemId,
    @required this.barcode,
    @required this.name,
    @required this.description,
    @required this.store
  });
}