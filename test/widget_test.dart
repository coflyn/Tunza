import 'package:flutter_test/flutter_test.dart';
import 'package:flow/main.dart';

void main() {
  testWidgets('FlowApp rendering smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlowApp());

    expect(find.text('FLOW'), findsOneWidget);
  });
}
