import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

const _meeting = MeetingDetailsEntity(
  id: 'meeting-1',
  bookTitle: 'Dom Casmurro',
  hostName: 'Beatriz Souza',
  locationName: 'Café Literário',
  locationAddress: 'Rua das Flores, 12',
);

void main() {
  late MockGroupRepository repository;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = MockGroupRepository();
  });

  void answerUpdateWith(Result<void, GroupFailure> result) {
    when(
      () => repository.updateMeeting(
        meetingId: any(named: 'meetingId'),
        date: any(named: 'date'),
        googlePlaceId: any(named: 'googlePlaceId'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) async => result);
  }

  /// Abre a página de edição por cima de uma tela inicial e guarda o valor
  /// devolvido quando ela fecha.
  Future<List<bool?>> pumpEditPage(WidgetTester tester) async {
    final results = <bool?>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              results.add(
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) =>
                              MeetingEditCubit(groupRepository: repository),
                        ),
                        BlocProvider(
                          create: (_) => PlaceSearchCubit(
                            groupRepository: repository,
                            debounce: Duration.zero,
                          ),
                        ),
                      ],
                      child: const MeetingEditPage(meeting: _meeting),
                    ),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '30/10/2026');
    await tester.enterText(fields.at(1), '19:30');

    final saveButton = find.text('Salvar alterações');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
  }

  testWidgets(
    'given the backend saves, when saving, then closes the page returning true',
    (tester) async {
      answerUpdateWith(const Success(null));
      final results = await pumpEditPage(tester);

      await fillAndSave(tester);
      await tester.pumpAndSettle();

      expect(find.byType(MeetingEditPage), findsNothing);
      expect(results, [true]);
      verify(
        () => repository.updateMeeting(
          meetingId: 'meeting-1',
          date: DateTime(2026, 10, 30, 19, 30),
          description: null,
        ),
      ).called(1);
    },
  );

  testWidgets(
    'given the meeting is locked, when saving, then shows the error and keeps the form',
    (tester) async {
      answerUpdateWith(const Failure(MeetingNotEditableFailure()));
      final results = await pumpEditPage(tester);

      await fillAndSave(tester);
      await tester.pump();

      expect(
        find.text('Este encontro não pode mais ser editado.'),
        findsOneWidget,
      );
      expect(find.byType(MeetingEditPage), findsOneWidget);
      expect(find.text('30/10/2026'), findsOneWidget);
      expect(results, isEmpty);

      // Deixa o toast terminar antes de encerrar o teste.
      await tester.pump(const Duration(seconds: 4));
    },
  );
}
