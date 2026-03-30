import 'package:flutter_test/flutter_test.dart';

import 'package:speleo_trace/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SpeleoTraceApp());
    expect(find.text('Speleo Trace'), findsOneWidget);
  });
}
