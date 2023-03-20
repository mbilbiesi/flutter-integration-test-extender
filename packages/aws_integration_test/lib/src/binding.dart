// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/common.dart';
// import 'package:integration_test/integration_test.dart';
//
// void _defaultPrintLogger(String message) {
//   // ignore: avoid_print
//   print('AWSIntegrationTestBinding: $message');
// }
//
// const bool _shouldReportResultsToNative = bool.fromEnvironment(
//   'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
//   defaultValue: true,
// );
//
// const awsIntegrationTestChannel =
//     MethodChannel('plugins.flutter.io/integration_test');
//
// class AwsIntegrationTestBinding extends IntegrationTestWidgetsFlutterBinding {
//   AwsIntegrationTestBinding() {
//     final oldTestExceptionReporter = reportTestException;
//     reportTestException = (details, testDescription) {
//       // ignore: invalid_use_of_visible_for_testing_member
//       results[testDescription] = Failure(testDescription, details.toString());
//       oldTestExceptionReporter(details, testDescription);
//     };
//
//     tearDownAll(() async {
//       try {
//         if (!Platform.isIOS) {
//           return;
//         }
//
//         if (!_shouldReportResultsToNative) {
//           return;
//         }
//
//         await awsIntegrationTestChannel.invokeMethod<void>(
//           'allTestsFinished',
//           <String, dynamic>{
//             // ignore: invalid_use_of_visible_for_testing_member
//             'results': results.map<String, dynamic>((name, result) {
//               if (result is Failure) {
//                 return MapEntry<String, dynamic>(name, result.details);
//               }
//
//               return MapEntry<String, Object>(name, result);
//             }),
//           },
//         );
//       } on MissingPluginException {
//         debugPrint('''
// Warning: AWSIntegrationTest plugin was not detected.
//
// Thrown by AWSIntegrationTest.
// ''');
//       }
//     });
//   }
//
//   factory AwsIntegrationTestBinding.ensureInitialized() {
//     if (_instance == null) {
//       AwsIntegrationTestBinding();
//     }
//     return _instance!;
//   }
//
//   /// Logger used by this binding.
//   void Function(String message) logger = _defaultPrintLogger;
//
//   // TODO: Remove once https://github.com/flutter/flutter/pull/108430 is available on the stable channel
//   @override
//   TestBindingEventSource get pointerEventSource => TestBindingEventSource.test;
//
//   @override
//   void initInstances() {
//     super.initInstances();
//     _instance = this;
//   }
//
//   static AwsIntegrationTestBinding get instance =>
//       BindingBase.checkInstance(_instance);
//   static AwsIntegrationTestBinding? _instance;
// }
