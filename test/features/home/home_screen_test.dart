import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockSessionCubit mockSessionCubit;

  const testUser = UserEntity(
    name: 'Jane User',
    mail: 'jane@example.com',
    birthday: '01/01/1990',
    phoneNumber: '555-1234',
    instagramUser: '@jane',
    educationDegree: 'Bachelor',
    jobPosition: 'Engineer',
    cityZone: (id: '1', name: 'Porto Alegre', acronym: 'POA'),
  );

  const testProfile = UserProfileEntity(
    id: 'p-1',
    name: 'Jane Profile',
    email: 'jane@example.com',
    address: 'Street 1',
    phoneNumber: '555-1234',
    birthday: '01/01/1990',
    instagram: '@jane',
    educationDegree: 'Bachelor',
    jobPosition: 'Engineer',
    userId: 'user-123',
    isActive: true,
  );

  setUp(() {
    mockSessionCubit = MockSessionCubit();
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.state).thenReturn(const GuestSession());
    when(() => mockSessionCubit.logOut()).thenAnswer((_) async {});
  });

  Widget buildSubject({
    required UserEntity user,
    UserProfileEntity? profile,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<SessionCubit>.value(
        value: mockSessionCubit,
        child: HomeScreen(user: user, profile: profile),
      ),
    );
  }

  group('HomeScreen Widget', () {
    testWidgets('renders profile data correctly when profile is provided', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(user: testUser, profile: testProfile));
      await tester.pumpAndSettle();

      expect(find.text("Clube de Leitura D'elas"), findsOneWidget);
      expect(find.text('Jane Profile'), findsNWidgets(2));
      expect(find.text('jane@example.com'), findsNWidgets(2));
      expect(find.text('Perfil Vinculado & Ativo'), findsOneWidget);
      expect(find.text('Street 1'), findsOneWidget);
      expect(find.text('555-1234'), findsOneWidget);
      expect(find.text('01/01/1990'), findsOneWidget);
      expect(find.text('@jane'), findsOneWidget);
      expect(find.text('Bachelor'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
      expect(find.text('user-123'), findsOneWidget);
    });

    testWidgets('renders user entity fallbacks when profile is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(user: testUser));
      await tester.pumpAndSettle();

      expect(find.text('Jane User'), findsNWidgets(2));
      expect(find.text('jane@example.com'), findsNWidgets(2));
    });

    testWidgets('tapping logout button in AppBar calls logOut on SessionCubit', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(user: testUser, profile: testProfile));
      await tester.pumpAndSettle();

      final logoutIconButton = find.byIcon(Icons.logout);
      expect(logoutIconButton, findsOneWidget);

      await tester.tap(logoutIconButton);
      await tester.pumpAndSettle();

      verify(() => mockSessionCubit.logOut()).called(1);
    });

    testWidgets('tapping Sair da Conta button calls logOut on SessionCubit', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(user: testUser, profile: testProfile));
      await tester.pumpAndSettle();

      final logoutButton = find.text('Sair da Conta');
      expect(logoutButton, findsOneWidget);

      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      verify(() => mockSessionCubit.logOut()).called(1);
    });
  });
}
