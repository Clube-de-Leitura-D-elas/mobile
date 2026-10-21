import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_screen.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

Widget _wrap({
  required MeetingDetailsEntity meeting,
  ValueChanged<MeetingEditResult>? onSaved,
  GroupRepository? repository,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('pt', 'BR'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: _withEditCubits(
        repository ?? MockGroupRepository(),
        MeetingEditScreen(meeting: meeting, onSaved: onSaved),
      ),
    ),
  );
}

void main() {
  const meeting = MeetingDetailsEntity(
    id: 'meeting-1',
    number: 12,
    bookTitle: 'Dom Casmurro',
    hostName: 'Beatriz Souza',
    locationName: 'Café Literário',
    locationAddress: 'Rua das Flores, 12',
    description: 'Discussão dos principais temas do livro.',
  );

  testWidgets('prefills editable and read-only meeting fields', (tester) async {
    await tester.pumpWidget(_wrap(meeting: meeting));

    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('Beatriz Souza'), findsOneWidget);
    expect(find.text('Café Literário - Rua das Flores, 12'), findsOneWidget);
    expect(
      find.text('Discussão dos principais temas do livro.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows validation errors and keeps form open when required fields are empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          meeting: const MeetingDetailsEntity(
            id: 'draft',
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
          ),
        ),
      );

      final saveButton = find.text('Salvar alterações');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Informe a data.'), findsOneWidget);
      expect(find.text('Informe o horário.'), findsOneWidget);
      expect(find.text('Informe o local.'), findsOneWidget);
      expect(find.byType(MeetingEditScreen), findsOneWidget);
    },
  );

  const place = PlaceSuggestionEntity(
    googlePlaceId: 'place-1',
    name: 'Café Paris',
    address: 'R. A, 10',
  );

  Future<void> fillDateAndTime(WidgetTester tester, String date) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), date);
    await tester.enterText(fields.at(1), '19:30');
  }

  Future<void> tapSave(WidgetTester tester) async {
    final saveButton = find.text('Salvar alterações');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
  }

  testWidgets('given an impossible date, when saving, then shows the error', (
    tester,
  ) async {
    MeetingEditResult? saved;
    await tester.pumpWidget(
      _wrap(meeting: meeting, onSaved: (result) => saved = result),
    );

    await fillDateAndTime(tester, '32/13/2026');
    await tapSave(tester);

    expect(find.text('Informe uma data válida (DD/MM/AAAA).'), findsOneWidget);
    expect(saved, isNull);
  });

  testWidgets(
    'given the location was not changed, when saving, then keeps the current place',
    (tester) async {
      MeetingEditResult? saved;
      await tester.pumpWidget(
        _wrap(meeting: meeting, onSaved: (result) => saved = result),
      );

      await fillDateAndTime(tester, '30/10/2026');
      await tapSave(tester);

      expect(saved?.date, DateTime(2026, 10, 30, 19, 30));
      expect(saved?.googlePlaceId, isNull);
      expect(saved?.description, 'Discussão dos principais temas do livro.');
    },
  );

  testWidgets(
    'given a typed location without a suggestion, when saving, then asks to pick one',
    (tester) async {
      final repository = MockGroupRepository();
      when(
        () => repository.searchPlaces(any()),
      ).thenAnswer((_) async => const Success([]));
      MeetingEditResult? saved;
      await tester.pumpWidget(
        _wrap(
          meeting: meeting,
          repository: repository,
          onSaved: (result) => saved = result,
        ),
      );

      await fillDateAndTime(tester, '30/10/2026');
      await tester.enterText(find.byType(TextField).at(2), 'Café Paris');
      await tester.pump(const Duration(milliseconds: 1));
      await tapSave(tester);

      expect(find.text('Selecione um local da lista.'), findsOneWidget);
      expect(saved, isNull);
    },
  );

  testWidgets(
    'given a chosen suggestion, when saving, then returns the place id',
    (tester) async {
      final repository = MockGroupRepository();
      when(
        () => repository.searchPlaces('Café Paris'),
      ).thenAnswer((_) async => const Success([place]));
      MeetingEditResult? saved;
      await tester.pumpWidget(
        _wrap(
          meeting: meeting,
          repository: repository,
          onSaved: (result) => saved = result,
        ),
      );

      await fillDateAndTime(tester, '30/10/2026');
      await tester.enterText(find.byType(TextField).at(2), 'Café Paris');
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      final suggestion = find.byKey(const ValueKey('place-suggestion-place-1'));
      await tester.ensureVisible(suggestion);
      await tester.tap(suggestion);
      await tester.pump();
      await tapSave(tester);

      expect(find.text('Café Paris - R. A, 10'), findsOneWidget);
      expect(saved?.googlePlaceId, 'place-1');
    },
  );

  testWidgets('renders the edit page with its back header', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        _withEditCubits(
          MockGroupRepository(),
          const MeetingEditPage(meeting: meeting),
        ),
      ),
    );

    expect(find.byType(MeetingEditScreen), findsOneWidget);
    expect(find.byTooltip('Voltar'), findsOneWidget);
    expect(find.text('Editar encontro'), findsOneWidget);

    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pump();
  });

  testWidgets('shows edit action only when editing is allowed', (tester) async {
    final repository = MockGroupRepository();
    when(() => repository.getMeetingPhotos(any())).thenAnswer(
      (_) async =>
          const Success(MeetingPhotosEntity(photos: [], canAddPhotos: true)),
    );

    await tester.pumpWidget(
      _localizedApp(
        _withMeetingPhotos(
          repository,
          const MeetingDetailsScreen(meeting: meeting, canEdit: false),
        ),
      ),
    );
    expect(find.byTooltip('Editar encontro'), findsNothing);

    await tester.pumpWidget(
      _localizedApp(
        _withMeetingPhotos(
          repository,
          const MeetingDetailsScreen(meeting: meeting, canEdit: true),
        ),
      ),
    );
    expect(find.byTooltip('Editar encontro'), findsOneWidget);
  });

  testWidgets('group edit route renders the edit page from state extra', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<MeetingEditCubit>(
      () => MeetingEditCubit(groupRepository: repository),
    );
    serviceLocator.registerFactory<PlaceSearchCubit>(
      () => PlaceSearchCubit(groupRepository: repository),
    );
    addTearDown(() {
      serviceLocator.unregister<MeetingEditCubit>();
      serviceLocator.unregister<PlaceSearchCubit>();
    });

    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, state) => TextButton(
            onPressed: () =>
                context.push(GroupRoutePaths.meetingEdit, extra: meeting),
            child: const Text('open'),
          ),
        ),
        ...GroupRoutes.routes,
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
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingEditPage), findsOneWidget);
    router.dispose();
  });

  testWidgets('edit action navigates to the edit page', (tester) async {
    final repository = MockGroupRepository();
    when(() => repository.getMeetingPhotos(any())).thenAnswer(
      (_) async =>
          const Success(MeetingPhotosEntity(photos: [], canAddPhotos: true)),
    );

    final router = GoRouter(
      initialLocation: '/details',
      routes: [
        GoRoute(
          path: '/details',
          builder: (context, state) => _withMeetingPhotos(
            repository,
            const MeetingDetailsScreen(meeting: meeting, canEdit: true),
          ),
        ),
        GoRoute(
          path: GroupRoutePaths.meetingEdit,
          builder: (context, state) => _withEditCubits(
            repository,
            MeetingEditPage(meeting: state.extra! as MeetingDetailsEntity),
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

    await tester.tap(find.byTooltip('Editar encontro'));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingEditPage), findsOneWidget);
    router.dispose();
  });
}

Widget _withMeetingPhotos(MockGroupRepository repository, Widget child) {
  return BlocProvider(
    create: (_) => MeetingPhotosCubit(
      groupRepository: repository,
      photoPicker: MockPhotoPicker(),
    ),
    child: child,
  );
}

Widget _localizedApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('pt', 'BR'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

Widget _withEditCubits(GroupRepository repository, Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => MeetingEditCubit(groupRepository: repository),
      ),
      BlocProvider(
        create: (_) => PlaceSearchCubit(
          groupRepository: repository,
          debounce: Duration.zero,
        ),
      ),
    ],
    child: child,
  );
}
