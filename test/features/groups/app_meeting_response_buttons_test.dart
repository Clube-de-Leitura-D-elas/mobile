import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_state.dart';
import 'package:mobile/features/groups/presentation/widgets/app_meeting_response_buttons.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockMeetingInvitationCubit extends MockCubit<MeetingInvitationState>
    implements MeetingInvitationCubit {}

void main() {
  late MockMeetingInvitationCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(MeetingInvitationStatus.pending);
  });

  setUp(() {
    mockCubit = MockMeetingInvitationCubit();

    when(() => mockCubit.respond(any())).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: BlocProvider<MeetingInvitationCubit>.value(
          value: mockCubit,
          child: const AppMeetingResponseButtons(),
        ),
      ),
    );
  }

  testWidgets(
    'Deve chamar respond(confirmed) ao clicar em confirmar quando status for pending',
    (tester) async {
      when(() => mockCubit.state).thenReturn(
        const MeetingInvitationIdle(MeetingInvitationStatus.pending),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(AppMeetingResponseButtons),
      );
      final l10n = AppLocalizations.of(context);

      final confirmBtn = find.text(l10n.groupConfirmMeetingButton);
      await tester.tap(confirmBtn);

      verify(
        () => mockCubit.respond(MeetingInvitationStatus.confirmed),
      ).called(1);
    },
  );

  testWidgets(
    'Deve chamar respond(declined) ao clicar em recusar quando status for pending',
    (tester) async {
      when(() => mockCubit.state).thenReturn(
        const MeetingInvitationIdle(MeetingInvitationStatus.pending),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(
        find.byType(AppMeetingResponseButtons),
      );
      final l10n = AppLocalizations.of(context);

      final declineBtn = find.text(l10n.groupDeclineMeetingButton);
      await tester.tap(declineBtn);

      verify(
        () => mockCubit.respond(MeetingInvitationStatus.declined),
      ).called(1);
    },
  );
}
