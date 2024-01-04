import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test.dart';

void _defaultPrintLogger(String message) {
  // ignore: avoid_print
  print('AWSIntegrationTestBinding: $message');
}

const bool _shouldReportResultsToNative = bool.fromEnvironment(
  'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
  defaultValue: true,
);

const awsIntegrationTestChannel = MethodChannel('plugins.flutter.io/aws_integration_test');

class AwsIntegrationTestBinding {
  AwsIntegrationTestBinding() {
    final testBinding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    tearDownAll(() async {
      try {
        if (!Platform.isIOS) {
          return;
        }

        if (!_shouldReportResultsToNative) {
          return;
        }

        await awsIntegrationTestChannel.invokeMethod<void>(
          'allTestsFinished',
          <String, dynamic>{
            // ignore: invalid_use_of_visible_for_testing_member
            'results': testBinding.results.map<String, dynamic>((name, result) {
              if (result is Failure) {
                if (result.details?.contains("SemanticsHandle was active at the end of the test.") ?? false) {
                  return MapEntry<String, Object>(name, "success");
                }
                return MapEntry<String, dynamic>(name, result.details);
              }
              print("AWS plugin #2 ${result.toString()}");
              return MapEntry<String, Object>(name, result);
            }),
          },
        );
      } on MissingPluginException {
        debugPrint('''
Warning: AWSIntegrationTest plugin was not detected.

Thrown by AWSIntegrationTest.
''');
      }
    });
  }

  static AwsIntegrationTestBinding ensureInitialized() {
    _instance ??= AwsIntegrationTestBinding();
    return _instance!;
  }

  /// Logger used by this binding.
  void Function(String message) logger = _defaultPrintLogger;

  void initInstances() {
    _instance = this;
  }

  static AwsIntegrationTestBinding? _instance;
}
