import 'package:aws_integration_test/aws_integration_test.dart';
import 'package:aws_integration_test_example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  final binding = AwsIntegrationTestBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('tap on the floating action button, verify counter', (tester) async {
    // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    // Load app widget.
    await tester.pumpWidget(const MyApp());


    // Verify the counter starts at 0.
    expect(find.text('0'), findsOneWidget);

    // Finds the floating action button to tap on.
    final fab = find.byKey(const Key('increment'));

    // Emulate a tap on the floating action button.
    await tester.tap(fab);

    // Trigger a frame.
    await tester.pumpAndSettle();

    // Verify the counter increments by 1.
    expect(find.text('1'), findsOneWidget);
  });
}
