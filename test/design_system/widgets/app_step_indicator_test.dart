import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  Widget buildTestableWidget({int totalSteps = 3, int currentStep = 0}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: AppStepIndicator(
          totalSteps: totalSteps,
          currentStep: currentStep,
        ),
      ),
    );
  }

  group('AppStepIndicator Widget Tests', () {
    testWidgets('renders all step indicators with correct active states', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(totalSteps: 4, currentStep: 1));

      expect(find.byType(AppStepIndicator), findsOneWidget);
      expect(
        find.bySemanticsLabel('Passo 2 de 4'),
        findsOneWidget,
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(4));
    });

    testWidgets('renders default totalSteps of 3', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppStepIndicator(currentStep: 0),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Passo 1 de 3'),
        findsOneWidget,
      );
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(3));
    });
  });
}
