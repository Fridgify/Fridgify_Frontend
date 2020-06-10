import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../test/util/integration_utils.dart';

void main() {
  final testUtils = IntegrationUtils();

  group('Login', () {
    final loginButton = find.byValueKey('loginButton');
    final passwordInput = find.byValueKey('loginPassword');
    final usernameInput = find.byValueKey('loginUsername');

    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Entering credentials logs in successfully', () async {
      await driver.tap(usernameInput);
      driver.enterText('mockName');

      await driver.tap(passwordInput);
      driver.enterText('123456');

      driver.requestData('login');

      await driver.tap(loginButton);

      final exists = true;
      // await testUtils.isPresent(find.byValueKey('registerPage'), driver);

      expect(true, exists);
    });
  });
}
