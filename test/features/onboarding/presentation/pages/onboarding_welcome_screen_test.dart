import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/features/onboarding/presentation/pages/onboarding_welcome_screen.dart';
import 'package:mobile/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockSessionCubit sessionCubit;

  setUp(() {
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.state).thenReturn(const NeedsClaimSession(userId: 'u1'));
  });

  Widget buildSubject(GoRouter router) {
    return MaterialApp.router(
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: OnboardingRoutes.welcome,
      routes: [
        GoRoute(
          path: OnboardingRoutes.welcome,
          builder: (context, state) => BlocProvider<SessionCubit>.value(
            value: sessionCubit,
            child: const OnboardingWelcomeScreen(),
          ),
        ),
        GoRoute(
          path: HomeRoutes.home,
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
  }

  testWidgets('refreshes the session before going home', (tester) async {
    when(() => sessionCubit.refreshProfileSilently()).thenAnswer(
      (_) async => true,
    );

    final router = buildRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(buildSubject(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pronta para o próximo capítulo?'));
    await tester.pumpAndSettle();

    verify(() => sessionCubit.refreshProfileSilently()).called(1);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('stays put when the profile cannot be refreshed', (tester) async {
    when(() => sessionCubit.refreshProfileSilently()).thenAnswer(
      (_) async => false,
    );

    final router = buildRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(buildSubject(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pronta para o próximo capítulo?'));
    await tester.pumpAndSettle();

    verify(() => sessionCubit.refreshProfileSilently()).called(1);
    expect(find.text('Home'), findsNothing);
    expect(find.byType(OnboardingWelcomeScreen), findsOneWidget);
    expect(
      find.text('Não foi possível concluir o cadastro. Tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('disables the button while refreshing', (tester) async {
    final completer = Completer<bool>();
    when(() => sessionCubit.refreshProfileSilently()).thenAnswer(
      (_) => completer.future,
    );

    final router = buildRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(buildSubject(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pronta para o próximo capítulo?'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    verify(() => sessionCubit.refreshProfileSilently()).called(1);

    completer.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
