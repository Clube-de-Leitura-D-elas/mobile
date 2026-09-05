import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('AppTextField Widget', () {
    testWidgets('renders label and hintText correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'E-mail',
            hintText: 'seu@email.com',
          ),
        ),
      );

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('seu@email.com'), findsOneWidget);
    });

    testWidgets('displays errorText when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'E-mail',
            errorText: 'Campo obrigatório',
          ),
        ),
      );

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('toggles obscure text visibility when eye suffix icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            label: 'Senha',
            obscureText: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
