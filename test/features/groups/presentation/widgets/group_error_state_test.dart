import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/presentation/widgets/group_error_state.dart';
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

  Future<void> pump(WidgetTester tester, GroupFailure failure) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: BlocProvider<SessionCubit>.value(
          value: sessionCubit,
          child: Scaffold(
            body: GroupErrorState(failure: failure, onRetry: () => retries++),
          ),
        ),
      ),
    );
  }

  testWidgets('retries a load failure', (tester) async {
    await pump(tester, const GroupNetworkFailure());

    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
    expect(find.text('Sair'), findsNothing);
  });

  for (final failure in const <GroupFailure>[
    GroupForbiddenFailure(),
    GroupNotFoundFailure(),
    MeetingNotFoundFailure(),
  ]) {
    testWidgets('hides retry for ${failure.runtimeType}', (tester) async {
      await pump(tester, failure);

      expect(find.text(failure.message), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });
  }

  testWidgets('offers logout when the session expired', (tester) async {
    await pump(tester, const GroupSessionExpiredFailure());

    await tester.tap(find.text('Sair'));
    verify(() => sessionCubit.logOut()).called(1);
  });
}
