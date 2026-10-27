import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_tasks_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_tasks_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

const _draft = MeetingTasksEntity(
  meetingId: 'meeting-1',
  status: MeetingTaskStatus.created,
  canManageTasks: true,
  canConclude: false,
  schedule: MeetingScheduleTask(done: false),
  record: MeetingRecordTask(MeetingRecordStatus.locked),
  bookTitle: 'A Hora da Estrela',
  bookAuthor: 'Clarice Lispector',
  groupName: 'Grupo 12',
);

final _scheduled = MeetingTasksEntity(
  meetingId: 'meeting-1',
  status: MeetingTaskStatus.scheduled,
  canManageTasks: true,
  canConclude: false,
  schedule: MeetingScheduleTask(
    done: true,
    date: DateTime(2026, 8, 22, 15),
    location: 'Rua Harmonia, 512',
  ),
  record: const MeetingRecordTask(MeetingRecordStatus.locked),
  bookTitle: 'A Hora da Estrela',
);

MeetingTasksEntity _withState({
  MeetingTaskStatus? status,
  bool? canConclude,
  MeetingRecordStatus? record,
}) => MeetingTasksEntity(
  meetingId: _scheduled.meetingId,
  status: status ?? _scheduled.status,
  canManageTasks: true,
  canConclude: canConclude ?? _scheduled.canConclude,
  schedule: _scheduled.schedule,
  record: MeetingRecordTask(record ?? _scheduled.record.status),
  bookTitle: _scheduled.bookTitle,
);

