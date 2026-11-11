import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/pending_tasks_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

GroupEntity _group(int number, {bool canManageTasks = false}) {
  return GroupEntity(
    id: 'g$number',
    number: number,
    participantsCount: 8,
    cityState: 'Porto Alegre, RS',
    nextMeeting: GroupMeeting(
      id: 'm$number',
      hostName: 'Ana',
      bookTitle: 'Livro',
      date: '08/11/2026',
      location: 'Casa da Ana',
      canManageTasks: canManageTasks,
      tasksDone: 1,
    ),
  );
}

void main() {
  Widget buildSubject(HomeCubit cubit) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(value: cubit, child: const PendingTasksScreen()),
    );
  }

  testWidgets('lists only the groups with pending host tasks', (tester) async {
    final repository = MockGroupRepository();
    when(() => repository.getMyGroups()).thenAnswer(
      (_) async => Success([_group(1, canManageTasks: true), _group(2)]),
    );
    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(find.text('Tarefas pendentes'), findsOneWidget);
    expect(find.text('Grupo 1'), findsOneWidget);
    expect(find.text('Grupo 2'), findsNothing);
    expect(find.text('Minhas tarefas'), findsOneWidget);
    expect(find.text('Próximo evento'), findsNothing);
  });

  testWidgets('shows an empty message when there are no pending tasks', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => Success([_group(2)]));
    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(find.text('Você não tem tarefas pendentes'), findsOneWidget);
  });

  testWidgets('shows a retry action when loading groups fails', (tester) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Failure(GroupListFailure()));
    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar seus grupos. Tente novamente.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    verify(() => repository.getMyGroups()).called(2);
  });

  testWidgets(
    'lists one card per pending meeting when a group has two of them',
    (tester) async {
      GroupMeeting pending(String id, int tasksDone) => GroupMeeting(
        id: id,
        hostName: 'Ana',
        bookTitle: 'Livro',
        date: '',
        location: '',
        canManageTasks: true,
        tasksDone: tasksDone,
      );
      final repository = MockGroupRepository();
      when(() => repository.getMyGroups()).thenAnswer(
        (_) async => Success([
          GroupEntity(
            id: 'g1',
            number: 1,
            participantsCount: 8,
            cityState: 'Porto Alegre, RS',
            pendingMeetings: [pending('m-ended', 1), pending('m-draft', 0)],
          ),
        ]),
      );
      final cubit = HomeCubit(groupRepository: repository);
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit));
      await cubit.loadGroups();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Grupo 1'), findsNWidgets(2));
      expect(find.text('Minhas tarefas'), findsNWidgets(2));
      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('0/2'), findsOneWidget);
    },
  );
}
