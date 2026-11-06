import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';

void main() {
  final profile = UserProfileEntity(
    id: 'p-1',
    name: 'Roberta',
    email: 'roberta@example.com',
    address: 'Rua A',
    phoneNumber: '51999999999',
    birthday: '01/01/1990',
    instagram: '@roberta',
    educationDegree: 'Superior',
    jobPosition: 'Professora',
    userId: 'u-1',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
    photoUrl: 'https://example.com/antiga.jpg',
  );

  group('UserProfileEntity.copyWith', () {
    test('replaces only the photo', () {
      final updated = profile.copyWith(
        photoUrl: 'https://example.com/nova.jpg',
      );

      expect(updated.photoUrl, 'https://example.com/nova.jpg');
      expect(
        updated,
        UserProfileEntity(
          id: profile.id,
          name: profile.name,
          email: profile.email,
          address: profile.address,
          phoneNumber: profile.phoneNumber,
          birthday: profile.birthday,
          instagram: profile.instagram,
          educationDegree: profile.educationDegree,
          jobPosition: profile.jobPosition,
          userId: profile.userId,
          isActive: profile.isActive,
          createdAt: profile.createdAt,
          photoUrl: 'https://example.com/nova.jpg',
        ),
      );
    });

    test('keeps the current photo when none is given', () {
      expect(profile.copyWith(), profile);
    });
  });

  test('profiles with different photos are not equal', () {
    expect(
      profile.copyWith(photoUrl: 'https://example.com/nova.jpg'),
      isNot(profile),
    );
  });
}
