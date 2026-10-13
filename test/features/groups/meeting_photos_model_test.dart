import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_photos_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';

void main() {
  group('MeetingPhotosModel', () {
    test(
      'given photos and can_add_photos, when parsed, then maps both to the domain',
      () {
        final model = MeetingPhotosModel.fromEnvelope(const {
          'photos': [
            {'id': 'photo-1', 'url': 'https://a/1.jpg'},
          ],
          'can_add_photos': false,
        });

        expect(
          model.toDomain(),
          const MeetingPhotosEntity(
            photos: [MeetingPhotoEntity(id: 'photo-1', url: 'https://a/1.jpg')],
            canAddPhotos: false,
          ),
        );
      },
    );

    test('given can_add_photos is true, when parsed, then allows adding', () {
      final model = MeetingPhotosModel.fromEnvelope(const {
        'photos': [],
        'can_add_photos': true,
      });

      expect(model.canAddPhotos, isTrue);
    });

    test(
      'given a response without can_add_photos, when parsed, then keeps adding allowed',
      () {
        final model = MeetingPhotosModel.fromEnvelope(const {'photos': []});

        expect(model.canAddPhotos, isTrue);
      },
    );

    test('given a non-boolean can_add_photos, when parsed, then throws', () {
      expect(
        () => MeetingPhotosModel.fromEnvelope(const {
          'photos': [],
          'can_add_photos': 'yes',
        }),
        throwsFormatException,
      );
    });

    test('given a response without photos, when parsed, then throws', () {
      expect(
        () => MeetingPhotosModel.fromEnvelope(const {'can_add_photos': true}),
        throwsFormatException,
      );
      expect(
        () => MeetingPhotosModel.fromEnvelope(null),
        throwsFormatException,
      );
    });
  });
}
