import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_screen.dart';

void main() {
  group('MeetingDetailsScreen', () {
    const mockMeeting = MeetingDetailsEntity(
      id: 'meeting-1',
      bookTitle: 'O Senhor dos Anéis',
      hostName: 'Maria Silva',
      number: 10,
      coverPhotoUrl: null,
    );

    Widget createWidgetUnderTest() {
      return MaterialApp(
        theme: AppTheme.light,
        home: const MeetingDetailsScreen(meeting: mockMeeting),
      );
    }

    testWidgets('exibe o botão para ver a lista de participantes', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Ver lista de participantes'), findsOneWidget);
    });

    testWidgets('exibe o componente da tela de detalhes da reunião', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(MeetingDetailsScreen), findsOneWidget);
    });
  });
}
