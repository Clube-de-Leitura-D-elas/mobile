import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';

void main() {
  group('MeetingPhotoModel', () {
    test('given a photo json, when parsed, then maps id and url', () {
      final model = MeetingPhotoModel.fromJson(const {
        'id': 'photo-1',
        'url': 'https://cdn.example.com/photo-1.jpg',
      });

      expect(
        model.toDomain(),
        const MeetingPhotoEntity(
          id: 'photo-1',
          url: 'https://cdn.example.com/photo-1.jpg',
        ),
      );
    });

    test('given a photo without url, when parsed, then throws', () {
      expect(
        () => MeetingPhotoModel.fromJson(const {'id': 'photo-1'}),
        throwsFormatException,
      );
    });

    test('given a list envelope, when parsed, then keeps the order', () {
      final photos = MeetingPhotoModel.listFromEnvelope({
        'photos': [
          {'id': 'photo-1', 'url': 'https://a/1.jpg'},
          {'id': 'photo-2', 'url': 'https://a/2.jpg'},
        ],
      });

      expect(photos.map((photo) => photo.id), ['photo-1', 'photo-2']);
    });

    test('given an empty list envelope, when parsed, then is empty', () {
      expect(MeetingPhotoModel.listFromEnvelope({'photos': []}), isEmpty);
    });

    test('given a list envelope without photos, when parsed, then throws', () {
      expect(
        () => MeetingPhotoModel.listFromEnvelope({'items': []}),
        throwsFormatException,
      );
      expect(
        () => MeetingPhotoModel.listFromEnvelope(null),
        throwsFormatException,
      );
    });

    test('given an upload envelope, when parsed, then maps the photo', () {
      final photo = MeetingPhotoModel.fromEnvelope({
        'photo': {'id': 'photo-9', 'url': 'https://a/9.jpg'},
      });

      expect(photo.id, 'photo-9');
      expect(photo.url, 'https://a/9.jpg');
    });

    test(
      'given an upload envelope with null photo, when parsed, then throws',
      () {
        expect(
          () => MeetingPhotoModel.fromEnvelope({'photo': null}),
          throwsFormatException,
        );
      },
    );
  });
}
