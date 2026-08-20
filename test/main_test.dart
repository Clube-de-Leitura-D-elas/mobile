import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('MainApp builds with AppTheme and renders HomePage', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });
}
