
import 'package:fridgify/exceptions/failed_to_fetch_fridges_exception.dart';
import 'package:http/http.dart';

import '../config.dart';

class FridgeModel {
  String token;

  FridgeModel(String token) {
    this.token = token;
  }
  
  
  Future<String> fetchFridges() async {
    var response = await get(Config.API + Config.FRIDGE, headers: {"Authorization": this.token});
    Config.logger.i("Fetching Fridges: ${response.statusCode}");
    if(response.statusCode >= 400)
      throw new FailedToFetchFridgesException();
    return response.body;
  }
}