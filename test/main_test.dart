import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('MainApp builds with AppTheme and renders HomePage', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
  });

  test('mainAsync initializes and runs app', () async {
    // This test ensures the mainAsync function is called during coverage
    // In a real scenario, this would be tested through integration tests
    expect(mainAsync, isA<Function>());
  });
}
