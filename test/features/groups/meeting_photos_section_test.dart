import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_thumbnail.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_section.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockMeetingPhotosCubit extends MockCubit<MeetingPhotosState>
    implements MeetingPhotosCubit {}

const _loadedEmpty = MeetingPhotosState(status: MeetingPhotosStatus.loaded);

final _photos = List.generate(
  4,
  (index) => MeetingPhotoEntity(id: 'p$index', url: 'https://a/p$index.jpg'),
);

final _failed = [
  PickedPhoto(
    id: 'f1',
    bytes: Uint8List.fromList([1]),
    contentType: 'image/jpeg',
  ),
  PickedPhoto(
    id: 'f2',
    bytes: Uint8List.fromList([2]),
    contentType: 'image/jpeg',
  ),
];

void main() {
  late MockMeetingPhotosCubit cubit;

  setUp(() {
    cubit = MockMeetingPhotosCubit();
    when(() => cubit.pickAndUpload()).thenAnswer((_) async {});
    when(() => cubit.retryFailed()).thenAnswer((_) async {});
    when(() => cubit.reload()).thenAnswer((_) async {});
  });

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
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
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
    'given no photos, when rendered, then shows the empty state that opens the gallery',
    (tester) async {
      await pumpSection(tester, _loadedEmpty);

      expect(find.text('Fotos do encontro'), findsOneWidget);
      expect(find.text('Adicionar fotos'), findsOneWidget);
      expect(
        tester.widgetList<AppIcon>(find.byType(AppIcon)).map((i) => i.icon),
        contains(AppIcons.camera),
      );

      await tester.tap(
        find.byKey(const ValueKey('meeting-photos-empty-state')),
      );
      verify(() => cubit.pickAndUpload()).called(1);
    },
  );

  testWidgets('given photos are loading, when rendered, then shows a spinner', (
    tester,
  ) async {
    await pumpSection(tester, const MeetingPhotosState());

    expect(
      find.byKey(const ValueKey('meeting-photos-loading')),
      findsOneWidget,
    );
    expect(find.text('Adicionar fotos'), findsNothing);
  });

  testWidgets(
    'given photos, when rendered, then shows a 3-column grid with a trailing add tile',
    (tester) async {
      await pumpSection(tester, _loadedEmpty.copyWith(photos: _photos));
      await tester.pump();

      expect(find.byType(MeetingPhotoThumbnail), findsNWidgets(4));
      expect(find.byType(Image), findsNWidgets(4));
      expect(find.text('Adicionar fotos'), findsNothing);
      final grid = tester.widget<GridView>(
        find.byKey(const ValueKey('meeting-photos-grid')),
      );
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
      final first = tester.getSize(find.byType(MeetingPhotoThumbnail).first);
      expect(first.width, closeTo(first.height, 0.01));

      await tester.tap(find.byKey(const ValueKey('meeting-photos-add-tile')));
      verify(() => cubit.pickAndUpload()).called(1);
    },
  );

  testWidgets(
    'given the member cannot add photos and there are none, when rendered, then shows a message without the add action',
    (tester) async {
      await pumpSection(tester, _loadedEmpty.copyWith(canAddPhotos: false));

      expect(
        find.byKey(const ValueKey('meeting-photos-empty-state')),
        findsNothing,
      );
      expect(find.text('Adicionar fotos'), findsNothing);
      expect(find.text('Ainda não há fotos deste encontro.'), findsOneWidget);
    },
  );

  testWidgets(
    'given the member cannot add photos, when rendered with photos, then hides the add tile',
    (tester) async {
      await pumpSection(
        tester,
        _loadedEmpty.copyWith(photos: _photos, canAddPhotos: false),
      );
      await tester.pump();

      expect(find.byType(MeetingPhotoThumbnail), findsNWidgets(4));
      expect(
        find.byKey(const ValueKey('meeting-photos-add-tile')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'given the meeting is full, when rendered, then hides the add tile',
    (tester) async {
      await pumpSection(
        tester,
        _loadedEmpty.copyWith(
          photos: List.generate(
            MeetingPhotoLimits.perMeeting,
            (i) => MeetingPhotoEntity(id: 'p$i', url: 'https://a/$i.jpg'),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('meeting-photos-add-tile')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'given an upload in progress, when rendered, then shows "Enviando N de M" and disables adding',
    (tester) async {
      await pumpSection(
        tester,
        _loadedEmpty.copyWith(
          photos: _photos,
          progress: const MeetingPhotosUploadProgress(current: 2, total: 3),
        ),
      );

      expect(find.text('Enviando 2 de 3'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('meeting-photos-add-tile')));
      verifyNever(() => cubit.pickAndUpload());
    },
  );

  testWidgets(
    'given failed uploads, when tapping "Tentar novamente", then retries the failed ones',
    (tester) async {
      await pumpSection(tester, _loadedEmpty.copyWith(failedPhotos: _failed));

      expect(find.text('Não foi possível enviar 2 fotos.'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      verify(() => cubit.retryFailed()).called(1);
    },
  );

  testWidgets(
    'given loading the photos failed, when tapping "Tentar novamente", then reloads',
    (tester) async {
      await pumpSection(
        tester,
        const MeetingPhotosState(status: MeetingPhotosStatus.error),
      );

      expect(
        find.text('Não foi possível carregar as fotos do encontro.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Tentar novamente'));
      verify(() => cubit.reload()).called(1);
    },
  );

  testWidgets(
    'given photo access is denied, when the notice arrives, then shows a friendly toast',
    (tester) async {
      await pumpSection(
        tester,
        _loadedEmpty,
        stream: Stream.value(
          _loadedEmpty.copyWith(
            notice: const MeetingPhotosAccessDeniedNotice(),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          'Permita o acesso às fotos nos ajustes do aparelho para adicionar fotos.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'given a thumbnail fails to load, when tapping it, then opens the photo so it can still be removed',
    (tester) async {
      when(() => cubit.deletePhoto(any())).thenAnswer((_) async => true);
      await pumpSection(tester, _loadedEmpty.copyWith(photos: [_photos.first]));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('meeting-photo-error')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('meeting-photo-error')));
      await tester.pumpAndSettle();

      expect(find.text('Foto 1 de 1'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('meeting-photo-delete')),
        findsOneWidget,
      );
      verifyNever(() => cubit.reload());
    },
  );

  testWidgets(
    'renders loading state of MeetingPhotoPlaceholder with circular progress indicator',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: MeetingPhotoPlaceholder()),
        ),
      );

      expect(
        find.byKey(const ValueKey('meeting-photo-loading')),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  group('promo text', () {
    setUp(() {
      when(() => cubit.savePromoText(any())).thenAnswer((_) async => true);
    });

    testWidgets(
      'given no promo text and the member can edit, when saving one, then sends it to the cubit',
      (tester) async {
        await pumpSection(tester, _loadedEmpty);

        expect(find.text('Texto de divulgação'), findsOneWidget);
        expect(
          find.text('Nenhum texto de divulgação anexado.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('meeting-promo-text-copy')),
          findsNothing,
        );

        await tester.tap(find.text('Adicionar texto'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byKey(const ValueKey('meeting-promo-text-field')),
            matching: find.byType(TextField),
          ),
          'Venham ao próximo!',
        );
        await tester.pump();
        expect(find.text('18 de 2000 caracteres'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('meeting-promo-text-save')));
        await tester.pumpAndSettle();

        verify(() => cubit.savePromoText('Venham ao próximo!')).called(1);
        expect(
          find.byKey(const ValueKey('meeting-promo-text-save')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'given a text over the limit, when editing, then blocks saving',
      (tester) async {
        await pumpSection(tester, _loadedEmpty);

        await tester.tap(find.text('Adicionar texto'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byKey(const ValueKey('meeting-promo-text-field')),
            matching: find.byType(TextField),
          ),
          'a' * 2001,
        );
        await tester.pump();

        expect(
          find.text('O texto passa do limite de 2000 caracteres.'),
          findsOneWidget,
        );
        final save = tester.widget<AppButton>(
          find.byKey(const ValueKey('meeting-promo-text-save')),
        );
        expect(save.onPressed, isNull);
      },
    );

    testWidgets(
      'given a promo text and a read-only member, when rendered, then shows the text with copy and no edit',
      (tester) async {
        await pumpSection(
          tester,
          _loadedEmpty.copyWith(promoText: 'Texto pronto', canAddPhotos: false),
        );

        expect(find.text('Texto pronto'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('meeting-promo-text-copy')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('meeting-promo-text-edit')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'given no promo text and a read-only member, when rendered, then shows only the empty message',
      (tester) async {
        await pumpSection(tester, _loadedEmpty.copyWith(canAddPhotos: false));

        expect(
          find.text('Nenhum texto de divulgação anexado.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('meeting-promo-text-edit')),
          findsNothing,
        );
      },
    );
  });

  group('photo viewer', () {
    setUp(() {
      when(() => cubit.deletePhoto(any())).thenAnswer((_) async => true);
    });

    testWidgets(
      'given the member can manage the record, when removing a photo, then confirms and calls the cubit',
      (tester) async {
        await pumpSection(tester, _loadedEmpty.copyWith(photos: _photos));
        await tester.pump();

        await tester.tap(find.byType(MeetingPhotoThumbnail).at(1));
        await tester.pumpAndSettle();
        expect(find.text('Foto 2 de 4'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('meeting-photo-download')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const ValueKey('meeting-photo-delete')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('meeting-photo-delete-confirm')),
        );
        await tester.pumpAndSettle();

        verify(() => cubit.deletePhoto('p1')).called(1);
        expect(find.text('Foto 2 de 4'), findsNothing);
      },
    );

    testWidgets(
      'given the member cancels the confirmation, when removing, then keeps the photo',
      (tester) async {
        await pumpSection(tester, _loadedEmpty.copyWith(photos: _photos));
        await tester.pump();

        await tester.tap(find.byType(MeetingPhotoThumbnail).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('meeting-photo-delete')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        verifyNever(() => cubit.deletePhoto(any()));
        expect(find.text('Foto 1 de 4'), findsOneWidget);
      },
    );

    testWidgets(
      'given a read-only member, when opening a photo, then can download but not remove',
      (tester) async {
        await pumpSection(
          tester,
          _loadedEmpty.copyWith(photos: _photos, canAddPhotos: false),
        );
        await tester.pump();

        await tester.tap(find.byType(MeetingPhotoThumbnail).first);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('meeting-photo-download')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('meeting-photo-delete')),
          findsNothing,
        );
      },
    );
  });
}