void main() {
  late MockGroupRepository repository;
  late List<String> visited;
  late Map<String, dynamic>? attendanceExtra;

  setUp(() {
    repository = MockGroupRepository();
    visited = [];
    attendanceExtra = null;
  });

  /// Responde `get-meeting-tasks` com cada item da lista, em ordem; o último
  /// se repete nas chamadas seguintes.
  void answerTasks(List<Result<MeetingTasksEntity, GroupFailure>> results) {
    var call = 0;
    when(() => repository.getMeetingTasks('meeting-1')).thenAnswer((_) async {
      final result = results[call < results.length ? call : results.length - 1];
      call++;
      return result;
    });
  }

  GoRoute stubRoute(String path) => GoRoute(
    path: path,
    builder: (context, state) {
      visited.add(state.uri.toString());
      if (path == GroupRoutes.meetingAttendance) {
        attendanceExtra = state.extra as Map<String, dynamic>?;
      }
      return Scaffold(
        appBar: ScreenHeader.back(title: path),
        body: TextButton(
          onPressed: () => context.pop(true),
          child: const Text('stub-done'),
        ),
      );
    },
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '${GroupRoutes.meetingTasks}?meeting_id=meeting-1',
      routes: [
        GoRoute(
          path: GroupRoutes.meetingTasks,
          builder: (context, state) => BlocProvider(
            create: (_) => MeetingTasksCubit(
              groupRepository: repository,
              meetingId: 'meeting-1',
            )..load(),
            child: const MeetingTasksScreen(meetingId: 'meeting-1'),
          ),
        ),
        stubRoute(GroupRoutes.meetingEdit),
        stubRoute(GroupRoutes.meetingRecord),
        stubRoute(GroupRoutes.meetingAttendance),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
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
      ),
    );
    await tester.pumpAndSettle();
  }

  AppButton buttonWithLabel(WidgetTester tester, String label) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, label));

  testWidgets('draft meeting: task 1 pending, task 2 and conclusion locked', (
    tester,
  ) async {
    answerTasks([const Success(_draft)]);
    await pumpScreen(tester);

    expect(find.text('Suas tarefas'), findsOneWidget);
    expect(find.text('VOCÊ FOI SORTEADA'), findsOneWidget);
    expect(find.text('A Hora da Estrela'), findsOneWidget);
    expect(find.text('Clarice Lispector · Grupo 12'), findsOneWidget);
    expect(find.text('2 tarefas para você'), findsOneWidget);
    expect(
      find.text('O grupo está esperando para saber quando e onde.'),
      findsOneWidget,
    );
    expect(find.text('Marcar agora'), findsOneWidget);
    expect(
      find.text('Disponível depois que o encontro acontecer.'),
      findsOneWidget,
    );
    expect(find.text('Enviar fotos'), findsNothing);
    expect(
      find.text('Este botão ficará ativo quando o encontro iniciar.'),
      findsOneWidget,
    );
    expect(buttonWithLabel(tester, 'Encerrar encontro').onPressed, isNull);
  });

  testWidgets('Marcar agora opens edit and reloads with schedule done', (
    tester,
  ) async {
    answerTasks([const Success(_draft), Success(_scheduled)]);
    await pumpScreen(tester);

    await tester.tap(find.text('Marcar agora'));
    await tester.pumpAndSettle();
    expect(visited.single, '${GroupRoutes.meetingEdit}?meeting_id=meeting-1');

    await tester.tap(find.text('stub-done'));
    await tester.pumpAndSettle();

    verify(() => repository.getMeetingTasks('meeting-1')).called(2);
    expect(find.text('TUDO CERTO'), findsOneWidget);
    expect(find.text('Encontro publicado'), findsOneWidget);
    expect(find.text('As participantes já foram avisadas.'), findsOneWidget);
    expect(find.text('1 tarefa para você'), findsOneWidget);
    expect(
      find.text('Sábado, 22 de agosto · 15h\nRua Harmonia, 512'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Marcar agora'), findsNothing);
    // Tarefa 1 concluída, mas o encontro não iniciou.
    expect(buttonWithLabel(tester, 'Encerrar encontro').onPressed, isNull);
    expect(
      find.text('Este botão ficará ativo quando o encontro iniciar.'),
      findsOneWidget,
    );
  });

  testWidgets('conclude button is active once the meeting started', (
    tester,
  ) async {
    answerTasks([
      Success(
        _withState(status: MeetingTaskStatus.inProgress, canConclude: true),
      ),
    ]);
    await pumpScreen(tester);

    expect(buttonWithLabel(tester, 'Encerrar encontro').onPressed, isNotNull);
    expect(
      find.text('Este botão ficará ativo quando o encontro iniciar.'),
      findsNothing,
    );
  });

  testWidgets('closing the modal with X changes nothing', (tester) async {
    answerTasks([
      Success(
        _withState(status: MeetingTaskStatus.inProgress, canConclude: true),
      ),
    ]);
    await pumpScreen(tester);

    await tester.tap(find.text('Encerrar encontro'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(visited, isEmpty);
  });

  testWidgets('shows minutes in the scheduled time', (tester) async {
    answerTasks([
      Success(
        MeetingTasksEntity(
          meetingId: 'meeting-1',
          status: MeetingTaskStatus.scheduled,
          canManageTasks: true,
          canConclude: false,
          schedule: MeetingScheduleTask(
            done: true,
            date: DateTime(2026, 8, 22, 15, 5),
          ),
          record: const MeetingRecordTask(MeetingRecordStatus.locked),
        ),
      ),
    ]);
    await pumpScreen(tester);

    expect(find.text('Sábado, 22 de agosto · 15h05'), findsOneWidget);
  });

  testWidgets('answering Não in the modal closes it and changes nothing', (
    tester,
  ) async {
    answerTasks([
      Success(
        _withState(status: MeetingTaskStatus.inProgress, canConclude: true),
      ),
    ]);
    await pumpScreen(tester);

    await tester.tap(find.text('Encerrar encontro'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Você deseja mesmo encerrar o encontro? '
        'Para concluir, preencha a lista de presença.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(visited, isEmpty);
    verify(() => repository.getMeetingTasks('meeting-1')).called(1);
  });

  testWidgets(
    'Sim opens attendance; going back without concluding keeps it open',
    (tester) async {
      final inProgress = _withState(
        status: MeetingTaskStatus.inProgress,
        canConclude: true,
      );
      answerTasks([Success(inProgress)]);
      await pumpScreen(tester);

      await tester.tap(find.text('Encerrar encontro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();

      expect(
        visited.single,
        '${GroupRoutes.meetingAttendance}?meeting_id=meeting-1',
      );
      expect(attendanceExtra, {
        'meetingName': 'A Hora da Estrela',
        'formattedDate': '22/08/2026',
        'concludeOnFinish': true,
      });

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verifyNever(() => repository.concludeMeeting(any()));
      expect(buttonWithLabel(tester, 'Encerrar encontro').onPressed, isNotNull);
    },
  );

  testWidgets('after concluding, task 2 is available and conclusion hides', (
    tester,
  ) async {
    answerTasks([
      Success(
        _withState(status: MeetingTaskStatus.inProgress, canConclude: true),
      ),
      Success(
        _withState(
          status: MeetingTaskStatus.concluded,
          record: MeetingRecordStatus.pending,
        ),
      ),
      Success(
        _withState(
          status: MeetingTaskStatus.concluded,
          record: MeetingRecordStatus.published,
        ),
      ),
    ]);
    await pumpScreen(tester);

    await tester.tap(find.text('Encerrar encontro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('stub-done'));
    await tester.pumpAndSettle();

    expect(find.text('Encerrar encontro'), findsNothing);
    expect(
      find.text('Este botão ficará ativo quando o encontro iniciar.'),
      findsNothing,
    );
    expect(
      find.text('Depois do encontro, compartilhe como foi.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Enviar fotos'));
    await tester.pumpAndSettle();
    expect(visited.last, '${GroupRoutes.meetingRecord}?meeting_id=meeting-1');

    await tester.tap(find.text('stub-done'));
    await tester.pumpAndSettle();

    expect(find.text('Registro publicado.'), findsOneWidget);
    expect(find.text('Todas as tarefas concluídas'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.text('Enviar fotos'), findsNothing);
  });

  testWidgets('draft record keeps the button and shows the draft tag', (
    tester,
  ) async {
    answerTasks([
      Success(
        _withState(
          status: MeetingTaskStatus.concluded,
          record: MeetingRecordStatus.draft,
        ),
      ),
    ]);
    await pumpScreen(tester);

    expect(find.text('Rascunho salvo'), findsOneWidget);
    expect(
      find.text('Você tem um rascunho salvo. Continue de onde parou.'),
      findsOneWidget,
    );
    expect(find.text('Enviar fotos'), findsOneWidget);
  });

  testWidgets('shows the error and retries', (tester) async {
    answerTasks([const Failure(MeetingTasksFailure()), const Success(_draft)]);
    await pumpScreen(tester);

    expect(
      find.text('Não foi possível carregar suas tarefas. Tente novamente.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Marcar agora'), findsOneWidget);
  });
}
