import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_photo_cubit.dart';
import 'package:mobile/features/profile/presentation/widgets/edit_profile_photo_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

void main() {
  late MockProfileRepository repository;
  late MockPhotoPicker picker;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repository = MockProfileRepository();
    picker = MockPhotoPicker();
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => BlocProvider(
                    create: (_) => EditProfilePhotoCubit(
                      profileRepository: repository,
                      photoPicker: picker,
                    ),
                    child: const EditProfilePhotoDialog(),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  void stubPickedPhoto() {
    when(() => picker.pickFromGallery(limit: 1)).thenAnswer(
      (_) async => Success([
        PickedPhoto(
          id: 'pick-1',
          bytes: Uint8List.fromList([0xFF, 0xD8]),
          contentType: 'image/jpeg',
        ),
      ]),
    );
  }

  testWidgets('shows title, preview and change button', (tester) async {
    await openDialog(tester);

    expect(find.text('Editar foto'), findsOneWidget);
    expect(find.text('Trocar foto'), findsOneWidget);
    expect(find.byType(AppDialog), findsOneWidget);
  });

  testWidgets('calls gallery picker when tapping Trocar foto', (tester) async {
    when(
      () => picker.pickFromGallery(limit: 1),
    ).thenAnswer((_) async => const Success([]));

    await openDialog(tester);

    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    verify(() => picker.pickFromGallery(limit: 1)).called(1);
  });

  testWidgets('closes and returns the same photo url', (tester) async {
    const photoUrl = 'https://cdn.example/same.jpg';
    String? result;
    stubPickedPhoto();
    when(
      () => repository.setProfilePhoto(
        bytes: any(named: 'bytes'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => const Success(photoUrl));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => BlocProvider(
                    create: (_) => EditProfilePhotoCubit(
                      profileRepository: repository,
                      photoPicker: picker,
                      initialPhotoUrl: photoUrl,
                    ),
                    child: const EditProfilePhotoDialog(
                      initialPhotoUrl: photoUrl,
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(EditProfilePhotoDialog), findsNothing);
    expect(result, photoUrl);
  });

  testWidgets('shows an error toast and stays open when upload fails', (
    tester,
  ) async {
    when(() => picker.pickFromGallery(limit: 1)).thenAnswer(
      (_) async => Success([
        PickedPhoto(
          id: 'pick-1',
          bytes: Uint8List.fromList([0xFF, 0xD8]),
          contentType: 'image/jpeg',
        ),
      ]),
    );
    when(
      () => repository.setProfilePhoto(
        bytes: any(named: 'bytes'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => const Failure(ProfilePhotoUploadFailure()));

    await openDialog(tester);
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(
      find.text('Não foi possível atualizar a foto. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.byType(EditProfilePhotoDialog), findsOneWidget);
  });

  testWidgets('shows a toast when the photo is rejected', (tester) async {
    stubPickedPhoto();
    when(
      () => repository.setProfilePhoto(
        bytes: any(named: 'bytes'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => const Failure(ProfilePhotoRejectedFailure()));

    await openDialog(tester);
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(
      find.text('Esta foto não pode ser usada como foto de perfil.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a toast when the photo is too large', (tester) async {
    stubPickedPhoto();
    when(
      () => repository.setProfilePhoto(
        bytes: any(named: 'bytes'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async => const Failure(ProfilePhotoTooLargeFailure()));

    await openDialog(tester);
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(
      find.text('A foto passa do tamanho máximo permitido.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a toast when gallery access is denied', (tester) async {
    when(
      () => picker.pickFromGallery(limit: 1),
    ).thenAnswer((_) async => const Failure(PhotoAccessDeniedFailure()));

    await openDialog(tester);
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(
      find.text(
        'Permita o acesso às fotos nos ajustes do aparelho para adicionar fotos.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a toast when the gallery fails to open', (tester) async {
    when(
      () => picker.pickFromGallery(limit: 1),
    ).thenAnswer((_) async => const Failure(PhotoPickerUnknownFailure()));

    await openDialog(tester);
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(
      find.text('Não foi possível abrir a galeria. Tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a toast when the picked file has no content type', (
    tester,
  ) async {
    when(() => picker.pickFromGallery(limit: 1)).thenAnswer(
      (_) async => Success([
        PickedPhoto(id: 'pick-1', bytes: Uint8List.fromList([0xFF, 0xD8])),
      ]),
    );

    await openDialog(tester);
    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(
      find.text(
        '1 foto foi ignorada: passa de 5 MB ou o formato não é aceito.',
      ),
      findsOneWidget,
    );
  });
}
