import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/theme/app_theme.dart';
import 'package:mobile/design_system/widgets/app_button.dart';
import 'package:mobile/design_system/widgets/app_toast.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_presence_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_presence_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_presence_attendee_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

MeetingAttendanceEntity _attendee(
  String id,
  String name, {
  MeetingPresenceStatus? presenceStatus,
}) => MeetingAttendanceEntity(
  id: id,
  name: name,
  invitationStatus: MeetingInvitationStatus.confirmed,
  presenceStatus: presenceStatus,
);

void main() {
  late MockGroupRepository repository;
  late MeetingPresenceCubit cubit;

  const meetingId = 'meeting-1';

  setUp(() {
    repository = MockGroupRepository();
    cubit = MeetingPresenceCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  Widget buildApp({Widget? home}) => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home:
        home ??
        BlocProvider<MeetingPresenceCubit>.value(
          value: cubit,
          child: const MeetingPresencePage(),
        ),
  );

  void stubAttendance(List<MeetingAttendanceEntity> list) {
    when(() => repository.getMeetingAttendance(meetingId)).thenAnswer(
      (_) async => Success<List<MeetingAttendanceEntity>, GroupFailure>(list),
    );
  }

  group('MeetingPresencePage', () {
    testWidgets('exibe indicador de carregamento no estado Loading', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MeetingPresenceScreen), findsNothing);
    });

    testWidgets('exibe a mensagem de erro no estado Error', (tester) async {
      const failure = MeetingAttendanceFailure();

      when(() => repository.getMeetingAttendance(meetingId)).thenAnswer(
        (_) async =>
            const Failure<List<MeetingAttendanceEntity>, GroupFailure>(failure),
      );

      await tester.pumpWidget(buildApp());
      await cubit.load(meetingId);
      await tester.pump();

      expect(find.text(failure.message), findsOneWidget);
      expect(find.byType(MeetingPresenceScreen), findsNothing);
    });

    testWidgets('exibe a lista editável com botão no estado Editing', (
      tester,
    ) async {
      stubAttendance([_attendee('u-1', 'Ana'), _attendee('u-2', 'Bruno')]);

      await tester.pumpWidget(buildApp());
      await cubit.load(meetingId);
      await tester.pump();

      expect(find.byType(MeetingPresenceScreen), findsOneWidget);
      expect(find.byType(PresenceAttendeeTile), findsNWidgets(2));
      expect(find.byType(AppButton), findsOneWidget);

      expect(
        tester
            .widget<MeetingPresenceScreen>(find.byType(MeetingPresenceScreen))
            .readOnly,
        isFalse,
      );
    });

    testWidgets('desmarcar um participante atualiza a tela', (tester) async {
      stubAttendance([_attendee('u-1', 'Ana'), _attendee('u-2', 'Bruno')]);

      await tester.pumpWidget(buildApp());
      await cubit.load(meetingId);
      await tester.pump();

      cubit.toggle('u-2');
      await tester.pump();

      final screen = tester.widget<MeetingPresenceScreen>(
        find.byType(MeetingPresenceScreen),
      );

      expect(screen.marked, {'u-1'});
    });

    testWidgets('exibe a lista somente leitura no estado Closed', (
      tester,
    ) async {
      stubAttendance([
        _attendee('u-1', 'Ana', presenceStatus: MeetingPresenceStatus.present),
        _attendee('u-2', 'Bruno', presenceStatus: MeetingPresenceStatus.absent),
      ]);

      await tester.pumpWidget(buildApp());
      await cubit.load(meetingId);
      await tester.pump();

      final screen = tester.widget<MeetingPresenceScreen>(
        find.byType(MeetingPresenceScreen),
      );

      expect(screen.readOnly, isTrue);
      expect(screen.isSubmitting, isFalse);
      expect(screen.marked, {'u-1'});
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('mostra toast de erro quando o envio falha', (tester) async {
      const failure = MeetingPresenceForbiddenFailure();

      stubAttendance([_attendee('u-1', 'Ana')]);

      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) async => const Failure<void, GroupFailure>(failure));

      await tester.pumpWidget(buildApp());
      await cubit.load(meetingId);
      await tester.pump();

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);
      expect(find.text(failure.message), findsOneWidget);
      expect(find.byType(MeetingPresencePage), findsOneWidget);

      // Remove a entrada do Overlay criada pelo AppToast durante o teste.
      AppToast.dismiss();
    });

    testWidgets('faz pop com as presentes quando a presença é confirmada', (
      tester,
    ) async {
      stubAttendance([_attendee('u-1', 'Ana')]);

      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) async => const Success<void, GroupFailure>(null));

      List<MeetingAttendanceEntity>? popResult;

      await tester.pumpWidget(
        buildApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    popResult = await Navigator.of(context)
                        .push<List<MeetingAttendanceEntity>>(
                          MaterialPageRoute(
                            builder: (_) =>
                                BlocProvider<MeetingPresenceCubit>.value(
                                  value: cubit,
                                  child: const MeetingPresencePage(),
                                ),
                          ),
                        );
                  },
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await cubit.load(meetingId);
      await tester.pump();

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.byType(MeetingPresencePage), findsNothing);
      expect(popResult?.map((a) => a.id), ['u-1']);
    });

    testWidgets('não faz pop quando o Closed vem do carregamento inicial', (
      tester,
    ) async {
      stubAttendance([
        _attendee('u-1', 'Ana', presenceStatus: MeetingPresenceStatus.present),
      ]);

      await tester.pumpWidget(buildApp());
      await cubit.load(meetingId);
      await tester.pumpAndSettle();

      expect(find.byType(MeetingPresencePage), findsOneWidget);
      expect(find.byType(MeetingPresenceScreen), findsOneWidget);
    });
  });
}
