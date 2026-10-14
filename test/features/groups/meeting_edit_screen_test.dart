import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_screen.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

Widget _wrap({
  required MeetingDetailsEntity meeting,
  ValueChanged<MeetingEditResult>? onSaved,
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
      body: MeetingEditScreen(meeting: meeting, onSaved: onSaved),
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

  testWidgets('renders the edit page with its back header', (tester) async {
    await tester.pumpWidget(
      _localizedApp(const MeetingEditPage(meeting: meeting)),
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
    when(
      () => repository.getMeetingPhotos(any()),
    ).thenAnswer((_) async => const Success([]));

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
    when(
      () => repository.getMeetingPhotos(any()),
    ).thenAnswer((_) async => const Success([]));

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
          builder: (context, state) =>
              MeetingEditPage(meeting: state.extra! as MeetingDetailsEntity),
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
