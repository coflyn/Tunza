import 'package:flutter_test/flutter_test.dart';
import 'package:tunza/main.dart';

void main() {
  testWidgets('TunzaApp rendering smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TunzaApp());

    // Verify that Tunza title is rendered
    expect(find.text('TUNZA'), findsOneWidget);
  });
}
