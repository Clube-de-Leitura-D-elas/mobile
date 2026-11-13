import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_groups_carousel.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  List<ProfileGroupEntity> groups(int count) => [
    for (var i = 1; i <= count; i++) ProfileGroupEntity(id: 'g-$i', number: i),
  ];

  Future<void> pumpCarousel(
    WidgetTester tester, {
    required List<ProfileGroupEntity> groups,
    ValueChanged<String>? onGroupTap,
    double width = 360,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: Center(
            // Largura de celular: cabem uns três avatares.
            child: SizedBox(
              width: width,
              child: ProfileGroupsCarousel(
                groups: groups,
                onGroupTap: onGroupTap ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder moreGroups() => find.bySemanticsLabel('Ver mais grupos');

  testWidgets('cada grupo é um botão com o número e abre o grupo', (
    tester,
  ) async {
    final opened = <String>[];
    await pumpCarousel(tester, groups: groups(2), onGroupTap: opened.add);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Grupo 2')),
      isSemantics(label: 'Grupo 2', isButton: true),
    );
    expect(
      tester.getSize(find.byType(AppGroupAvatar).first),
      const Size.square(ProfileGroupsCarousel.avatarDiameter),
    );

    await tester.tap(find.byKey(const ValueKey('profile-group-g-2')));
    expect(opened, ['g-2']);
  });

  testWidgets('sem mais grupos à direita, não mostra a seta', (tester) async {
    await pumpCarousel(tester, groups: groups(2));

    expect(moreGroups(), findsNothing);
  });

  testWidgets('com mais grupos, a seta rola até o fim e some', (tester) async {
    await pumpCarousel(tester, groups: groups(6));

    expect(moreGroups(), findsOneWidget);
    expect(
      tester.getSize(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(InkWell),
        ),
      ),
      greaterThanOrEqualTo(const Size.square(48)),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    while (moreGroups().evaluate().isNotEmpty) {
      final before = scrollable.position.pixels;
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, greaterThan(before));
    }

    expect(scrollable.position.extentAfter, 0);
    expect(find.byKey(const ValueKey('profile-group-g-6')), findsOneWidget);
  });

  testWidgets('a seta aparece quando a lista cresce e some se a tela alarga', (
    tester,
  ) async {
    await pumpCarousel(tester, groups: groups(2));
    expect(moreGroups(), findsNothing);

    // Lista nova com mais grupos, no mesmo carrossel.
    await pumpCarousel(tester, groups: groups(6));
    await tester.pump();
    expect(moreGroups(), findsOneWidget);

    // Tela mais larga (celular deitado): tudo cabe e a seta some.
    await pumpCarousel(tester, groups: groups(6), width: 760);
    await tester.pump();
    expect(moreGroups(), findsNothing);

    // De novo estreita (seta na tela), depois alarga só o bastante para os 6
    // grupos (656 px) caberem na largura toda, mas não na que sobra ao lado da
    // seta: ela tem de sair em vez de cortar o último grupo.
    await pumpCarousel(tester, groups: groups(6));
    await tester.pump();
    expect(moreGroups(), findsOneWidget);
    await pumpCarousel(tester, groups: groups(6), width: 680);
    await tester.pump();
    expect(moreGroups(), findsNothing);

    // E volta ao estreitar.
    await pumpCarousel(tester, groups: groups(6));
    await tester.pump();
    expect(moreGroups(), findsOneWidget);
  });
}
