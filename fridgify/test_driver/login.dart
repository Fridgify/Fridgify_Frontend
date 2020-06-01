import 'package:flutter_driver/driver_extension.dart';
import 'package:fridgify/main.dart' as app;

import '../test/util/integration_mock.dart';

void main() {
  // ignore: missing_return
  Future<String> requestHandler(String request) async {
    switch (request) {
      case "login":
        IntegrationMock.login();
        break;
      default:
        throw ArgumentError('Not implemented');
        break;
    }
  }

  enableFlutterDriverExtension(handler: requestHandler);

  app.main();
}
