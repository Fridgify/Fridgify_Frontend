import 'dart:async';
import 'package:glob/glob.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'steps/taps.dart';
import 'steps/see.dart';
import 'package:gherkin/gherkin.dart';

Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [Glob(r"test_driver/features/login.feature")]
    ..stepDefinitions = [GivenISeeScreen(), ThenISeeScreen(), TapButtonStep(), ThenISeePopup()]
    ..reporters = [ProgressReporter(), TestRunSummaryReporter()]
    ..restartAppBetweenScenarios = true
    ..targetAppPath = "test_driver/app.dart"
    ..exitAfterTestRun = true;
  return GherkinRunner().execute(config);
}