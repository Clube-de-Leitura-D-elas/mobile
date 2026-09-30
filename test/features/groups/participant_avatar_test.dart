import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('given no photo, then shows the placeholder only', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ParticipantAvatar(photoUrl: null)));

    expect(find.byType(ParticipantAvatarPlaceholder), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(
      tester.getSize(find.byType(ParticipantAvatar)),
      const Size.square(ParticipantAvatar.size),
    );
  });

  testWidgets('given a photo, then loads it with placeholder fallbacks', (
    tester,
  ) async {
    const url = 'https://example.com/ana.jpg';

    await tester.pumpWidget(_wrap(const ParticipantAvatar(photoUrl: url)));

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    final context = tester.element(find.byType(CachedNetworkImage));

    expect(image.imageUrl, url);
    expect(image.fit, BoxFit.cover);
    expect(
      image.placeholder!(context, url),
      isA<ParticipantAvatarPlaceholder>(),
    );
    expect(
      image.errorWidget!(context, url, Exception('falha simulada')),
      isA<ParticipantAvatarPlaceholder>(),
    );
  });
}
