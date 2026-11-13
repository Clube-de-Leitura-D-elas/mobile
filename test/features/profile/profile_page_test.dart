import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_route_observer.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_state.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileSummaryCubit extends MockCubit<ProfileSummaryState>
    implements ProfileSummaryCubit {}

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockGoRouter mockGoRouter;
  late MockSessionCubit sessionCubit;
  late MockProfileSummaryCubit summaryCubit;

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
    summaryCubit = MockProfileSummaryCubit();
    when(() => summaryCubit.state).thenReturn(
      const ProfileSummaryLoaded(ProfileSummaryEntity(booksReadCount: 0)),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: sessionCubit),
          BlocProvider<ProfileSummaryCubit>.value(value: summaryCubit),
        ],
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

  testWidgets('Repassa o resumo à tela e tenta de novo pelo cubit', (
    tester,
  ) async {
    when(() => summaryCubit.load()).thenAnswer((_) async {});
    when(
      () => summaryCubit.state,
    ).thenReturn(const ProfileSummaryError(ProfileNetworkFailure()));

    await tester.pumpWidget(buildSubject());

    final screen = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    expect(screen.summary, const ProfileSummaryError(ProfileNetworkFailure()));

    await tester.tap(find.text('Tentar novamente'));
    verify(() => summaryCubit.load()).called(1);
  });

  testWidgets('Deve passar o perfil da sessão para a ProfileScreen', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final screen = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    expect(screen.profile, profile);
    expect(find.text('Roberta'), findsOneWidget);
  });

  testWidgets('Mostra a foto vinda da sessão ao abrir a tela', (tester) async {
    when(() => sessionCubit.state).thenReturn(
      AuthenticatedSession(
        user: user,
        profile: profile.copyWith(photoUrl: 'https://example.com/foto.jpg'),
      ),
    );

    await tester.pumpWidget(buildSubject());

    final avatar = tester.widget<AppParticipantAvatar>(
      find.byType(AppParticipantAvatar),
    );
    expect(avatar.photoUrl, 'https://example.com/foto.jpg');
  });

  testWidgets('A foto editada continua ao recriar a tela na troca de aba', (
    tester,
  ) async {
    final authRepository = MockAuthRepository();
    final supabaseService = MockSupabaseService();
    when(() => supabaseService.currentUser).thenReturn(null);
    when(
      () => supabaseService.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(() => authRepository.getUserProfile('u-1')).thenAnswer(
      (_) async =>
          Success(profile.copyWith(photoUrl: 'https://example.com/antiga.jpg')),
    );

    final realCubit = SessionCubit(
      authRepository: authRepository,
      supabaseService: supabaseService,
    );
    addTearDown(realCubit.close);
    await realCubit.checkUserProfile('u-1', user);

    Widget page() => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: realCubit),
          BlocProvider<ProfileSummaryCubit>.value(value: summaryCubit),
        ],
        child: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const ProfilePage(),
        ),
      ),
    );

    await tester.pumpWidget(page());
    tester.widget<ProfileHeader>(find.byType(ProfileHeader)).onPhotoChanged!(
      'https://example.com/nova.jpg',
    );
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(page());

    final avatar = tester.widget<AppParticipantAvatar>(
      find.byType(AppParticipantAvatar),
    );
    expect(avatar.photoUrl, 'https://example.com/nova.jpg');
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

  testWidgets('Recarrega o resumo ao voltar de uma tela aberta pelo perfil', (
    tester,
  ) async {
    when(() => summaryCubit.refresh()).thenAnswer((_) async {});
    final router = GoRouter(
      observers: [appRouteObserver],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: sessionCubit),
              BlocProvider<ProfileSummaryCubit>.value(value: summaryCubit),
            ],
            child: const ProfilePage(),
          ),
        ),
        GoRoute(path: '/livro', builder: (_, _) => const Text('livro')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    verifyNever(() => summaryCubit.refresh());

    router.push('/livro');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    verify(() => summaryCubit.refresh()).called(1);
  });
}
