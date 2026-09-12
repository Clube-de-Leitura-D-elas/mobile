import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel', () {
    test('fromJson returns null for null or non-map input', () {
      expect(UserProfileModel.fromJson(null), isNull);
      expect(UserProfileModel.fromJson('invalid'), isNull);
    });

    test('fromJson handles wrapped profile object', () {
      final json = {
        'profile': {
          'id': 'p-1',
          'name': 'John Profile',
          'email': 'john@profile.com',
          'adress': 'Main St 123',
          'phone_number': '555-1234',
          'birthday': '01/01/1985',
          'instagram': '@johnprof',
          'education_degree': 'Bachelor',
          'job_position': 'Developer',
          'user_id': 'uid-123',
          'is_Active': true,
        }
      };

      final profile = UserProfileModel.fromJson(json);

      expect(profile, isNotNull);
      expect(profile!.id, equals('p-1'));
      expect(profile.name, equals('John Profile'));
      expect(profile.email, equals('john@profile.com'));
      expect(profile.address, equals('Main St 123'));
      expect(profile.phoneNumber, equals('555-1234'));
      expect(profile.birthday, equals('01/01/1985'));
      expect(profile.instagram, equals('@johnprof'));
      expect(profile.educationDegree, equals('Bachelor'));
      expect(profile.jobPosition, equals('Developer'));
      expect(profile.userId, equals('uid-123'));
      expect(profile.isActive, isTrue);
    });

    test('fromMap parses raw map with address fallback and defaults', () {
      final map = {
        'id': 'p-2',
        'name': 'Jane Profile',
        'email': 'jane@profile.com',
        'address': 'Second St 456',
        'user_id': 'uid-456',
      };

      final profile = UserProfileModel.fromMap(map);

      expect(profile.id, equals('p-2'));
      expect(profile.name, equals('Jane Profile'));
      expect(profile.email, equals('jane@profile.com'));
      expect(profile.address, equals('Second St 456'));
      expect(profile.phoneNumber, equals(''));
      expect(profile.isActive, isTrue);
    });
  });
}
