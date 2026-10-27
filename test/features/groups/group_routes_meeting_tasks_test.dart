import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_tasks_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

const _meeting = MeetingDetailsEntity(
  id: 'meeting-1',
  bookTitle: 'A Hora da Estrela',
  hostName: 'Cida',
);

void main() {
  late MockGroupRepository repository;

  void register<T extends Object>(T Function() factory) {
    if (serviceLocator.isRegistered<T>()) serviceLocator.unregister<T>();
    serviceLocator.registerFactory<T>(factory);
  }

  void unregister<T extends Object>() {
    if (serviceLocator.isRegistered<T>()) serviceLocator.unregister<T>();
  }

  setUp(() {
    repository = MockGroupRepository();
    serviceLocator.allowReassignment = true;
    register<GroupRepository>(() => repository);
    register<MeetingDetailsCubit>(
      () => MeetingDetailsCubit(groupRepository: repository),
    );
    register<MeetingEditCubit>(
      () => MeetingEditCubit(groupRepository: repository),
    );
    register<PlaceSearchCubit>(
      () => PlaceSearchCubit(groupRepository: repository),
    );
    register<MeetingPhotosCubit>(
      () => MeetingPhotosCubit(
        groupRepository: repository,
        photoPicker: MockPhotoPicker(),
      ),
    );
  });

  tearDown(() {
    unregister<GroupRepository>();
    unregister<MeetingDetailsCubit>();
    unregister<MeetingEditCubit>();
    unregister<PlaceSearchCubit>();
    unregister<MeetingPhotosCubit>();
  });

  Future<void> pumpRoute(WidgetTester tester, String location) async {
    final router = GoRouter(
      initialLocation: location,
      routes: GroupRoutes.routes,
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
  }

  group('meetingEdit sem o encontro em extra', () {
    const location = '${GroupRoutes.meetingEdit}?meeting_id=meeting-1';

    testWidgets('mostra loading enquanto busca os detalhes', (tester) async {
      final completer = Completer<Result<MeetingDetailsEntity, GroupFailure>>();
      when(
        () => repository.getMeetingDetails('meeting-1'),
      ).thenAnswer((_) => completer.future);

      await pumpRoute(tester, location);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Editar encontro'), findsOneWidget);

      completer.complete(const Success(_meeting));
      await tester.pumpAndSettle();
    });

    testWidgets('mostra o erro quando os detalhes falham', (tester) async {
      when(
        () => repository.getMeetingDetails('meeting-1'),
      ).thenAnswer((_) async => const Failure(MeetingTasksFailure()));

      await pumpRoute(tester, location);
      await tester.pumpAndSettle();

      expect(find.text(const MeetingTasksFailure().message), findsOneWidget);
      expect(find.byType(MeetingEditPage), findsNothing);
    });

    testWidgets('abre a edição com os cubits necessários', (tester) async {
      when(
        () => repository.getMeetingDetails('meeting-1'),
      ).thenAnswer((_) async => const Success(_meeting));

      await pumpRoute(tester, location);
      await tester.pumpAndSettle();

      final page = tester.widget<MeetingEditPage>(find.byType(MeetingEditPage));
      expect(page.meeting, _meeting);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('meetingRecord abre os detalhes do encontro', (tester) async {
    when(
      () => repository.getMeetingDetails('meeting-1'),
    ).thenAnswer((_) async => const Success(_meeting));
    when(
      () => repository.getMeetingPhotos('meeting-1'),
    ).thenAnswer((_) async => const Failure(MeetingTasksFailure()));

    await pumpRoute(
      tester,
      '${GroupRoutes.meetingRecord}?meeting_id=meeting-1',
    );
    await tester.pumpAndSettle();

    expect(find.byType(MeetingDetailsPage), findsOneWidget);
    verify(() => repository.getMeetingDetails('meeting-1')).called(1);
    verify(() => repository.getMeetingPhotos('meeting-1')).called(1);
  });

  testWidgets('meetingRecord usa meeting_id vazio sem o parâmetro', (
    tester,
  ) async {
    when(
      () => repository.getMeetingDetails(''),
    ).thenAnswer((_) async => const Failure(MeetingTasksFailure()));
    when(
      () => repository.getMeetingPhotos(''),
    ).thenAnswer((_) async => const Failure(MeetingTasksFailure()));

    await pumpRoute(tester, GroupRoutes.meetingRecord);
    await tester.pumpAndSettle();

    verify(() => repository.getMeetingDetails('')).called(1);
  });

  testWidgets('meetingTasks carrega as tarefas do encontro', (tester) async {
    when(() => repository.getMeetingTasks('meeting-1')).thenAnswer(
      (_) async => const Success(
        MeetingTasksEntity(
          meetingId: 'meeting-1',
          status: MeetingTaskStatus.created,
          canManageTasks: true,
          canConclude: false,
          schedule: MeetingScheduleTask(done: false),
          record: MeetingRecordTask(MeetingRecordStatus.locked),
        ),
      ),
    );

    await pumpRoute(tester, '${GroupRoutes.meetingTasks}?meeting_id=meeting-1');
    await tester.pumpAndSettle();

    final screen = tester.widget<MeetingTasksScreen>(
      find.byType(MeetingTasksScreen),
    );
    expect(screen.meetingId, 'meeting-1');
    expect(find.text('Marcar agora'), findsOneWidget);
  });

  for (final location in [
    GroupRoutes.meetingTasks,
    '${GroupRoutes.meetingTasks}?meeting_id=',
  ]) {
    testWidgets('meetingTasks sem meeting_id mostra encontro inválido '
        '($location)', (tester) async {
      await pumpRoute(tester, location);
      await tester.pumpAndSettle();

      expect(find.text('Suas tarefas'), findsOneWidget);
      expect(find.text('Encontro inválido.'), findsOneWidget);
      expect(find.byType(MeetingTasksScreen), findsNothing);
      verifyNever(() => repository.getMeetingTasks(any()));
    });
  }
}
