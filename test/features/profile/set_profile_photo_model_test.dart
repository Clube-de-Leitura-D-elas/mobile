import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/data/models/set_profile_photo_model.dart';

void main() {
  group('SetProfilePhotoModel.photoUrlFromJson', () {
    test('returns photo_url when present', () {
      expect(
        SetProfilePhotoModel.photoUrlFromJson({
          'photo_url': 'https://cdn.example/photo.jpg',
        }),
        'https://cdn.example/photo.jpg',
      );
    });

    test('returns null for invalid payloads', () {
      expect(SetProfilePhotoModel.photoUrlFromJson(null), isNull);
      expect(SetProfilePhotoModel.photoUrlFromJson(<String, dynamic>{}), isNull);
      expect(
        SetProfilePhotoModel.photoUrlFromJson({'photo_url': ''}),
        isNull,
      );
      expect(
        SetProfilePhotoModel.photoUrlFromJson({'photo_url': 1}),
        isNull,
      );
    });
  });
}
