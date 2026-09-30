import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_content.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_error_view.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_skeleton.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupParticipantsRepository extends Mock
    implements GroupParticipantsRepository {}

typedef ParticipantsResult = Result<List<GroupParticipantEntity>, GroupFailure>;

void main() {
  late MockGroupParticipantsRepository repository;

  const coordinator = GroupParticipantEntity(
    id: 'c',
    name: 'Roberta',
    isCoordinator: true,
  );
  // Network photos are covered in participant_avatar_test.dart; keeping these
  // fixtures photo-less avoids real image requests under pumpAndSettle.
  const ana = GroupParticipantEntity(id: 'a', name: 'Ana Beatriz');
  const carla = GroupParticipantEntity(id: 'b', name: 'Carla Souza');

  setUp(() => repository = MockGroupParticipantsRepository());

  void answer(ParticipantsResult result) {
    when(() => repository.getParticipants('g')).thenAnswer((_) async => result);
  }

  Widget buildApp(Widget child) => MaterialApp(
    theme: AppTheme.light.copyWith(splashFactory: NoSplash.splashFactory),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: BlocProvider(
      create: (_) =>
          GroupParticipantsCubit(participantsRepository: repository)..load('g'),
      child: child,
    ),
  );

  Widget buildSection() => buildApp(
    const Scaffold(
      body: SingleChildScrollView(child: GroupParticipantsContent()),
    ),
  );

  testWidgets(
    'given a pending request, then shows the skeleton without the list',
    (tester) async {
      final pending = Completer<ParticipantsResult>();
      when(
        () => repository.getParticipants('g'),
      ).thenAnswer((_) => pending.future);

      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(buildSection());
      await tester.pump();

      expect(find.byType(GroupParticipantsSkeleton), findsOneWidget);
      expect(find.bySemanticsLabel('Carregando participantes'), findsOneWidget);
      expect(find.byType(ParticipantTile), findsNothing);

      pending.complete(const Success([coordinator, ana]));
      await tester.pumpAndSettle();
      expect(find.byType(GroupParticipantsSkeleton), findsNothing);

      semantics.dispose();
    },
  );

  testWidgets('given participants, then renders a row with name per person', (
    tester,
  ) async {
    answer(const Success([coordinator, ana, carla]));

    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    expect(find.byType(ParticipantTile), findsNWidgets(3));
    expect(find.text('Roberta'), findsOneWidget);
    expect(find.text('Ana Beatriz'), findsOneWidget);
    expect(find.text('Carla Souza'), findsOneWidget);
    expect(find.byType(ParticipantAvatar), findsNWidgets(3));
  });

  testWidgets('given a participant without photo, then shows the placeholder', (
    tester,
  ) async {
    answer(const Success([carla]));

    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    final tile = find.byKey(const ValueKey('participant-b'));
    expect(
      find.descendant(
        of: tile,
        matching: find.byType(ParticipantAvatarPlaceholder),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tile, matching: find.byIcon(Icons.person_outline)),
      findsOneWidget,
    );
  });

  testWidgets(
    'given a very long name on a narrow screen, then truncates in one line',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const longName =
          'Maria Eduarda Albuquerque Cavalcanti de Oliveira Figueiredo Santos';
      answer(const Success([GroupParticipantEntity(id: 'l', name: longName)]));

      await tester.pumpWidget(buildSection());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.text(longName));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(
        tester.getSize(find.byType(ParticipantTile)).height,
        ParticipantAvatar.size,
      );
      expect(tester.getRect(find.text(longName)).right, lessThanOrEqualTo(320));
    },
  );

  testWidgets('given only the coordinator, then renders the coordinator', (
    tester,
  ) async {
    answer(const Success([coordinator]));

    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    expect(find.text('Roberta'), findsOneWidget);
    expect(find.byType(ParticipantTile), findsOneWidget);
  });

  testWidgets('given no participants, then shows the empty message', (
    tester,
  ) async {
    answer(const Success([]));

    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    expect(
      find.text('Ainda não há participantes neste grupo.'),
      findsOneWidget,
    );
    expect(find.byType(ParticipantTile), findsNothing);
  });

  testWidgets('given an error, then retry fetches again and shows the list', (
    tester,
  ) async {
    var calls = 0;
    when(() => repository.getParticipants('g')).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        return const Failure(GroupParticipantsFailure(message: 'Falhou'));
      }
      return const Success([ana]);
    });

    await tester.pumpWidget(buildSection());
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar as participantes.'),
      findsOneWidget,
    );
    expect(find.text('Falhou'), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Ana Beatriz'), findsOneWidget);
    expect(find.byType(GroupParticipantsErrorView), findsNothing);
  });

  testWidgets(
    'given 30 participants, then the list scrolls with the page and has no '
    'nested scroll view',
    (tester) async {
      final many = List.generate(
        30,
        (i) => GroupParticipantEntity(id: '$i', name: 'Participante $i'),
      );
      answer(Success(many));

      await tester.pumpWidget(buildSection());
      await tester.pumpAndSettle();

      expect(find.byType(Scrollable), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Participante 29'),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Participante 29'), findsOneWidget);
    },
  );

  testWidgets(
    'given the details screen, when collapsing participants, then the list '
    'hides and the other section stays as it was',
    (tester) async {
      answer(const Success([coordinator, ana]));

      await tester.pumpWidget(
        buildApp(
          const GroupDetailsScreen(
            name: 'Grupo 1',
            genres: ['Ficção'],
            participantCount: 2,
            city: 'Porto Alegre',
            stateCode: 'RS',
            nextEventContent: Text('Conteúdo do evento'),
            participantsContent: GroupParticipantsContent(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final header = find.byKey(const ValueKey('section-Participantes'));
      await tester.ensureVisible(header);
      await tester.pumpAndSettle();
      expect(find.text('Ana Beatriz'), findsOneWidget);

      await tester.tap(header);
      await tester.pumpAndSettle();
      expect(find.text('Ana Beatriz'), findsNothing);
      expect(find.text('Conteúdo do evento'), findsOneWidget);

      await tester.tap(header);
      await tester.pumpAndSettle();
      expect(find.text('Ana Beatriz'), findsOneWidget);
      verify(() => repository.getParticipants('g')).called(1);
    },
  );
}
