import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_state.dart';
import 'package:mobile/features/groups/presentation/pages/event_history_page.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_card.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockEventHistoryCubit extends Mock implements EventHistoryCubit {}

Widget _wrap(EventHistoryState state) {
  final cubit = MockEventHistoryCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => Stream.value(state));

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
    home: BlocProvider<EventHistoryCubit>.value(
      value: cubit,
      child: const EventHistoryPage(),
    ),
  );
}

void main() {
  const meeting = GroupMeeting(
    id: 'meeting-1',
    bookTitle: 'Quarto de Despejo',
    hostName: 'Ana Souza',
    date: '2026-08-22T00:00:00Z',
    location: '',
  );

  testWidgets('displays a loading indicator while events are loading', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EventHistoryLoading()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays an empty-state message when there are no events', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EventHistoryEmpty()));

    expect(
      find.text('Este grupo ainda não realizou encontros.'),
      findsOneWidget,
    );
  });

  testWidgets('displays event cards when events are loaded', (tester) async {
    await tester.pumpWidget(_wrap(const EventHistoryLoaded([meeting])));

    expect(find.text('Histórico de eventos'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byType(EventHistoryCard), findsOneWidget);
  });

  testWidgets('displays the error message when event loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const EventHistoryError('Não foi possível carregar eventos.')),
    );

    expect(find.text('Não foi possível carregar eventos.'), findsOneWidget);
  });
}
