import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
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

  Widget buildSubject({UserProfileEntity? profile}) {
    return BlocProvider<SessionCubit>.value(
      value: mockCubit,
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(body: ProfileScreen(profile: profile)),
      ),
    );
  }

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

  testWidgets('Deve exibir o nome e o tempo no clube do perfil', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(profile: buildProfile()));

    expect(find.byType(ProfileHeader), findsOneWidget);
    expect(find.text('Roberta'), findsOneWidget);
    expect(find.text('3 meses no clube'), findsOneWidget);
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
}
