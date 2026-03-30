import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:speleo_trace/main.dart';
import 'package:speleo_trace/viewmodels/triangulation_viewmodel.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TriangulationViewModel(),
        child: const SpeleoTraceApp(),
      ),
    );
    expect(find.text('Set Path'), findsOneWidget);
  });
}
