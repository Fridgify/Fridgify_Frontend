import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/model/store.dart';

class Item {
  int itemId;
  String barcode;
  String name;
  String description;
  Store store;


  Item(
      {@required this.itemId,
        @required this.barcode,
        @required this.name,
        @required this.store});

  Item.create({
    this.barcode,
    @required this.name,
    @required this.store,
    this.itemId,
  });

  factory Item.fromJson(dynamic json) {
    StoreRepository _storeRepository = StoreRepository();
    return Item(
        itemId: json['item_id'],
        barcode: json['barcode'],
        name: json['name'],
        store: _storeRepository.get(json['store']));
  }

  @override
  String toString() {
    return "id: $itemId, barcode: $barcode, name: $name, store: $store";
  }
}
