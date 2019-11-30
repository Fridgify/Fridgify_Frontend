
import 'dart:convert';

import 'package:fridgify/controller/auth.controller.dart';

class Content {
  int id;
  int amount;
  String name;
  String description;
  String store;
  String unit;
  DateTime buyDate;
  String expirationDate;
  Auth auth;
  int fId;

  Content.withId(this.id, this.name, this.description, this.amount, this.unit,
      this.expirationDate, this.auth, this.fId);

  Content(this.name, this.store, this.description, this.amount, this.unit, this.buyDate,
      this.expirationDate);

  getJson() {
    return jsonEncode({
      "name": this.name,
      "description": this.description,
      "store": this.store,
      "amount": this.amount,
      "unit": this.unit,
      "buy_date": this.buyDate.toString(),
      "expiration_date": this.expirationDate.toString()
    });
  }
}