import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/presentation/widgets/raffle_error_state.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockSessionCubit sessionCubit;
  var retries = 0;

  setUp(() {
    retries = 0;
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.state).thenReturn(const GuestSession());
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, RaffleFailure failure) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: BlocProvider<SessionCubit>.value(
          value: sessionCubit,
          child: Scaffold(
            body: RaffleErrorState(failure: failure, onRetry: () => retries++),
          ),
        ),
      ),
    );
  }

  testWidgets('appends what retry does after the reason', (tester) async {
    await pump(tester, const RaffleAlreadyRecordedFailure());

    expect(
      find.text(
        'O sorteio deste encontro já foi feito. '
        'Toque em Tentar novamente para ver o resultado.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
  });

  testWidgets('hides retry when the user lacks permission', (tester) async {
    await pump(tester, const RaffleForbiddenFailure());

    expect(
      find.text('Você não tem permissão para fazer isso.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('offers logout when the session expired', (tester) async {
    await pump(tester, const RaffleSessionExpiredFailure());

    await tester.tap(find.text('Sair'));
    verify(() => sessionCubit.logOut()).called(1);
  });
}
