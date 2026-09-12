import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/home/presentation/widgets/profile_detail_tile.dart';

void main() {
  Widget buildWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('ProfileDetailTile Widget', () {
    testWidgets('renders label and non-empty value correctly', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const ProfileDetailTile(
            icon: Icons.person,
            label: 'Nome',
            value: 'Maria Silva',
          ),
        ),
      );

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders fallback "Não informado" when value is empty', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const ProfileDetailTile(
            icon: Icons.email,
            label: 'E-mail',
            value: '',
          ),
        ),
      );

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Não informado'), findsOneWidget);
    });
  });
}
