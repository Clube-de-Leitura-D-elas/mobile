import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  // "Hoje" fixo para os testes não dependerem do relógio real.
  final today = DateTime(2026, 11, 15);

  Future<void> pumpHeader(WidgetTester tester, {DateTime? joinedAt}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: ProfileHeader(
            name: 'Roberta',
            joinedAt: joinedAt,
            now: () => today,
          ),
        ),
      ),
    );
  }

  group('ProfileHeader.monthsBetween', () {
    test('conta apenas meses completos', () {
      expect(
        ProfileHeader.monthsBetween(
          DateTime(2026, 1, 15),
          DateTime(2026, 3, 14),
        ),
        1,
      );
      expect(
        ProfileHeader.monthsBetween(
          DateTime(2026, 1, 15),
          DateTime(2026, 3, 15),
        ),
        2,
      );
    });

    test('o último dia de um mês mais curto fecha o mês', () {
      expect(
        ProfileHeader.monthsBetween(
          DateTime(2026, 1, 31),
          DateTime(2026, 2, 28),
        ),
        1,
      );
      expect(
        ProfileHeader.monthsBetween(
          DateTime(2026, 1, 31),
          DateTime(2026, 2, 27),
        ),
        0,
      );
    });

    test('atravessa a virada do ano', () {
      expect(
        ProfileHeader.monthsBetween(
          DateTime(2025, 11, 1),
          DateTime(2026, 2, 1),
        ),
        3,
      );
    });

    test('nunca fica negativo', () {
      expect(
        ProfileHeader.monthsBetween(DateTime(2026, 5, 1), DateTime(2026, 4, 1)),
        0,
      );
    });
  });

  group('ProfileHeader', () {
    testWidgets('mostra o nome e o avatar grande', (tester) async {
      await pumpHeader(tester);

      expect(find.text('Roberta'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppParticipantAvatar)),
        const Size.square(ProfileHeader.avatarDiameter),
      );
    });

    testWidgets('sem data de entrada não mostra o tempo no clube', (
      tester,
    ) async {
      await pumpHeader(tester);

      expect(find.textContaining('no clube'), findsNothing);
    });

    testWidgets('mostra quem chegou este mês', (tester) async {
      await pumpHeader(tester, joinedAt: DateTime(2026, 10, 16));

      expect(find.text('Chegou ao clube este mês'), findsOneWidget);
    });

    testWidgets('mostra os meses abaixo de um ano', (tester) async {
      await pumpHeader(tester, joinedAt: DateTime(2026, 10, 15));
      expect(find.text('1 mês no clube'), findsOneWidget);

      await pumpHeader(tester, joinedAt: DateTime(2025, 12, 15));
      expect(find.text('11 meses no clube'), findsOneWidget);
    });

    testWidgets('mostra os anos a partir de um ano', (tester) async {
      await pumpHeader(tester, joinedAt: DateTime(2025, 11, 15));
      expect(find.text('1 ano no clube'), findsOneWidget);

      // 23 meses ainda é 1 ano: os anos são arredondados para baixo.
      await pumpHeader(tester, joinedAt: DateTime(2024, 12, 15));
      expect(find.text('1 ano no clube'), findsOneWidget);

      await pumpHeader(tester, joinedAt: DateTime(2024, 11, 15));
      expect(find.text('2 anos no clube'), findsOneWidget);
    });

    // Em UTC a data local e a UTC são iguais e não há o que testar, então o
    // caso é pulado; o CI roda com TZ=America/Sao_Paulo para executá-lo.
    final offset = DateTime(2026, 10, 15).timeZoneOffset;

    testWidgets(
      'conta a data de entrada no fuso do aparelho',
      skip: offset == Duration.zero,
      (tester) async {
        // Entrada local perto da meia-noite, que em UTC cai em outro dia.
        // Fuso negativo: 15/10 23h local é 16/10 em UTC (0 meses em 15/11).
        // Fuso positivo: 16/10 00h30 local é 15/10 em UTC (1 mês em 15/11).
        final joinedLocal = offset.isNegative
            ? DateTime(2026, 10, 15, 23)
            : DateTime(2026, 10, 16, 0, 30);
        final joinedAt = joinedLocal.toUtc();
        expect(joinedAt.day, isNot(joinedLocal.day));

        await pumpHeader(tester, joinedAt: joinedAt);

        expect(
          find.text(
            offset.isNegative ? '1 mês no clube' : 'Chegou ao clube este mês',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('o avatar fica fora da leitura de tela', (tester) async {
      await pumpHeader(tester);

      expect(
        find.ancestor(
          of: find.byType(AppParticipantAvatar),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });
  });
}
