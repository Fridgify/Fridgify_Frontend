import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/service/user_service.dart';
import 'package:fridgify/view/widgets/popup.dart';
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

    bool validToken = false;

    try {
      validToken = await _authService.validateToken();
    }
    catch(exception) {
      logger.e("MainController => Exception while trying to validateToken ${exception.toString()}");
      await Popups.errorPopup(context, exception.toString());
      return false;
    }

    if(validToken) {
      logger.i("MainController => CLIENT TOKEN STILL VALID");

      try {
        await _authService.fetchApiToken();
      }
      catch(exception) {
        if(exception is FailedToFetchApiTokenException) {
          logger.e('MainController => FAILED TO FETCH API TOKEN');
        }
        else {
          logger.e('MainController => ${exception.toString()}');
        }
        Popups.errorPopup(context, exception);
        return false;
      }
    }
    else{
      return false;
    }

    if(!await _authService.initiateRepositories()) {
      return false;
    }

    logger.i('MainController => INIT DONE STARTING WITH CACHED TOKEN');

    return true;
  }
}