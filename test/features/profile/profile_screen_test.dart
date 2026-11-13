import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_state.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_groups_carousel.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_reviewed_books.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockSessionCubit mockCubit;

  setUp(() {
    mockCubit = MockSessionCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.logOut()).thenAnswer((_) async {});
  });

  // Por padrão o resumo já carregou vazio: o spinner do carregamento não
  // deixaria os pumpAndSettle terminarem.
  Widget buildSubject({
    UserProfileEntity? profile,
    ProfileSummaryState summary = const ProfileSummaryLoaded(
      ProfileSummaryEntity(booksReadCount: 0),
    ),
    VoidCallback? onRetry,
  }) {
    return BlocProvider<SessionCubit>.value(
      value: mockCubit,
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: ProfileScreen(
            profile: profile,
            summary: summary,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }

  const summary = ProfileSummaryEntity(
    booksReadCount: 5,
    groups: [
      ProfileGroupEntity(id: 'g-1', number: 1),
      ProfileGroupEntity(id: 'g-2', number: 4),
    ],
    reviewedBooks: [
      ProfileReviewedBookEntity(
        bookId: 'b-1',
        title: 'Harry Potter e a Pedra Filosofal',
        rating: 5,
      ),
    ],
  );

  Finder logoutButton() => find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is AppIcon && widget.icon == AppIcons.leave,
    ),
    matching: find.byType(InkWell),
  );

  UserProfileEntity buildProfile({String name = 'Roberta'}) {
    final now = DateTime.now();
    return UserProfileEntity(
      id: 'p-1',
      name: name,
      email: 'roberta@example.com',
      address: '',
      phoneNumber: '',
      birthday: '',
      instagram: '',
      educationDegree: '',
      jobPosition: '',
      userId: 'u-1',
      isActive: true,
      createdAt: DateTime(now.year, now.month - 3),
    );
  }

  testWidgets('Repassa a foto do perfil ao cabeçalho', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        profile: buildProfile().copyWith(
          photoUrl: 'https://example.com/foto.jpg',
        ),
      ),
    );

    final avatar = tester.widget<AppParticipantAvatar>(
      find.byType(AppParticipantAvatar),
    );
    expect(avatar.photoUrl, 'https://example.com/foto.jpg');
  });

  testWidgets('Avisa a sessão quando a foto muda', (tester) async {
    when(() => mockCubit.updateProfilePhoto(any())).thenReturn(null);
    await tester.pumpWidget(buildSubject(profile: buildProfile()));

    tester.widget<ProfileHeader>(find.byType(ProfileHeader)).onPhotoChanged!(
      'https://example.com/nova.jpg',
    );

    verify(
      () => mockCubit.updateProfilePhoto('https://example.com/nova.jpg'),
    ).called(1);
  });

  testWidgets('Deve exibir o título como cabeçalho', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Meu Perfil'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Meu Perfil'),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.header == true,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Deve exibir o nome, os livros lidos e os grupos', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        profile: buildProfile(),
        summary: const ProfileSummaryLoaded(summary),
      ),
    );

    expect(find.byType(ProfileHeader), findsOneWidget);
    expect(find.text('Roberta'), findsOneWidget);
    expect(find.text('5 livros lidos'), findsOneWidget);
    expect(find.text('2 grupos'), findsOneWidget);
    // O tempo no clube saiu do cabeçalho, como no design.
    expect(find.textContaining('no clube'), findsNothing);
  });

  testWidgets('Deve usar o nome padrão quando o perfil não tem nome', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(profile: buildProfile(name: '')));

    expect(find.text('Usuária'), findsOneWidget);
  });

  testWidgets('O botão de sair tem alvo de toque de 48x48', (tester) async {
    await tester.pumpWidget(buildSubject());

    final size = tester.getSize(logoutButton());
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('Deve exibir o ícone de leave na ProfileScreen', (tester) async {
    await tester.pumpWidget(buildSubject());

    final iconFinder = find.byWidgetPredicate(
      (widget) => widget is AppIcon && widget.icon == AppIcons.leave,
    );
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('Deve abrir o LogoutConfirmDialog ao clicar no ícone de saída', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(logoutButton());
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });
  testWidgets('Deve expor Semantics de botão com label', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Sair da conta',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Editar foto de perfil',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Deve fechar o dialog ao clicar em Cancelar sem chamar logOut', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(logoutButton());
    await tester.pumpAndSettle();
    expect(find.byType(LogoutConfirmDialog), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsNothing);
    verifyNever(() => mockCubit.logOut());
  });

  testWidgets('Deve fechar o dialog ao clicar no X sem chamar logOut', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(logoutButton());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsNothing);
    verifyNever(() => mockCubit.logOut());
  });

  testWidgets('Deve fechar o dialog ao tocar fora (barrierDismissible)', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(logoutButton());
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsNothing);
    verifyNever(() => mockCubit.logOut());
  });

  testWidgets('Deve chamar logOut e fechar o dialog ao confirmar em Sair', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(logoutButton());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.logOut()).called(1);
    expect(find.byType(LogoutConfirmDialog), findsNothing);
  });

  group('resumo do perfil', () {
    testWidgets('mostra o carregamento sem os contadores', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          profile: buildProfile(),
          summary: const ProfileSummaryLoading(),
        ),
      );

      expect(
        find.bySemanticsLabel('Carregando seus grupos e livros'),
        findsOneWidget,
      );
      expect(find.textContaining('livros lidos'), findsNothing);
      expect(find.text('Meus grupos'), findsNothing);
    });

    testWidgets('mostra o erro e tenta de novo', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        buildSubject(
          summary: const ProfileSummaryError(ProfileSummaryLoadFailure()),
          onRetry: () => retries++,
        ),
      );

      expect(
        find.text('Não foi possível carregar seus grupos e livros.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tentar novamente'));
      expect(retries, 1);
    });

    testWidgets(
      'com a sessão expirada, oferece sair em vez de tentar de novo',
      variant: TargetPlatformVariant.mobile(),
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            summary: const ProfileSummaryError(ProfileSessionExpiredFailure()),
            onRetry: () => fail('tentar de novo não resolve sessão expirada'),
          ),
        );

        expect(
          find.text(
            'Sua sessão expirou. Saia do app e entre de novo na sua conta.',
          ),
          findsOneWidget,
        );
        expect(find.text('Tentar novamente'), findsNothing);

        await tester.tap(find.widgetWithText(AppButton, 'Sair'));
        verify(() => mockCubit.logOut()).called(1);
      },
    );

    testWidgets('explica a falta de conexão', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          summary: const ProfileSummaryError(ProfileNetworkFailure()),
        ),
      );

      expect(
        find.text(
          'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('explica quando não há grupos nem avaliações', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Você ainda não participa de nenhum grupo.'),
        findsOneWidget,
      );
      expect(find.text('Você ainda não avaliou nenhum livro.'), findsOneWidget);
      expect(find.byType(ProfileGroupsCarousel), findsNothing);
      expect(find.text('Ver todos os livros'), findsNothing);
    });

    testWidgets('mostra as seções como cabeçalhos, com grupos e livros', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(summary: const ProfileSummaryLoaded(summary)),
      );

      for (final title in ['Meus grupos', 'Livros avaliados']) {
        expect(
          tester.getSemantics(find.text(title)),
          isSemantics(label: title, isHeader: true),
        );
      }
      expect(find.bySemanticsLabel('Grupo 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Grupo 4'), findsOneWidget);
      expect(find.byType(ProfileReviewedBooks), findsOneWidget);
      expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
    });

    testWidgets('o link de todos os livros fica desabilitado por enquanto', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(summary: const ProfileSummaryLoaded(summary)),
      );

      final seeAll = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Ver todos os livros'),
      );
      expect(seeAll.onPressed, isNull);
    });

    Future<GoRouter> pumpWithRouter(WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: ProfileScreen(summary: ProfileSummaryLoaded(summary)),
            ),
          ),
          GoRoute(
            path: GroupRoutes.groupDetails,
            builder: (_, state) =>
                Text('grupo ${state.uri.queryParameters['group_id']}'),
          ),
          GoRoute(
            path: '/books/:bookId',
            builder: (_, state) =>
                Text('livro ${state.pathParameters['bookId']}'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        BlocProvider<SessionCubit>.value(
          value: mockCubit,
          child: MaterialApp.router(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('tocar num grupo abre a tela do grupo', (tester) async {
      await pumpWithRouter(tester);

      await tester.tap(find.byKey(const ValueKey('profile-group-g-2')));
      await tester.pumpAndSettle();

      expect(find.text('grupo g-2'), findsOneWidget);
    });

    testWidgets('tocar num livro abre o detalhe do livro', (tester) async {
      await pumpWithRouter(tester);

      await tester.tap(find.byKey(const ValueKey('profile-book-b-1')));
      await tester.pumpAndSettle();

      expect(find.text('livro b-1'), findsOneWidget);
    });
  });
}
