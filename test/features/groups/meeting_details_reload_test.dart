import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

const _meeting = MeetingDetailsEntity(
  id: 'meeting-1',
  bookTitle: 'Dom Casmurro',
  hostName: 'Beatriz Souza',
);

void main() {
  late MockGroupRepository repository;

  setUp(() {
    repository = MockGroupRepository();
    when(
      () => repository.getMeetingPhotos(any()),
    ).thenAnswer(
      (_) async => const Success(
        MeetingPhotosEntity(photos: <MeetingPhotoEntity>[], canAddPhotos: true),
      ),
    );
    when(
      () => repository.getMeetingDetails('meeting-1'),
    ).thenAnswer((_) async => const Success(_meeting));
  });

  /// Detalhes com o botão de editar; a "edição" só tem um botão que fecha a
  /// tela devolvendo [result], como a página real faz depois de salvar.
  Future<GoRouter> pumpDetails(
    WidgetTester tester, {
    required bool? result,
  }) async {
    final router = GoRouter(
      initialLocation: '/details',
      routes: [
        GoRoute(
          path: '/details',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => MeetingDetailsCubit(groupRepository: repository),
              ),
              BlocProvider(
                create: (_) => MeetingPhotosCubit(
                  groupRepository: repository,
                  photoPicker: MockPhotoPicker(),
                )..load('meeting-1'),
              ),
            ],
            child: const MeetingDetailsScreen(meeting: _meeting, canEdit: true),
          ),
        ),
        GoRoute(
          path: GroupRoutePaths.meetingEdit,
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(result),
              child: const Text('close edit'),
            ),
          ),
        ),
      ],
    );

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

    await tester.tap(find.byTooltip('Editar encontro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close edit'));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets(
    'given the edit was saved, when coming back, then reloads the meeting',
    (tester) async {
      final router = await pumpDetails(tester, result: true);

      verify(() => repository.getMeetingDetails('meeting-1')).called(1);
      router.dispose();
    },
  );

  testWidgets(
    'given the edit was closed without saving, when coming back, then does not reload',
    (tester) async {
      final router = await pumpDetails(tester, result: null);

      verifyNever(() => repository.getMeetingDetails(any()));
      router.dispose();
    },
  );
}
