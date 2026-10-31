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
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_tasks_content.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

Widget _wrapRouter(GoRouter router) {
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

// Sem data: evita depender da inicialização de intl para 'pt_BR'.
MeetingTasksEntity _tasks({
  required MeetingTaskStatus status,
  required bool scheduleDone,
}) {
  return MeetingTasksEntity(
    meetingId: 'meeting-1',
    status: status,
    canManageTasks: true,
    canConclude: false,
    schedule: MeetingScheduleTask(
      done: scheduleDone,
      location: scheduleDone ? 'Z Café TECNOPUC' : null,
    ),
    record: const MeetingRecordTask(MeetingRecordStatus.locked),
  );
}

void main() {
  late MockGroupRepository repository;
  late MeetingTasksCubit cubit;

  setUp(() {
    repository = MockGroupRepository();
    cubit = MeetingTasksCubit(
      groupRepository: repository,
      meetingId: 'meeting-1',
    );
    when(
      () => repository.getMeetingTasks('meeting-1'),
    ).thenAnswer((_) async => const Failure(MeetingTasksFailure()));
  });

  tearDown(() => cubit.close());

  GoRouter routerFor(MeetingTasksEntity tasks) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: BlocProvider<MeetingTasksCubit>.value(
              value: cubit,
              child: MeetingTasksContent(meetingId: 'meeting-1', tasks: tasks),
            ),
          ),
        ),
        GoRoute(
          path: GroupRoutes.meetingEdit,
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'Voltar das tarefas',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: Text('edit:${state.uri.queryParameters['meeting_id']}'),
          ),
        ),
      ],
    );
  }

  Finder scheduleEditButton() => find.descendant(
    of: find.byKey(const ValueKey('meeting_task_schedule')),
    matching: find.byIcon(Icons.edit_outlined),
  );

  group('MeetingTasksContent - botão de editar data e local', () {
    testWidgets(
      'Given a scheduled meeting with date and location saved, When rendering, Then shows the edit button',
      (tester) async {
        final router = routerFor(
          _tasks(status: MeetingTaskStatus.scheduled, scheduleDone: true),
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(_wrapRouter(router));

        expect(scheduleEditButton(), findsOneWidget);
      },
    );

    testWidgets(
      'Given a meeting without date and location, When rendering, Then hides the edit button',
      (tester) async {
        final router = routerFor(
          _tasks(status: MeetingTaskStatus.created, scheduleDone: false),
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(_wrapRouter(router));

        expect(scheduleEditButton(), findsNothing);
      },
    );

    for (final status in [
      MeetingTaskStatus.inProgress,
      MeetingTaskStatus.ended,
      MeetingTaskStatus.concluded,
    ]) {
      testWidgets(
        'Given a $status meeting with schedule done, When rendering, Then hides the edit button',
        (tester) async {
          final router = routerFor(_tasks(status: status, scheduleDone: true));
          addTearDown(router.dispose);

          await tester.pumpWidget(_wrapRouter(router));

          expect(scheduleEditButton(), findsNothing);
        },
      );
    }

    testWidgets(
      'Given a scheduled meeting, When tapping edit, Then opens the edit route with the meeting id and reloads tasks on return',
      (tester) async {
        final router = routerFor(
          _tasks(status: MeetingTaskStatus.scheduled, scheduleDone: true),
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(_wrapRouter(router));

        await tester.tap(scheduleEditButton());
        await tester.pumpAndSettle();

        expect(find.text('edit:meeting-1'), findsOneWidget);
        verifyNever(() => repository.getMeetingTasks('meeting-1'));

        await tester.tap(find.byTooltip('Voltar das tarefas'));
        await tester.pumpAndSettle();

        verify(() => repository.getMeetingTasks('meeting-1')).called(1);
      },
    );
  });
}
