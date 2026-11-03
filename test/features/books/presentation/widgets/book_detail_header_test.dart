import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/book_detail_header.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';

const _title = 'Harry Potter e a Pedra Filosofal';
const _coverUrl = 'https://example.com/capa.jpg';
const _colors = AppColorTokens.light;

Future<void> _pumpHeader(
  WidgetTester tester,
  BookDetailHeader header, {
  double topInset = 0,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: EdgeInsets.only(top: topInset),
            textScaler: textScaler,
          ),
          child: Scaffold(
            body: Align(alignment: Alignment.topCenter, child: header),
          ),
        ),
      ),
    ),
  );
}

BookDetailHeader _header({
  String title = _title,
  String author = 'J. K. Rowling',
  String? coverUrl = _coverUrl,
  double? rating = 4.5,
  ReadingStatusChipState status = ReadingStatusChipState.markAsRead,
  VoidCallback? onBackPressed,
  VoidCallback? onStatusTap,
  bool isStatusLoading = false,
}) {
  return BookDetailHeader(
    title: title,
    author: author,
    coverUrl: coverUrl,
    rating: rating,
    status: status,
    onBackPressed: onBackPressed,
    onStatusTap: onStatusTap,
    isStatusLoading: isStatusLoading,
  );
}

Finder get _backButton => find.byTooltip('Voltar');

Finder get _scrim => find.byWidgetPredicate(
  (w) =>
      w is ColoredBox && w.color == _colors.overlayScrim.withValues(alpha: 0.7),
);

