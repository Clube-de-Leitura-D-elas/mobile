import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockGoRouter mockGoRouter;
  late MockSessionCubit sessionCubit;

  const user = UserEntity(
    name: 'Roberta',
    mail: 'roberta@example.com',
    birthday: '',
    phoneNumber: '',
    instagramUser: '',
    educationDegree: '',
    jobPosition: '',
    cityZone: (id: '', name: '', acronym: ''),
  );

  const profile = UserProfileEntity(
    id: 'p-1',
    name: 'Roberta',
    email: 'roberta@example.com',
    address: '',
    phoneNumber: '',
    birthday: '',
    instagram: '',
    educationDegree: '',
    jobPosition: '',
    userId: 'u-1',
    isActive: true,
  );

  setUp(() {
    mockGoRouter = MockGoRouter();
    sessionCubit = MockSessionCubit();
    when(
      () => sessionCubit.state,
    ).thenReturn(const AuthenticatedSession(user: user, profile: profile));
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const ProfilePage(),
        ),
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

  testWidgets('Deve passar o perfil da sessão para a ProfileScreen', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final screen = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    expect(screen.profile, profile);
    expect(find.text('Roberta'), findsOneWidget);
  });

  testWidgets('Sem sessão autenticada mostra o nome padrão', (tester) async {
    when(() => sessionCubit.state).thenReturn(const LoadingSession());

    await tester.pumpWidget(buildSubject());

    final screen = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    expect(screen.profile, isNull);
    expect(find.text('Usuária'), findsOneWidget);
  });

  testWidgets('Atualiza a tela quando a sessão traz um perfil novo', (
    tester,
  ) async {
    const renamed = UserProfileEntity(
      id: 'p-1',
      name: 'Roberta Silva',
      email: 'roberta@example.com',
      address: '',
      phoneNumber: '',
      birthday: '',
      instagram: '',
      educationDegree: '',
      jobPosition: '',
      userId: 'u-1',
      isActive: true,
    );

    whenListen(
      sessionCubit,
      Stream.fromIterable([
        const AuthenticatedSession(user: user, profile: renamed),
      ]),
      initialState: const AuthenticatedSession(user: user, profile: profile),
    );

    await tester.pumpWidget(buildSubject());
    expect(find.text('Roberta'), findsOneWidget);

    await tester.pump();

    expect(find.text('Roberta Silva'), findsOneWidget);
    expect(find.text('Roberta'), findsNothing);
  });

  testWidgets('Mantém o nome enquanto a sessão sai da conta', (tester) async {
    whenListen(
      sessionCubit,
      Stream.fromIterable([const LoadingSession(), const GuestSession()]),
      initialState: const AuthenticatedSession(user: user, profile: profile),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Roberta'), findsOneWidget);
    expect(find.text('Usuária'), findsNothing);
  });

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
