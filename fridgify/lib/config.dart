import 'package:logger/logger.dart';

class Config {
  static const String API = "https://fridgapi-dev.donkz.dev";

  static const String LOGIN = "/auth/login/";

  static const String REGISTER = "/auth/register/";

  static const String TOKEN = "/auth/token/";

  static const String FRIDGE = "/fridge/";

  static const String CREATE_FRIDGE = "/fridge/management/create/";

  static Logger logger = Logger();
}