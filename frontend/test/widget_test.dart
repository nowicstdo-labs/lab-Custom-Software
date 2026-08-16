import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astha_diagnostic/frontend_app.dart';

void main() {
  testWidgets('Astha Diagnostic App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AsthaDiagnosticApp()));
    await tester.pumpAndSettle();
    expect(find.text('ASTHA DIAGNOSTIC'), findsWidgets);
  });
}