bool _isFallback(Widget widget) =>
    widget is ColoredBox && widget.color == _colors.actionPrimary;

Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required String initialLocation,
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: HomeRoutes.home,
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () => context.push('/livro'),
            child: const Text('home'),
          ),
        ),
      ),
      GoRoute(
        path: '/livro',
        builder: (context, state) => Scaffold(body: _header()),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('BookDetailHeader', () {
    testWidgets('shows the cover, title, author, rating and status chip', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());

      final cover = tester.widget<AppBookCover>(find.byType(AppBookCover));
      expect(cover.imageUrl, _coverUrl);
      expect(cover.size, AppBookCoverSize.header);
      expect(find.text(_title), findsOneWidget);
      expect(find.text('Escrito por J. K. Rowling'), findsOneWidget);

      final stars = tester.widget<AppStarRating>(find.byType(AppStarRating));
      expect(stars.rating, 4.5);
      expect(stars.size, AppStarRatingSize.md);
      expect(find.text('Marcar como lido'), findsOneWidget);
    });

    testWidgets('draws the title and author in white with line limits', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());

      final title = tester.widget<Text>(find.text(_title));
      final author = tester.widget<Text>(
        find.text('Escrito por J. K. Rowling'),
      );

      expect(title.style?.color, _colors.textOnBrand);
      expect(title.maxLines, 3);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(author.style?.color, _colors.textOnBrand);
      expect(author.maxLines, 2);
      expect(author.overflow, TextOverflow.ellipsis);
    });

    testWidgets('exposes the title as a header and the rating label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await _pumpHeader(tester, _header());

      expect(
        tester.getSemantics(find.text(_title)),
        isSemantics(label: _title, isHeader: true),
      );
      expect(find.bySemanticsLabel('4,5 de 5 estrelas'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('hides the author line when the author is empty', (
      tester,
    ) async {
      await _pumpHeader(tester, _header(author: ''));

      expect(find.textContaining('Escrito por'), findsNothing);
    });

    testWidgets('shows empty stars with a label when nobody rated the book', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await _pumpHeader(tester, _header(rating: null));

      expect(
        tester.widget<AppStarRating>(find.byType(AppStarRating)).rating,
        0,
      );
      expect(find.bySemanticsLabel('Ainda sem avaliações'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('passes the status, tap and loading to the chip', (
      tester,
    ) async {
      var taps = 0;

      await _pumpHeader(
        tester,
        _header(status: ReadingStatusChipState.read, onStatusTap: () => taps++),
      );
      await tester.tap(find.text('Já lido'));

      expect(taps, 1);

      await _pumpHeader(tester, _header(isStatusLoading: true));

      expect(
        tester
            .widget<AppReadingStatusChip>(find.byType(AppReadingStatusChip))
            .isLoading,
        isTrue,
      );
    });

    testWidgets('back button has a 48x48 target, label and callback', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;

      await _pumpHeader(tester, _header(onBackPressed: () => taps++));

      expect(tester.getSize(_backButton), const Size(48, 48));
      expect(
        tester.getSemantics(_backButton),
        isSemantics(tooltip: 'Voltar', isButton: true, hasTapAction: true),
      );

      await tester.tap(_backButton);
      expect(taps, 1);

      semantics.dispose();
    });

    testWidgets('back button pops the route by default', (tester) async {
      final router = await _pumpRouter(
        tester,
        initialLocation: HomeRoutes.home,
      );
      await tester.tap(find.text('home'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailHeader), findsOneWidget);

      await tester.tap(_backButton);
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailHeader), findsNothing);
      expect(router.state.uri.path, HomeRoutes.home);
    });

    testWidgets('back button goes home when there is no previous route', (
      tester,
    ) async {
      final router = await _pumpRouter(tester, initialLocation: '/livro');

      await tester.tap(_backButton);
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailHeader), findsNothing);
      expect(router.state.uri.path, HomeRoutes.home);
    });

    testWidgets('blurs the cover inside a clip and behind a scrim', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());

      final filtered = find.byType(ImageFiltered);
      expect(
        tester.widget<ImageFiltered>(filtered).imageFilter,
        ImageFilter.blur(sigmaX: 12, sigmaY: 12, tileMode: TileMode.clamp),
      );
      expect(
        find.ancestor(of: filtered, matching: find.byType(ClipRect)),
        findsWidgets,
      );
      expect(_scrim, findsOneWidget);
    });

    testWidgets('shows the brand color while loading or when the cover fails', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());

      final background = find.descendant(
        of: find.byType(ImageFiltered),
        matching: find.byType(CachedNetworkImage),
      );
      final context = tester.element(background);
      final image = tester.widget<CachedNetworkImage>(background);

      expect(_isFallback(image.placeholder!(context, _coverUrl)), isTrue);
      expect(
        _isFallback(image.errorWidget!(context, _coverUrl, Exception())),
        isTrue,
      );
    });

    testWidgets('falls back to the brand color without a cover', (
      tester,
    ) async {
      await _pumpHeader(tester, _header(coverUrl: null));

      expect(find.byType(ImageFiltered), findsNothing);
      expect(find.byWidgetPredicate(_isFallback), findsOneWidget);
      expect(_scrim, findsOneWidget);
    });

    testWidgets('lays out the cover beside the text and over the background', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());

      final background = tester.getRect(_scrim);
      final title = tester.getRect(find.text(_title));
      final stars = tester.getRect(find.byType(AppStarRating));
      final cover = tester.getRect(find.byType(AppBookCover));
      final back = tester.getRect(_backButton);
      final header = tester.getRect(find.byType(BookDetailHeader));

      expect(back.left, 8);
      expect(cover.left, 16);
      expect(title.left, greaterThanOrEqualTo(cover.right));
      expect(stars.left, greaterThanOrEqualTo(cover.right));
      expect(title.bottom, lessThanOrEqualTo(background.bottom));
      expect(stars.top, greaterThan(background.bottom));
      expect(cover.top, lessThan(background.bottom));
      expect(cover.bottom, greaterThan(background.bottom));
      expect(cover.bottom, lessThanOrEqualTo(header.bottom));
    });

    testWidgets('grows the background for a long title without overflow', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());
      final shortBackground = tester.getRect(_scrim);

      await _pumpHeader(
        tester,
        _header(title: 'Um título bem comprido para ocupar três linhas aqui'),
      );
      final longBackground = tester.getRect(_scrim);

      expect(tester.takeException(), isNull);
      expect(longBackground.height, greaterThan(shortBackground.height));
      expect(
        tester.getRect(find.byType(AppStarRating)).top,
        greaterThan(longBackground.bottom),
      );
    });

    testWidgets('fits a narrow screen with large text', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _pumpHeader(
        tester,
        _header(),
        textScaler: const TextScaler.linear(2),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('moves the back button and cover below the status bar', (
      tester,
    ) async {
      await _pumpHeader(tester, _header());
      final backTop = tester.getTopLeft(_backButton).dy;
      final coverTop = tester.getTopLeft(find.byType(AppBookCover)).dy;

      await _pumpHeader(tester, _header(), topInset: 24);

      expect(tester.getTopLeft(_backButton).dy, backTop + 24);
      expect(tester.getTopLeft(find.byType(AppBookCover)).dy, coverTop + 24);
    });
  });
}
