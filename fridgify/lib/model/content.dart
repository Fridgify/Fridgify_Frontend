import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/utils/item_state_helper.dart';
import 'package:logger/logger.dart';

import 'fridge.dart';
import 'item.dart';

class Content {
  String contentId;
  String expirationDate;
  int amount;
  int count;
  int maxAmount;
  String unit;
  Fridge fridge;
  Item item;
  ItemState state;

  Logger _logger = Logger();


  factory Content.fromJson(dynamic json, Fridge f) {
    return Content(
      contentId: json['content_id'],
      expirationDate: json['expiration_date'],
      amount: json['amount'],
      maxAmount: json['max_amount'],
      unit: json['unit'],
      fridge:f,
      item: ItemRepository().get(json['item_id']),
    );
  }

  Content({
    @required this.contentId,
    @required this.expirationDate,
    @required this.amount,
    @required this.maxAmount,
    @required this.unit,
    @required this.item,
    @required this.fridge,
  }) {
    setItemState();
  }

  Content.create({
    this.contentId,
    @required this.count,
    @required this.expirationDate,
    @required this.amount,
    @required this.unit,
    @required this.item,
  }) {
    this.maxAmount = this.amount;
    setItemState();
  }

  void setItemState() {
    var date = DateTime.parse(this.expirationDate);
    if(this.item == null)
    {
      _logger.e("CONTENTMODEL -> ITEM NOT FOUND ERROR");
      return;
    }
    _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item.name} ${this.item.barcode} AND DATE: $date / ${this.expirationDate}');

    if(date.isAfter(DateTime.now().add(Duration(days: 5)))) {
      _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} FRESH');
      this.state = ItemState.fresh;
    }
    else if(date.isBefore(DateTime.now().add(Duration(days: 5))) && date.isAfter(DateTime.now())) {
      _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} DUE SOON');
      this.state = ItemState.dueSoon;
    }
    else {
      _logger.i('CONTENTMODEL -> SET ITEMSTATE FOR ITEM ${this.item} OVER DUE');
      this.state = ItemState.overDue;
    }
  }

  @override
  String toString() {
    var date = DateTime.now();
    return jsonEncode({
      "name": this.item != null ? this.item.name : "",
      "buy_date": "${date.year}-${date.month < 10 ? "0${date.month}" : date.month}-${date.day}",
      "expiration_date": this.expirationDate,
      "count": this.count,
      "amount": this.amount,
      "unit": this.unit,
      "store": this.item != null ? this.item.store.name : "",
      "content_id": this.contentId != null ? this.contentId : "",
      "barcode": this.item != null ? this.item.barcode ?? "" : "",
    });
  }
}
