import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/fridge_repository.dart';
import 'package:fridgify/data/item_repository.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/data/store_repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/model/item.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/view/widgets/loader.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController {
  Logger logger = Logger();

  AuthenticationService _authService = AuthenticationService();


  Future<bool> initialLaunch(BuildContext context) async {
    logger.i("MainController => INITIAL LAUNCH!");


    Repository.sharedPreferences = await SharedPreferences.getInstance();
    
    if(!Repository.sharedPreferences.containsKey('clientToken')) {
      return false;
    }

    logger.i("MainController => FOUND CLIENT TOKEN: ${Repository.sharedPreferences.get('clientToken')}");


    if(await _authService.validateToken()) {
      logger.i("MainController => CLIENT TOKEN STILL VALID");

      try {
        await _authService.fetchApiToken();
      }
      catch(exception) {
        if(exception is FailedToFetchApiTokenException) {
          logger.e('MainController => FAILED TO FETCH API TOKEN');
        }
        else {
          logger.e('MainController => $exception');
        }
        return false;
      }
    }

    if(!await _authService.initiateRepositories()) {
      return false;
    }


    logger.e('MainController => INIT DONE STARTING WITH CACHED TOKEN');

    return true;
  }
}