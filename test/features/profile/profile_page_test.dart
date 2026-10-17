import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(theme: AppTheme.light, home: const ProfilePage());
  }

  testWidgets(
    'Deve renderizar o Scaffold contendo a ProfileScreen e o BottomNavigationBarWidget',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(Scaffold), findsOneWidget);

      expect(find.byType(SafeArea), findsNWidgets(2));

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(BottomNavigationBarWidget), findsOneWidget);
    },
  );

  testWidgets(
    'A navegação inferior deve estar com o índice do perfil selecionado',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final navBarFinder = find.byType(BottomNavigationBarWidget);
      expect(navBarFinder, findsOneWidget);

      final navBar = tester.widget<BottomNavigationBarWidget>(navBarFinder);
      expect(navBar.currentIndex, equals(QuickAccessItem.profile.index));
    },
  );
}
