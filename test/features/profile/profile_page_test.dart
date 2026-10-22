import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: InheritedGoRouter(
        goRouter: mockGoRouter,
        child: const ProfilePage(),
      ),
    );
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

  testWidgets(
    'Deve chamar a navegação correta ao clicar em outro item da barra',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final searchTab = find.bySemanticsLabel('Busca');
      await tester.tap(searchTab);
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.go('/search')).called(1);
    },
  );
}
