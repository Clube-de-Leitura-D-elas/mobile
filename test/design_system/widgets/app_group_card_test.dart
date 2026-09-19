import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

void main() {
  group('AppGroupCard', () {
    testWidgets('Renders group name, participants count and city/state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppGroupCard(
              groupName: 'Grupo 27',
              participantsCount: 18,
              cityState: 'Porto Alegre, RS',
            ),
          ),
        ),
      );

      expect(find.text('Grupo 27'), findsOneWidget);
      expect(find.text('18 participantes'), findsOneWidget);
      expect(find.text('Porto Alegre, RS'), findsOneWidget);
    });

    testWidgets(
      'Does not render the meeting section when there is no next meeting',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: AppGroupCard(
                groupName: 'Grupo 27',
                participantsCount: 18,
                cityState: 'Porto Alegre, RS',
              ),
            ),
          ),
        );

        expect(find.text('Próximo encontro'), findsNothing);
        expect(find.text('Não irei'), findsNothing);
        expect(find.text('Confirmar presença'), findsNothing);
      },
    );

    testWidgets(
      'Renders the meeting section and both buttons when there is a next meeting',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: AppGroupCard(
                groupName: 'Grupo 1',
                participantsCount: 32,
                cityState: 'Porto Alegre, RS',
                nextMeeting: GroupMeeting(
                  hostName: 'Roberta',
                  bookTitle: 'Pequeno príncipe',
                  date: '29/08/2026',
                  location: 'Z Café TECNOPUC',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Próximo encontro'), findsOneWidget);
        expect(find.text('Roberta'), findsOneWidget);
        expect(find.text('Pequeno príncipe'), findsOneWidget);
        expect(find.text('29/08/2026'), findsOneWidget);
        expect(find.text('Z Café TECNOPUC'), findsOneWidget);
        expect(find.text('Não irei'), findsOneWidget);
        expect(find.text('Confirmar presença'), findsOneWidget);
      },
    );

    testWidgets('Triggers onTap when the card is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppGroupCard(
              groupName: 'Grupo 27',
              participantsCount: 18,
              cityState: 'Porto Alegre, RS',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('Is not tappable when onTap is not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppGroupCard(
              groupName: 'Grupo 27',
              participantsCount: 18,
              cityState: 'Porto Alegre, RS',
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('Shows a placeholder icon when there is no photo URL', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppGroupCard(
              groupName: 'Grupo 27',
              participantsCount: 18,
              cityState: 'Porto Alegre, RS',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
    });

    testWidgets(
      'Calls onConfirmPresence and onDeclinePresence when the buttons are tapped',
      (tester) async {
        var confirmed = false;
        var declined = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: AppGroupCard(
                groupName: 'Grupo 1',
                participantsCount: 32,
                cityState: 'Porto Alegre, RS',
                nextMeeting: const GroupMeeting(
                  hostName: 'Roberta',
                  bookTitle: 'Pequeno príncipe',
                  date: '29/08/2026',
                  location: 'Z Café TECNOPUC',
                ),
                onConfirmPresence: () => confirmed = true,
                onDeclinePresence: () => declined = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Não irei'));
        await tester.pump();
        expect(declined, isTrue);

        await tester.tap(find.text('Confirmar presença'));
        await tester.pump();
        expect(confirmed, isTrue);
      },
    );

    testWidgets(
      'Shows only the header and a down chevron when collapsed (expanded: false)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: AppGroupCard(
                groupName: 'Grupo 27',
                participantsCount: 18,
                cityState: 'Porto Alegre, RS',
                expanded: false,
                nextMeeting: GroupMeeting(
                  hostName: 'Roberta',
                  bookTitle: 'Pequeno príncipe',
                  date: '29/08/2026',
                  location: 'Z Café TECNOPUC',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Próximo encontro'), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

        // Detalhes e botões não aparecem enquanto colapsado.
        expect(find.text('Roberta'), findsNothing);
        expect(find.text('Pequeno príncipe'), findsNothing);
        expect(find.text('Não irei'), findsNothing);
        expect(find.text('Confirmar presença'), findsNothing);
      },
    );

    testWidgets(
      'Shows an up chevron next to the header when expanded (default)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: AppGroupCard(
                groupName: 'Grupo 1',
                participantsCount: 32,
                cityState: 'Porto Alegre, RS',
                nextMeeting: GroupMeeting(
                  hostName: 'Roberta',
                  bookTitle: 'Pequeno príncipe',
                  date: '29/08/2026',
                  location: 'Z Café TECNOPUC',
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      },
    );
  });
}
