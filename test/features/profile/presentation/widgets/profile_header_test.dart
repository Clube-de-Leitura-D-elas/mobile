import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/widgets/edit_profile_photo_dialog.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

void main() {
  setUpAll(() => registerFallbackValue(Uint8List(0)));

  Future<void> pumpHeader(
    WidgetTester tester, {
    int? booksReadCount,
    int? groupsCount,
    String? photoUrl,
    ValueChanged<String>? onPhotoChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: ProfileHeader(
            name: 'Roberta',
            booksReadCount: booksReadCount,
            groupsCount: groupsCount,
            photoUrl: photoUrl,
            onPhotoChanged: onPhotoChanged,
          ),
        ),
      ),
    );
  }

  group('ProfileHeader', () {
    testWidgets('mostra o nome e o avatar grande', (tester) async {
      await pumpHeader(tester);

      expect(find.text('Roberta'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppParticipantAvatar)),
        const Size.square(ProfileHeader.avatarDiameter),
      );
    });

    testWidgets('mostra os livros lidos e os grupos, no plural certo', (
      tester,
    ) async {
      await pumpHeader(tester, booksReadCount: 5, groupsCount: 2);
      expect(find.text('5 livros lidos'), findsOneWidget);
      expect(find.text('2 grupos'), findsOneWidget);

      await pumpHeader(tester, booksReadCount: 1, groupsCount: 1);
      expect(find.text('1 livro lido'), findsOneWidget);
      expect(find.text('1 grupo'), findsOneWidget);

      await pumpHeader(tester, booksReadCount: 0, groupsCount: 0);
      expect(find.text('0 livros lidos'), findsOneWidget);
      expect(find.text('0 grupos'), findsOneWidget);
    });

    testWidgets('esconde os contadores enquanto o resumo não chega', (
      tester,
    ) async {
      await pumpHeader(tester);

      expect(find.textContaining('livro'), findsNothing);
      expect(find.textContaining('grupo'), findsNothing);
      expect(find.byType(AppIcon), findsNothing);
    });

    testWidgets('os ícones dos contadores ficam fora da leitura de tela', (
      tester,
    ) async {
      await pumpHeader(tester, booksReadCount: 5, groupsCount: 2);

      for (final icon in tester.widgetList<AppIcon>(find.byType(AppIcon))) {
        expect(
          find.ancestor(
            of: find.byWidget(icon),
            matching: find.byType(ExcludeSemantics),
          ),
          findsWidgets,
        );
      }
      expect(find.bySemanticsLabel(RegExp('5 livros lidos')), findsOneWidget);
    });

    testWidgets('o avatar fica fora da leitura de tela', (tester) async {
      await pumpHeader(tester);

      expect(
        find.ancestor(
          of: find.byType(AppParticipantAvatar),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Editar foto de perfil'), findsOneWidget);
    });

    testWidgets('abre o modal ao tocar no avatar e atualiza a foto', (
      tester,
    ) async {
      const photoUrl = 'https://cdn.example/new.jpg';
      final repository = MockProfileRepository();
      final picker = MockPhotoPicker();
      serviceLocator.allowReassignment = true;
      serviceLocator.registerSingleton<ProfileRepository>(repository);
      serviceLocator.registerSingleton<PhotoPicker>(picker);
      addTearDown(() {
        serviceLocator.unregister<ProfileRepository>();
        serviceLocator.unregister<PhotoPicker>();
      });

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
          contentType: 'image/jpeg',
        ),
      ).thenAnswer((_) async => const Success(photoUrl));

      final changes = <String>[];
      await pumpHeader(tester, onPhotoChanged: changes.add);
      await tester.tap(find.bySemanticsLabel('Editar foto de perfil'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePhotoDialog), findsOneWidget);
      expect(find.text('Editar foto'), findsOneWidget);

      await tester.tap(find.text('Trocar foto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EditProfilePhotoDialog), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppParticipantAvatar && widget.photoUrl == photoUrl,
        ),
        findsOneWidget,
      );
      expect(changes, [photoUrl]);
    });

    testWidgets('fechar o modal sem trocar mantém a foto anterior', (
      tester,
    ) async {
      serviceLocator.allowReassignment = true;
      serviceLocator.registerSingleton<ProfileRepository>(
        MockProfileRepository(),
      );
      serviceLocator.registerSingleton<PhotoPicker>(MockPhotoPicker());
      addTearDown(() {
        serviceLocator.unregister<ProfileRepository>();
        serviceLocator.unregister<PhotoPicker>();
      });

      final changes = <String>[];
      await pumpHeader(
        tester,
        photoUrl: 'https://cdn.example/old.jpg',
        onPhotoChanged: changes.add,
      );
      await tester.tap(find.bySemanticsLabel('Editar foto de perfil'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePhotoDialog), findsNothing);
      expect(changes, isEmpty);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppParticipantAvatar &&
              widget.photoUrl == 'https://cdn.example/old.jpg',
        ),
        findsOneWidget,
      );
    });

    testWidgets('atualiza o avatar quando a url do perfil muda', (
      tester,
    ) async {
      await pumpHeader(tester);
      await pumpHeader(
        tester,
        photoUrl: 'https://cdn.example/from-profile.jpg',
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppParticipantAvatar &&
              widget.photoUrl == 'https://cdn.example/from-profile.jpg',
        ),
        findsOneWidget,
      );
    });
  });
}
