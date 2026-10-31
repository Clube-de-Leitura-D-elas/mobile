import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_tasks/meeting_task_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
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
    home: Scaffold(body: child),
  );
}

MeetingTaskCard _card({
  required MeetingTaskCardState state,
  VoidCallback? onEdit,
  String? editLabel = 'Editar data e local',
}) {
  return MeetingTaskCard(
    title: 'Marcar data e local',
    description: 'Sábado, 22 de agosto · 15h',
    state: state,
    actionLabel: 'Marcar',
    onPressed: () {},
    onEdit: onEdit,
    editLabel: editLabel,
  );
}

void main() {
  group('MeetingTaskCard', () {
    testWidgets(
      'Given a done card with onEdit, When rendering, Then shows the edit button and the check',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_card(state: MeetingTaskCardState.done, onEdit: () {})),
        );

        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byTooltip('Editar data e local'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets(
      'Given a done card with onEdit, When rendering, Then the edit button is to the left of the check',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_card(state: MeetingTaskCardState.done, onEdit: () {})),
        );

        final editX = tester.getCenter(find.byIcon(Icons.edit_outlined)).dx;
        final checkX = tester.getCenter(find.byIcon(Icons.check_circle)).dx;

        expect(editX, lessThan(checkX));
      },
    );

    testWidgets(
      'Given a done card without onEdit, When rendering, Then hides the edit button',
      (tester) async {
        await tester.pumpWidget(_wrap(_card(state: MeetingTaskCardState.done)));

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      },
    );

    testWidgets(
      'Given a done card with onEdit but no editLabel, When rendering, Then hides the edit button',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _card(
              state: MeetingTaskCardState.done,
              onEdit: () {},
              editLabel: null,
            ),
          ),
        );

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      },
    );

    testWidgets(
      'Given an active card with onEdit, When rendering, Then hides the edit button',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_card(state: MeetingTaskCardState.active, onEdit: () {})),
        );

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.text('Marcar'), findsOneWidget);
      },
    );

    testWidgets(
      'Given a locked card with onEdit, When rendering, Then hides the edit button',
      (tester) async {
        await tester.pumpWidget(
          _wrap(_card(state: MeetingTaskCardState.locked, onEdit: () {})),
        );

        expect(find.byIcon(Icons.edit_outlined), findsNothing);
      },
    );

    testWidgets(
      'Given a done card with onEdit, When tapping the edit button, Then calls onEdit',
      (tester) async {
        var editCount = 0;

        await tester.pumpWidget(
          _wrap(
            _card(state: MeetingTaskCardState.done, onEdit: () => editCount++),
          ),
        );

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pump();

        expect(editCount, 1);
      },
    );
  });
}
