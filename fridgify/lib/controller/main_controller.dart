import 'package:flutter/cupertino.dart';
import 'package:fridgify/data/repository.dart';
import 'package:fridgify/exception/failed_to_fetch_api_token_exception.dart';
import 'package:fridgify/service/auth_service.dart';
import 'package:fridgify/utils/logger.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController {
  Logger _logger = Logger('MainController');

  AuthenticationService _authService = AuthenticationService();


  Future<bool> initialLaunch(BuildContext context) async {
    _logger.i("INITIAL LAUNCH!");


    Repository.sharedPreferences = await SharedPreferences.getInstance();
    
    if(!Repository.sharedPreferences.containsKey('clientToken')) {
      return false;
    }

    _logger.i("FOUND CLIENT TOKEN: ${Repository.sharedPreferences.get('clientToken')}");

    bool validToken = false;

    try {
      validToken = await _authService.validateToken();
    }
    catch(exception) {
      _logger.e("Exception while trying to validateToken ${exception.toString()}");
      await Popups.errorPopup(context, exception.toString());
      return false;
    }

    if(validToken) {
      _logger.i("CLIENT TOKEN STILL VALID");

      try {
        await _authService.fetchApiToken();
      }
      catch(exception) {
        if(exception is FailedToFetchApiTokenException) {
          _logger.e('FAILED TO FETCH API TOKEN');
        }
        else {
          _logger.e('${exception.toString()}');
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

    _logger.i('INIT DONE STARTING WITH CACHED TOKEN');

    return true;
  }
}