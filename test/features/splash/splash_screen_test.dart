import 'package:bloc_test/bloc_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/splash/presentation/pages/splash_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockSessionCubit sessionCubit;

  setUp(() {
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.retryProfile()).thenAnswer((_) async {});
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
  });

  Future<void> pumpSplash(WidgetTester tester, SessionState state) async {
    when(() => sessionCubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocProvider<SessionCubit>.value(
          value: sessionCubit,
          child: const SplashScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'SplashScreen renders logo asset and progress indicator correctly',
    (tester) async {
      await pumpSplash(tester, const LoadingSession());

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == "Logo do Clube de Leitura D'Elas",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows the reason with retry and logout when the profile fails '
      'to load', (tester) async {
    await pumpSplash(
      tester,
      const SessionProfileUnavailable(
        userId: 'user-1',
        failure: UserNetworkFailure(),
      ),
    );

    final l10n = await AppLocalizations.delegate.load(
      const Locale('pt', 'BR'),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.text(l10n.sessionProfileLoadError(l10n.errorNoConnection)),
      findsOneWidget,
    );

    await tester.tap(find.text('Tentar novamente'));
    verify(() => sessionCubit.retryProfile()).called(1);

    await tester.tap(find.text(l10n.logoutTooltip));
    verify(() => sessionCubit.logOut()).called(1);
  });

  testWidgets('the profile error scrolls instead of overflowing with large '
      'text', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => sessionCubit.state).thenReturn(
      const SessionProfileUnavailable(
        userId: 'user-1',
        failure: UserNetworkFailure(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: BlocProvider<SessionCubit>.value(
          value: sessionCubit,
          child: const SplashScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Sair'), findsOneWidget);
  });
}
