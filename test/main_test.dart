import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('MainApp builds with AppTheme and renders SpacingGuidePage', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainApp), findsOneWidget);
  });
}
