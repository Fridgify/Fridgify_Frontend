import 'package:flutter_driver/flutter_driver.dart';

class IntegrationUtils {
  isPresent(SerializableFinder byValueKey, FlutterDriver driver,
      {Duration timeout = const Duration(seconds: 2)}) async {
    try {
      await driver.waitFor(byValueKey, timeout: timeout);
      return true;
    } catch (exception) {
      return false;
    }
  }
}
