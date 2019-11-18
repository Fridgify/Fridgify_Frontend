import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

class TapButtonByTooltipNTimesStep extends When2WithWorld<String, int, FlutterWorld> {
  TapButtonByTooltipNTimesStep()
    : super(StepDefinitionConfiguration()..timeout = Duration(seconds: 10));

  @override
  Future<void> executeStep(String input1, int input2) async {
    final locator = find.byTooltip(input1);
    for (var i = 0; i < input2; i++) {

      await FlutterDriverUtils.tap(world.driver, locator, timeout: timeout);
    }
  }

  @override
  RegExp get pattern => RegExp(r"I tap the tooltip {string} button {int} times");
}

class TapButtonByTooltipOnceStep extends When1WithWorld<String, FlutterWorld> {
  TapButtonByTooltipOnceStep()
    : super(StepDefinitionConfiguration()..timeout = Duration(seconds: 10));

  @override
  Future<void> executeStep(String input1) async {
    final locator = find.byTooltip(input1);
    await FlutterDriverUtils.tap(world.driver, locator, timeout: timeout);
  }

  @override
  RegExp get pattern => RegExp(r"I tap the tooltip {string} button once");
}

class TapButtonStep extends When1WithWorld<String, FlutterWorld> {
  TapButtonStep()
      : super(StepDefinitionConfiguration()..timeout = Duration(seconds: 1));

  @override
  Future<void> executeStep(String input1) async {
    final locator = find.byValueKey(input1);
    await FlutterDriverUtils.tap(world.driver, locator, timeout: timeout);
  }

  @override
  RegExp get pattern => RegExp(r"I tap the {string} button");
}

class TapLabelStep extends When1WithWorld<String, FlutterWorld> {
  TapLabelStep()
      : super(StepDefinitionConfiguration()..timeout = Duration(seconds: 1));

  @override
  Future<void> executeStep(String input1) async {
    final locator = find.byValueKey(input1);
    await FlutterDriverUtils.tap(world.driver, locator, timeout: timeout);
  }

  @override
  RegExp get pattern => RegExp(r"I tap the {string} label");
}

class TapButtonNTimesStep extends When2WithWorld<String, int, FlutterWorld> {
  TapButtonNTimesStep ()
      : super(StepDefinitionConfiguration()..timeout = Duration(seconds: 10));

  @override
  Future<void> executeStep(String input1, int input2) async {
    final locator = find.byValueKey(input1);
    for (var i = 0; i < input2; i++) {
      await FlutterDriverUtils.tap(world.driver, locator, timeout: timeout);
    }
  }

  @override
  RegExp get pattern => RegExp(r"I tap the {string} button {int} times");
}