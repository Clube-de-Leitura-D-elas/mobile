import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/group_next_event.dart';
import 'package:mobile/l10n/app_localizations.dart';

final _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
);

class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();

  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _FailingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(StateError('cover failed to load')),
  );
}

class _LoadingCompleter extends ImageStreamCompleter {
  @override
  void addListener(ImageStreamListener listener) {
    super.addListener(listener);
    reportImageChunkEvent(
      const ImageChunkEvent(cumulativeBytesLoaded: 10, expectedTotalBytes: 100),
    );
  }
}

class _LoadingImage extends ImageProvider<_LoadingImage> {
  const _LoadingImage();

  @override
  Future<_LoadingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _LoadingImage key,
    ImageDecoderCallback decode,
  ) => _LoadingCompleter();
}

void main() {
  Widget buildSubject(Widget child) => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );

  testWidgets('renders event details in two columns', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        GroupNextEvent(
          status: GroupNextEventStatus.loaded,
          data: GroupNextEventData(
            location: 'Porto Alegre, RS',
            date: DateTime(2026, 8, 29),
            hostName: 'Roberta',
          ),
        ),
      ),
    );

    expect(find.text('Porto Alegre, RS'), findsOneWidget);
    expect(find.text('29/08/2026'), findsOneWidget);
    expect(find.text('Anfitriã: Roberta'), findsOneWidget);
    expect(
      tester.widgetList<AppIcon>(find.byType(AppIcon)).map((icon) => icon.icon),
      [AppIcons.location, AppIcons.calendar, AppIcons.user, AppIcons.book],
    );

    final location = tester.getRect(find.text('Porto Alegre, RS'));
    final date = tester.getRect(find.text('29/08/2026'));
    expect(date.left, greaterThan(location.right));
  });

  testWidgets('renders the empty state with localized text', (tester) async {
    await tester.pumpWidget(
      buildSubject(const GroupNextEvent(status: GroupNextEventStatus.empty)),
    );

    expect(find.text('Nenhum próximo evento agendado'), findsOneWidget);
  });

  testWidgets('renders the generic localized error state', (tester) async {
    await tester.pumpWidget(
      buildSubject(const GroupNextEvent(status: GroupNextEventStatus.error)),
    );

    expect(
      find.text(
        'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders loading state without throwing', (tester) async {
    await tester.pumpWidget(
      buildSubject(const GroupNextEvent(status: GroupNextEventStatus.loading)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow on a narrow layout', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        GroupNextEvent(
          status: GroupNextEventStatus.loaded,
          data: GroupNextEventData(
            location: 'Uma localização muito extensa para a largura disponível',
            date: DateTime(2026, 8, 29),
            hostName: 'Roberta',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final location = tester.widget<Text>(
      find.text('Uma localização muito extensa para a largura disponível'),
    );
    expect(location.overflow, isNot(TextOverflow.ellipsis));
    expect(
      tester
          .getSize(
            find.text(
              'Uma localização muito extensa para a largura disponível',
            ),
          )
          .height,
      greaterThan(AppTypographyTokens.standard.bodySmall.fontSize! * 2),
    );
  });

  test('loaded state requires data', () {
    expect(
      () => GroupNextEvent(status: GroupNextEventStatus.loaded),
      throwsAssertionError,
    );
  });

  testWidgets(
    'renders history link with bodyDefaultEmphasis when callback is provided',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(
          GroupNextEvent(
            status: GroupNextEventStatus.loaded,
            data: GroupNextEventData(
              location: 'Porto Alegre, RS',
              date: DateTime(2026, 8, 29),
              hostName: 'Roberta',
            ),
            onEventHistoryPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Exibir detalhes dos últimos eventos'), findsOneWidget);

      final linkText = tester.widget<Text>(
        find.text('Exibir detalhes dos últimos eventos'),
      );
      expect(
        linkText.style?.fontSize,
        AppTypographyTokens.standard.bodyDefaultEmphasis.fontSize,
      );

      await tester.tap(find.text('Exibir detalhes dos últimos eventos'));
      expect(tapped, isTrue);
    },
  );

  testWidgets('does not render history link when no callback is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        GroupNextEvent(
          status: GroupNextEventStatus.loaded,
          data: GroupNextEventData(
            location: 'Porto Alegre, RS',
            date: DateTime(2026, 8, 29),
            hostName: 'Roberta',
          ),
        ),
      ),
    );

    expect(find.text('Exibir detalhes dos últimos eventos'), findsNothing);
  });

  group('current book', () {
    const placeholderKey = ValueKey('group-next-event-book-placeholder');
    const loadingKey = ValueKey('group-next-event-book-loading');

    GroupNextEvent buildEvent({String? bookTitle, ImageProvider? bookCover}) {
      return GroupNextEvent(
        status: GroupNextEventStatus.loaded,
        data: GroupNextEventData(
          location: 'Porto Alegre, RS',
          date: DateTime(2026, 8, 29),
          hostName: 'Roberta',
          bookTitle: bookTitle,
          bookCover: bookCover,
        ),
        onEventHistoryPressed: () {},
      );
    }

    testWidgets(
      'Given a next event with a book cover, '
      'When rendering, '
      'Then shows the label, the cover sized 180x240 and the history link below',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            buildEvent(
              bookTitle: 'Ponciá Vicêncio',
              bookCover: MemoryImage(_transparentPng),
            ),
          ),
        );

        expect(find.text('O livro da vez é:'), findsOneWidget);
        final cover = find.bySemanticsLabel('Capa do livro Ponciá Vicêncio');
        expect(cover, findsOneWidget);
        expect(tester.getSize(find.byType(Image)), const Size(180, 240));
        expect(find.byKey(placeholderKey), findsNothing);

        final label = tester.getRect(find.text('O livro da vez é:'));
        final image = tester.getRect(find.byType(Image));
        final link = tester.getRect(
          find.text('Exibir detalhes dos últimos eventos'),
        );
        expect(image.top, greaterThan(label.bottom));
        expect(link.top, greaterThan(image.bottom));
      },
    );

    testWidgets('Given a next event without a book, '
        'When rendering, '
        'Then shows the undefined-book placeholder with the cover size', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(buildEvent()));

      expect(find.text('O livro da vez é:'), findsOneWidget);
      expect(find.text('Livro ainda não definido'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.getSize(find.byKey(placeholderKey)), const Size(180, 240));
      expect(
        tester
            .widgetList<AppIcon>(find.byType(AppIcon))
            .map((icon) => icon.icon),
        contains(AppIcons.book),
      );
    });

    testWidgets('Given a book without cover, '
        'When rendering, '
        'Then shows the unavailable-cover placeholder', (tester) async {
      await tester.pumpWidget(
        buildSubject(buildEvent(bookTitle: "Olhos d'água")),
      );

      expect(find.text("Olhos d'água"), findsOneWidget);
      expect(find.text('Livro ainda não definido'), findsNothing);
      expect(tester.getSize(find.byKey(placeholderKey)), const Size(180, 240));
    });

    testWidgets(
      'Given a cover that fails to load, '
      'When the image errors, '
      'Then the unavailable-cover placeholder replaces it without breaking layout',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            buildEvent(
              bookTitle: 'Ponciá Vicêncio',
              bookCover: const _FailingImage(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Ponciá Vicêncio'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(placeholderKey)),
          const Size(180, 240),
        );
        expect(
          find.text('Exibir detalhes dos últimos eventos'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Given a cover still loading, '
        'When rendering, '
        'Then shows the loading frame with the cover size', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          buildEvent(
            bookTitle: 'Ponciá Vicêncio',
            bookCover: const _LoadingImage(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.getSize(find.byKey(loadingKey)), const Size(180, 240));
      expect(find.byKey(placeholderKey), findsNothing);
    });
  });
}
