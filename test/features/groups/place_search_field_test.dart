import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/place_suggestion_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/widgets/place_search_field.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;
  late TextEditingController controller;

  setUp(() {
    repository = MockGroupRepository();
    controller = TextEditingController();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpField(WidgetTester tester) {
    return tester.pumpWidget(
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
        home: Scaffold(
          body: BlocProvider(
            create: (_) => PlaceSearchCubit(
              groupRepository: repository,
              debounce: Duration.zero,
            ),
            child: PlaceSearchField(
              controller: controller,
              onSelected: (_) {},
              onEdited: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'given the search fails, when typing, then shows the search error',
    (tester) async {
      when(
        () => repository.searchPlaces('Café'),
      ).thenAnswer((_) async => const Failure(PlaceSearchFailure()));
      await pumpField(tester);

      await tester.enterText(find.byType(TextField), 'Café');
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();

      expect(
        find.text('Não foi possível buscar locais. Tente novamente.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('given a slow search, when typing, then shows the loading bar', (
    tester,
  ) async {
    final response =
        Completer<Result<List<PlaceSuggestionEntity>, GroupFailure>>();
    when(
      () => repository.searchPlaces('Café'),
    ).thenAnswer((_) => response.future);
    await pumpField(tester);

    await tester.enterText(find.byType(TextField), 'Café');
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    response.complete(const Success([]));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
