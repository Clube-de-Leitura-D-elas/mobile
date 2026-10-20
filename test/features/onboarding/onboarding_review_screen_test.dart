import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/onboarding/domain/entities/user_review_profile.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_state.dart';
import 'package:mobile/features/onboarding/presentation/pages/onboarding_review_screen.dart';
import 'package:mobile/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingReviewCubit extends MockCubit<OnboardingReviewState>
    implements OnboardingReviewCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockOnboardingReviewCubit mockReviewCubit;
  late MockSessionCubit mockSessionCubit;

  const testProfile = UserReviewProfile(
    name: 'Maria Silva',
    email: 'maria@example.com',
  );

  setUp(() {
    mockReviewCubit = MockOnboardingReviewCubit();
    mockSessionCubit = MockSessionCubit();
    when(() => mockSessionCubit.state).thenReturn(const GuestSession());
    when(() => mockSessionCubit.refreshProfile()).thenAnswer((_) async {});
  });

  tearDown(() {
    AppToast.dismiss();
  });

  Widget buildSubject({
    required Widget child,
    GoRouter? router,
  }) {
    if (router != null) {
      return MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      );
    }

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
          BlocProvider<OnboardingReviewCubit>.value(value: mockReviewCubit),
        ],
        child: child,
      ),
    );
  }

  testWidgets('renders loading spinner for initial and loading profile states', (
    tester,
  ) async {
    when(() => mockReviewCubit.state).thenReturn(
      const OnboardingReviewInitial(),
    );

    await tester.pumpWidget(
      buildSubject(child: const OnboardingReviewScreen()),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    when(() => mockReviewCubit.state).thenReturn(
      const OnboardingReviewLoadingProfile(),
    );
    await tester.pumpWidget(
      buildSubject(child: const OnboardingReviewScreen()),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders form and steps when state is OnboardingReviewFormState', (
    tester,
  ) async {
    when(() => mockReviewCubit.state).thenReturn(
      const OnboardingReviewFormState(
        currentStep: 0,
        profile: testProfile,
      ),
    );

    await tester.pumpWidget(
      buildSubject(child: const OnboardingReviewScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verifique os seus dados'), findsOneWidget);
    expect(find.byType(AppStepIndicator), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets(
    'calls refreshProfile and navigates to welcome on OnboardingReviewSuccess',
    (tester) async {
      when(() => mockReviewCubit.state).thenReturn(
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: testProfile,
        ),
      );
      final streamController =
          StreamController<OnboardingReviewState>.broadcast();
      whenListen(
        mockReviewCubit,
        streamController.stream,
        initialState: const OnboardingReviewFormState(
          currentStep: 0,
          profile: testProfile,
        ),
      );

      final router = GoRouter(
        initialLocation: OnboardingRoutes.reviewProfile,
        routes: [
          GoRoute(
            path: OnboardingRoutes.reviewProfile,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider<SessionCubit>.value(value: mockSessionCubit),
                BlocProvider<OnboardingReviewCubit>.value(
                  value: mockReviewCubit,
                ),
              ],
              child: const OnboardingReviewScreen(),
            ),
          ),
          GoRoute(
            path: OnboardingRoutes.welcome,
            builder: (context, state) =>
                const Scaffold(body: Text('Welcome Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        buildSubject(child: const SizedBox(), router: router),
      );
      await tester.pumpAndSettle();

      streamController.add(const OnboardingReviewSuccess());
      await tester.pumpAndSettle();

      verify(() => mockSessionCubit.refreshProfile()).called(1);
      expect(find.text('Welcome Screen'), findsOneWidget);

      await streamController.close();
    },
  );

  testWidgets(
    'shows error toast when OnboardingReviewFormState has errorMessage',
    (tester) async {
      when(() => mockReviewCubit.state).thenReturn(
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: testProfile,
        ),
      );
      final streamController =
          StreamController<OnboardingReviewState>.broadcast();
      whenListen(
        mockReviewCubit,
        streamController.stream,
        initialState: const OnboardingReviewFormState(
          currentStep: 0,
          profile: testProfile,
        ),
      );

      await tester.pumpWidget(
        buildSubject(child: const OnboardingReviewScreen()),
      );
      await tester.pumpAndSettle();

      streamController.add(
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: testProfile,
          errorMessage: 'Erro ao salvar',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar'), findsOneWidget);
      await streamController.close();
    },
  );

  testWidgets(
    'clicking Continuar on step 0 and 1 moves to next page, and Voltar moves to previous page',
    (tester) async {
      when(() => mockReviewCubit.state).thenReturn(
        const OnboardingReviewFormState(
          currentStep: 0,
          profile: testProfile,
        ),
      );
      when(() => mockReviewCubit.goToStep(any())).thenReturn(null);

      await tester.pumpWidget(
        buildSubject(child: const OnboardingReviewScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      when(() => mockReviewCubit.state).thenReturn(
        const OnboardingReviewFormState(
          currentStep: 1,
          profile: testProfile,
        ),
      );
      await tester.pumpWidget(
        buildSubject(child: const OnboardingReviewScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'clicking Continuar on step 2 triggers submitReview',
    (tester) async {
      when(() => mockReviewCubit.state).thenReturn(
        const OnboardingReviewFormState(
          currentStep: 2,
          profile: testProfile,
        ),
      );
      when(() => mockReviewCubit.submitReview()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildSubject(child: const OnboardingReviewScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      verify(() => mockReviewCubit.submitReview()).called(1);
    },
  );
}
