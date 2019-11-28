import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:gherkin/gherkin.dart';

class ThenISeeScreen extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(input1) async {
    final locator = find.byTooltip(input1);
    await FlutterDriverUtils.waitForFlutter(world.driver);
    await FlutterDriverUtils.isPresent(locator, world.driver);
  }

  @override
  RegExp get pattern => RegExp(r"I see screen {string}");
}


class GivenISeeScreen extends Given1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(input1) async {
    final locator = find.byTooltip(input1);
    await FlutterDriverUtils.waitForFlutter(world.driver);
    await FlutterDriverUtils.isPresent(locator, world.driver);
  }

  @override
  RegExp get pattern => RegExp(r"I see screen {string}");
}

class ThenISeePopup extends Given1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(input1) async {
    final locator = find.byTooltip(input1);
    await FlutterDriverUtils.waitForFlutter(world.driver);
    await FlutterDriverUtils.isPresent(locator, world.driver);
  }

  @override
  RegExp get pattern => RegExp(r"I see popup {string}");
}