import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../test/util/integration_utils.dart';

void main() {
  final testUtils = IntegrationUtils();

  group('Fridgify', () {
    final registerButton = find.byValueKey('register');
    final buttonFinder = find.byValueKey('increment');

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

    test('pressing on I dont have an account navigates', () async {
      await driver.tap(registerButton);

      final exists =
          await testUtils.isPresent(find.byValueKey('registerPage'), driver);

      expect(true, exists);
    });
  });
}
