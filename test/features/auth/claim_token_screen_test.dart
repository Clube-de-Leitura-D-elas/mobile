import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/claim_token_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionCubit mockSessionCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionCubit = MockSessionCubit();
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.state).thenReturn(const GuestSession());
    when(() => mockSessionCubit.checkUserProfile(any())).thenAnswer((_) async {});

    when(() => mockAuthRepository.claimProfile(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => mockAuthRepository.getUserProfile(any()))
        .thenAnswer((_) async => const Success(UserProfileEntity(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          address: 'Address 1',
          phoneNumber: '123456789',
          birthday: '01/01/2000',
          instagram: '@test',
          educationDegree: 'Superior',
          jobPosition: 'Dev',
          userId: 'user-123',
          isActive: true,
        )));

    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<AuthRepository>(
      () => mockAuthRepository,
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: mockSessionCubit),
          BlocProvider<ClaimTokenCubit>(
            create: (_) => ClaimTokenCubit(authRepository: mockAuthRepository),
          ),
        ],
        child: const ClaimTokenScreen(userId: 'user-123'),
      ),
    );
  }

  group('ClaimTokenScreen Widget', () {
    testWidgets('renders UI elements correctly', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Vincular Perfil'), findsOneWidget);
      expect(find.text('Informe o seu Token de Acesso'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);
    });

    testWidgets('entering token and pressing Confirmar submits token', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'TOKEN123');
      await tester.pumpAndSettle();

      final confirmButton = find.byType(AppButton);
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pump();

      expect(find.byType(ClaimTokenScreen), findsOneWidget);
    });
  });
}
