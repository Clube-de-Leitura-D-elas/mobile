import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/theme/app_theme.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
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

  final attendees = [_attendee('u-1', 'Ana'), _attendee('u-2', 'Bruno')];

  setUp(() {
    repository = MockGroupRepository();
    cubit = MeetingPresenceCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(
    WidgetTester tester, {
    List<MeetingAttendanceEntity>? list,
    Set<String> marked = const {},
    bool isSubmitting = false,
    bool readOnly = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: BlocProvider<MeetingPresenceCubit>.value(
          value: cubit,
          child: MeetingPresenceScreen(
            attendees: list ?? attendees,
            marked: marked,
            isSubmitting: isSubmitting,
            readOnly: readOnly,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('MeetingPresenceScreen', () {
    testWidgets('renderiza um tile por participante', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(PresenceAttendeeTile), findsNWidgets(2));
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Bruno'), findsOneWidget);
    });

    testWidgets('renderiza lista vazia sem tiles', (tester) async {
      await pumpScreen(tester, list: const []);

      expect(find.byType(PresenceAttendeeTile), findsNothing);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('marca os tiles conforme o conjunto marked', (tester) async {
      await pumpScreen(tester, marked: {'u-2'});

      final tiles = tester
          .widgetList<PresenceAttendeeTile>(find.byType(PresenceAttendeeTile))
          .toList();

      expect(tiles[0].isChecked, isFalse);
      expect(tiles[1].isChecked, isTrue);
    });

    testWidgets('no modo editável o tile dispara toggle no cubit', (
      tester,
    ) async {
      when(() => repository.getMeetingAttendance('meeting-1')).thenAnswer(
        (_) async =>
            Success<List<MeetingAttendanceEntity>, GroupFailure>(attendees),
      );
      await cubit.load('meeting-1');

      await pumpScreen(tester);

      final tile = tester.widget<PresenceAttendeeTile>(
        find.byType(PresenceAttendeeTile).first,
      );
      expect(tile.onChanged, isNotNull);

      tile.onChanged!();

      expect((cubit.state as dynamic).marked, {'u-1'});
    });

    testWidgets('exibe botão de confirmar habilitado e dispara confirm', (
      tester,
    ) async {
      when(() => repository.getMeetingAttendance('meeting-1')).thenAnswer(
        (_) async =>
            Success<List<MeetingAttendanceEntity>, GroupFailure>(attendees),
      );
      when(
        () => repository.setMeetingPresence('meeting-1', any()),
      ).thenAnswer((_) async => const Success<void, GroupFailure>(null));
      await cubit.load('meeting-1');

      await pumpScreen(tester);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      verify(() => repository.setMeetingPresence('meeting-1', any())).called(1);
    });

    testWidgets('durante envio desabilita botão e tiles e mostra spinner', (
      tester,
    ) async {
      await pumpScreen(tester, isSubmitting: true);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final tiles = tester.widgetList<PresenceAttendeeTile>(
        find.byType(PresenceAttendeeTile),
      );
      expect(tiles.every((t) => t.onChanged == null), isTrue);
    });

    testWidgets('em readOnly esconde o botão e desabilita os tiles', (
      tester,
    ) async {
      await pumpScreen(tester, readOnly: true, marked: {'u-1'});

      expect(find.byType(FilledButton), findsNothing);

      final tiles = tester.widgetList<PresenceAttendeeTile>(
        find.byType(PresenceAttendeeTile),
      );
      expect(tiles.every((t) => t.onChanged == null), isTrue);

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(ListView),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('no modo editável a opacidade da lista é 1', (tester) async {
      await pumpScreen(tester);

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(ListView),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 1);
    });
  });
}
