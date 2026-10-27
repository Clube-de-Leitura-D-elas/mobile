import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_attendance_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;

  const participant = MeetingAttendanceEntity(
    id: 'user-1',
    name: 'Ana Souza',
    photoUrl: null,
    invitationStatus: MeetingInvitationStatus.confirmed,
    presenceStatus: MeetingPresenceStatus.present,
  );

  setUp(() {
    repository = MockGroupRepository();
    serviceLocator.allowReassignment = true;

    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }

    serviceLocator.registerFactory<GroupRepository>(() => repository);
  });

  tearDown(() {
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
  });

  Widget createWidget() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MeetingAttendancePage(
        meetingId: 'meeting-1',
        meetingName: 'Encontro de leitura',
        formattedDate: '12/10/2026 às 19:00',
      ),
    );
  }

  group('MeetingAttendancePage', () {
    testWidgets('exibe carregamento enquanto busca a presença', (tester) async {
      when(() => repository.getMeetingAttendance('meeting-1')).thenAnswer((
        _,
      ) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return const Success([participant]);
      });

      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Encontro de leitura'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('exibe os participantes quando a busca tem sucesso', (
      tester,
    ) async {
      when(
        () => repository.getMeetingAttendance('meeting-1'),
      ).thenAnswer((_) async => const Success([participant]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('Presente'), findsOneWidget);

      verify(() => repository.getMeetingAttendance('meeting-1')).called(1);
    });

    testWidgets('exibe erro e permite tentar novamente', (tester) async {
      var calls = 0;

      when(() => repository.getMeetingAttendance('meeting-1')).thenAnswer((
        _,
      ) async {
        calls++;

        if (calls == 1) {
          return const Failure(GroupDetailsFailure(message: 'Erro de teste'));
        }

        return const Success([participant]);
      });

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível carregar a lista de presença.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Souza'), findsOneWidget);
      expect(calls, 2);
    });
  });

  group('MeetingAttendancePage aberta pelo "Encerrar encontro"', () {
    /// Abre a página com `concludeOnFinish` e guarda o valor devolvido ao fechar.
    Future<List<bool?>> pumpConcluding(WidgetTester tester) async {
      final results = <bool?>[];
      when(
        () => repository.getMeetingAttendance('meeting-1'),
      ).thenAnswer((_) async => const Success([participant]));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => results.add(
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const MeetingAttendancePage(
                      meetingId: 'meeting-1',
                      meetingName: 'Encontro de leitura',
                      formattedDate: '12/10/2026',
                      concludeOnFinish: true,
                    ),
                  ),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('sem concludeOnFinish não mostra o botão de concluir', (
      tester,
    ) async {
      when(
        () => repository.getMeetingAttendance('meeting-1'),
      ).thenAnswer((_) async => const Success([participant]));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Concluir lista de presença'), findsNothing);
    });

    testWidgets('concluir encerra o encontro e volta com true', (tester) async {
      final results = await pumpConcluding(tester);
      when(
        () => repository.concludeMeeting('meeting-1'),
      ).thenAnswer((_) async => const Success(null));

      await tester.tap(find.text('Concluir lista de presença'));
      await tester.pumpAndSettle();

      verify(() => repository.concludeMeeting('meeting-1')).called(1);
      expect(results, [true]);
    });

    testWidgets('voltar sem concluir não encerra o encontro', (tester) async {
      final results = await pumpConcluding(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verifyNever(() => repository.concludeMeeting(any()));
      expect(results, [null]);
    });

    testWidgets('falha ao encerrar mostra erro e continua na lista', (
      tester,
    ) async {
      final results = await pumpConcluding(tester);
      when(
        () => repository.concludeMeeting('meeting-1'),
      ).thenAnswer((_) async => const Failure(MeetingConclusionFailure()));

      await tester.tap(find.text('Concluir lista de presença'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Não foi possível encerrar o encontro. Tente novamente.'),
        findsOneWidget,
      );
      expect(results, isEmpty);
      expect(find.text('Ana Souza'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}
