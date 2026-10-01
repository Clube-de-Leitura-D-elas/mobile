import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const testMeeting = GroupMeeting(
    hostName: 'Roberta',
    bookTitle: 'Pequeno príncipe',
    date: '29/08/2026',
    location: 'Z Café TECNOPUC',
  );

  const group1 = GroupEntity(
    id: '1',
    name: 'Grupo 1',
    participantsCount: 32,
    cityState: 'Porto Alegre, RS',
    nextMeeting: testMeeting,
    hasPendingResponse: true,
  );

  const group27 = GroupEntity(
    id: '27',
    name: 'Grupo 27',
    participantsCount: 18,
    cityState: 'Porto Alegre, RS',
    nextMeeting: testMeeting,
    hasPendingResponse: true,
  );

  Widget buildSubject({
    required HomeCubit homeCubit,
    Size size = const Size(390, 844),
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: BlocProvider<HomeCubit>.value(
          value: homeCubit,
          child: const HomeScreen(),
        ),
      ),
    );
  }

  group('HomeScreen Widget', () {
    late HomeCubit homeCubit;

    setUp(() {
      homeCubit = HomeCubit();
    });

    tearDown(() {
      homeCubit.close();
    });

    testWidgets(
      'Given loaded groups, When HomeScreen renders, Then displays title, search field with placeholder, and filter chips',
      (tester) async {
        homeCubit.loadGroups(initialGroups: [group1, group27]);

        await tester.pumpWidget(buildSubject(homeCubit: homeCubit));
        await tester.pumpAndSettle();

        expect(find.text('Meus grupos'), findsOneWidget);
        expect(find.text('Buscar grupo'), findsOneWidget);
        expect(find.text('Todos'), findsOneWidget);
        expect(find.text('Não respondidos (2)'), findsOneWidget);
        expect(find.text('Respondidos'), findsOneWidget);
        expect(find.byType(BottomNavigationBarWidget), findsOneWidget);
      },
    );

    testWidgets(
      'Given loaded groups, When HomeScreen renders, Then displays cards with group name, participants count, and city/state',
      (tester) async {
        homeCubit.loadGroups(initialGroups: [group1, group27]);

        await tester.pumpWidget(buildSubject(homeCubit: homeCubit));
        await tester.pumpAndSettle();

        expect(find.text('Grupo 1'), findsOneWidget);
        expect(find.text('32 participantes'), findsOneWidget);
        expect(find.text('Grupo 27'), findsOneWidget);
        expect(find.text('18 participantes'), findsOneWidget);
      },
    );

    testWidgets(
      'Given loaded groups with cards, When next meeting row is tapped, Then cards expand and collapse independently',
      (tester) async {
        homeCubit.loadGroups(initialGroups: [group1, group27]);

        await tester.pumpWidget(buildSubject(homeCubit: homeCubit));
        await tester.pumpAndSettle();

        // Initially in mock data: group 1 is expanded, group 27 is collapsed.
        expect(find.text('Roberta'), findsOneWidget);
        expect(find.text('Não irei'), findsOneWidget);
        expect(find.text('Confirmar presença'), findsOneWidget);

        // Tap on group 1 "Próximo evento" to collapse it.
        await tester.tap(find.text('Próximo evento').first);
        await tester.pumpAndSettle();

        // Now both group 1 and group 27 are collapsed.
        expect(find.text('Roberta'), findsNothing);
        expect(find.text('Não irei'), findsNothing);

        // Tap on group 27 "Próximo evento" to expand it.
        await tester.tap(find.text('Próximo evento').last);
        await tester.pumpAndSettle();

        // Group 27 is expanded, group 1 remains collapsed.
        expect(find.text('Roberta'), findsOneWidget);
        expect(find.text('Não irei'), findsOneWidget);
        expect(find.text('Confirmar presença'), findsOneWidget);
      },
    );

    testWidgets(
      'Given card with next meeting, When expanded, Then shows meeting details and action buttons',
      (tester) async {
        homeCubit.loadGroups(initialGroups: [group1]);

        await tester.pumpWidget(buildSubject(homeCubit: homeCubit));
        await tester.pumpAndSettle();

        expect(find.text('Próximo evento'), findsOneWidget);
        expect(find.text('Roberta'), findsOneWidget);
        expect(find.text('Pequeno príncipe'), findsOneWidget);
        expect(find.text('29/08/2026'), findsOneWidget);
        expect(find.text('Z Café TECNOPUC'), findsOneWidget);
        expect(find.text('Não irei'), findsOneWidget);
        expect(find.text('Confirmar presença'), findsOneWidget);
      },
    );

    testWidgets(
      'Given empty groups list, When HomeScreen renders, Then displays empty state message',
      (tester) async {
        homeCubit.loadGroups(initialGroups: []);

        await tester.pumpWidget(buildSubject(homeCubit: homeCubit));
        await tester.pumpAndSettle();

        expect(
          find.text('Você ainda não participa de nenhum grupo'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Assim que você entrar em um grupo de leitura, ele aparecerá aqui.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Given small screen and long group name, When HomeScreen renders, Then displays without layout overflow',
      (tester) async {
        const longNameGroup = GroupEntity(
          id: '99',
          name:
              'Clube do Livro com Nome Extremamente Longo para Testar Quebra de Linha em Telas Pequenas',
          participantsCount: 99,
          cityState: 'São Paulo - SP, Brasil / Região Metropolitana',
          nextMeeting: testMeeting,
        );

        homeCubit.loadGroups(initialGroups: [longNameGroup]);

        // Small screen size (e.g. 320x568 iPhone SE 1st gen)
        await tester.pumpWidget(
          buildSubject(homeCubit: homeCubit, size: const Size(320, 568)),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text(
            'Clube do Livro com Nome Extremamente Longo para Testar Quebra de Linha em Telas Pequenas',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
