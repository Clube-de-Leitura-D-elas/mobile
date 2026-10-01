import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/media/image_picker_photo_picker.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  late MockImagePicker imagePicker;
  late ImagePickerPhotoPicker picker;

  final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

  XFile file(Uint8List bytes) => XFile.fromData(bytes, name: 'photo.jpg');

  setUp(() {
    imagePicker = MockImagePicker();
    picker = ImagePickerPhotoPicker(imagePicker);
  });

  void answerMulti(Future<List<XFile>> Function() answer) {
    when(
      () => imagePicker.pickMultiImage(
        imageQuality: any(named: 'imageQuality'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => answer());
  }

  test(
    'given a selection, when picking, then compresses, limits and detects the type',
    () async {
      answerMulti(
        () async => [
          file(jpeg),
          file(Uint8List.fromList([1, 2])),
        ],
      );

      final photos = (await picker.pickFromGallery(limit: 10)).unwrap();

      expect(photos.map((photo) => photo.bytes), [
        jpeg,
        Uint8List.fromList([1, 2]),
      ]);
      expect(photos.map((photo) => photo.contentType), ['image/jpeg', null]);
      expect(photos.first.id, matches(_uuidV4));
      expect(photos.first.id, isNot(photos.last.id));
      verify(
        () => imagePicker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1920,
          limit: 10,
        ),
      ).called(1);
    },
  );

  test(
    'given the picker returns more than the limit, when picking, then keeps only the limit',
    () async {
      answerMulti(() async => List.generate(4, (_) => file(jpeg)));

      final result = await picker.pickFromGallery(limit: 2);

      expect(result.unwrap(), hasLength(2));
    },
  );

  test(
    'given a limit of one, when picking, then uses the single image picker',
    () async {
      when(
        () => imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1920,
        ),
      ).thenAnswer((_) async => null);

      final result = await picker.pickFromGallery(limit: 1);

      expect(result, const Success<List<PickedPhoto>, PhotoPickerFailure>([]));
    },
  );

  test(
    'given photo access is denied, when picking, then returns PhotoAccessDeniedFailure',
    () async {
      answerMulti(
        () async => throw PlatformException(code: 'photo_access_denied'),
      );

      final result = await picker.pickFromGallery(limit: 10);

      expect(
        result,
        const Failure<List<PickedPhoto>, PhotoPickerFailure>(
          PhotoAccessDeniedFailure(),
        ),
      );
    },
  );

  test(
    'given an unexpected platform error, when picking, then returns PhotoPickerUnknownFailure',
    () async {
      answerMulti(() async => throw PlatformException(code: 'invalid_image'));

      final result = await picker.pickFromGallery(limit: 10);

      expect(
        result,
        const Failure<List<PickedPhoto>, PhotoPickerFailure>(
          PhotoPickerUnknownFailure(),
        ),
      );
    },
  );
}
