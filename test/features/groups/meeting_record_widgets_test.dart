import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_thumbnail.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_viewer.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_section.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_promo_text_editor.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockMeetingPhotosCubit extends MockCubit<MeetingPhotosState>
    implements MeetingPhotosCubit {}

const _photo = MeetingPhotoEntity(id: 'p1', url: 'https://a/p1.jpg');
const _loaded = MeetingPhotosState(status: MeetingPhotosStatus.loaded);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('pt', 'BR'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: child,
);

void main() {
  group('MeetingPhotoViewer download', () {
    testWidgets(
      'given a caption, when viewing the photo, then shows it below',
      (tester) async {
        await tester.pumpWidget(
          _app(
            const MeetingPhotoViewer(
              photo: MeetingPhotoEntity(
                id: 'p1',
                url: 'https://a/p1.jpg',
                caption: 'Legenda completa da foto',
              ),
              index: 0,
              total: 1,
            ),
          ),
        );

        final caption = find.text('Legenda completa da foto');
        expect(caption, findsOneWidget);
        expect(tester.getTopLeft(caption).dy, greaterThan(0));
      },
    );

    Future<void> pumpViewer(
      WidgetTester tester,
      MeetingPhotoLauncher onDownload,
    ) async {
      await tester.pumpWidget(
        _app(
          MeetingPhotoViewer(
            photo: _photo,
            index: 0,
            total: 1,
            onDownload: onDownload,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('meeting-photo-download')));
      await tester.pump();
    }

    testWidgets(
      'given the photo opens, when downloading, then launches its url without an error',
      (tester) async {
        Uri? launched;
        await pumpViewer(tester, (uri) async {
          launched = uri;
          return true;
        });

        expect(launched, Uri.parse(_photo.url));
        expect(
          find.text('Não foi possível abrir a foto para baixar.'),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('meeting-photo-delete')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'given the photo cannot be opened, when downloading, then shows an error',
      (tester) async {
        await pumpViewer(tester, (_) async => false);

        expect(
          find.text('Não foi possível abrir a foto para baixar.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given the launcher throws, when downloading, then shows an error',
      (tester) async {
        await pumpViewer(tester, (_) async => throw Exception('no browser'));

        expect(
          find.text('Não foi possível abrir a foto para baixar.'),
          findsOneWidget,
        );
      },
    );
  });

  group('MeetingPromoTextEditor', () {
    testWidgets(
      'given the save fails, when saving, then keeps the editor open to try again',
      (tester) async {
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: MeetingPromoTextEditor(
                initialText: 'Texto antigo',
                onSave: (_) async => false,
              ),
            ),
          ),
        );

        expect(find.text('Texto antigo'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('meeting-promo-text-save')));
        await tester.pumpAndSettle();

        final save = tester.widget<AppButton>(
          find.byKey(const ValueKey('meeting-promo-text-save')),
        );
        expect(save.onPressed, isNotNull);
        expect(save.isLoading, isFalse);
      },
    );
  });

  group('MeetingPhotosSection record', () {
    late MockMeetingPhotosCubit cubit;

    setUp(() => cubit = MockMeetingPhotosCubit());

    Future<void> pumpSection(
      WidgetTester tester,
      MeetingPhotosState state, {
      Stream<MeetingPhotosState>? stream,
    }) async {
      whenListen(
        cubit,
        stream ?? const Stream<MeetingPhotosState>.empty(),
        initialState: state,
      );
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SingleChildScrollView(
              child: BlocProvider<MeetingPhotosCubit>.value(
                value: cubit,
                child: const MeetingPhotosSection(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'given a promo text, when copying, then puts it on the clipboard and confirms',
      (tester) async {
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String?;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await pumpSection(tester, _loaded.copyWith(promoText: 'Venham!'));

        await tester.tap(find.byKey(const ValueKey('meeting-promo-text-copy')));
        await tester.pump();

        expect(copied, 'Venham!');
        expect(find.text('Texto copiado.'), findsOneWidget);
      },
    );

    testWidgets(
      'given a promo text and a member who can edit, when editing, then opens the editor with the current text',
      (tester) async {
        when(() => cubit.savePromoText(any())).thenAnswer((_) async => true);
        await pumpSection(tester, _loaded.copyWith(promoText: 'Venham!'));

        expect(find.text('Editar'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('meeting-promo-text-edit')));
        await tester.pumpAndSettle();

        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey('meeting-promo-text-field')),
            matching: find.byType(TextField),
          ),
        );
        expect(field.controller?.text, 'Venham!');
      },
    );

    for (final (notice, message) in [
      (const MeetingPhotoDeletedNotice(), 'Foto removida.'),
      (
        const MeetingPhotoDeleteFailedNotice(),
        'Não foi possível remover a foto. Tente novamente.',
      ),
      (const MeetingPromoTextSavedNotice(), 'Texto de divulgação salvo.'),
      (
        const MeetingPromoTextSaveFailedNotice(),
        'Não foi possível salvar o texto de divulgação. Tente novamente.',
      ),
    ]) {
      testWidgets(
        'given a ${notice.runtimeType}, when emitted, then shows it',
        (tester) async {
          await pumpSection(
            tester,
            _loaded,
            stream: Stream.value(_loaded.copyWith(notice: notice)),
          );
          await tester.pump();

          expect(find.text(message), findsOneWidget);
        },
      );
    }
  });

  group('MeetingPhotoThumbnail without viewer', () {
    testWidgets(
      'given no open action and a failed image, when tapping, then reloads',
      (tester) async {
        var reloads = 0;
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SizedBox.square(
                dimension: 120,
                child: MeetingPhotoThumbnail(
                  photo: _photo,
                  index: 0,
                  onReload: () => reloads++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics &&
                w.properties.label == 'Foto 1 do encontro' &&
                w.properties.button != true,
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('meeting-photo-error')));
        expect(reloads, 1);
      },
    );
  });
}
