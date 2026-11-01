import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

void main() {
  Widget createWidget(String? photoUrl) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: AppParticipantAvatar(photoUrl: photoUrl)),
      ),
    );
  }

  group('AppParticipantAvatar', () {
    testWidgets('usa o tamanho padrão de 56 pixels', (tester) async {
      await tester.pumpWidget(createWidget(null));

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(AppParticipantAvatar),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == AppParticipantAvatar.size &&
                widget.height == AppParticipantAvatar.size,
          ),
        ),
      );

      expect(sizedBox.width, 56);
      expect(sizedBox.height, 56);
    });

    testWidgets('aceita um diâmetro maior e acompanha o ícone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Center(
              child: AppParticipantAvatar(photoUrl: null, diameter: 112),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(AppParticipantAvatar)),
        const Size(112, 112),
      );
      expect(tester.widget<Icon>(find.byType(Icon)).size, 48);
    });

    testWidgets('exibe ícone padrão quando a URL é null', (tester) async {
      await tester.pumpWidget(createWidget(null));

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('exibe ícone padrão quando a URL está vazia', (tester) async {
      await tester.pumpWidget(createWidget(''));

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('utiliza CachedNetworkImage quando há uma URL', (tester) async {
      await tester.pumpWidget(createWidget('https://example.com/avatar.jpg'));

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      expect(image.imageUrl, 'https://example.com/avatar.jpg');
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('mantém o avatar recortado em formato circular', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(null));

      expect(find.byType(ClipOval), findsOneWidget);
    });
  });
}
