import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('UserModel', () {
    test('fromSupabase parses User metadata correctly', () {
      final user = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Jane Doe',
          'birthday': '01/01/1990',
          'phone': '123456789',
          'instagram': '@jane',
          'education_degree': 'Higher',
          'job_position': 'Designer',
          'city': (id: '1', name: 'Porto Alegre', acronym: 'POA'),
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'jane@example.com',
      );

      final entity = UserModel.fromSupabase(user);

      expect(entity.name, equals('Jane Doe'));
      expect(entity.mail, equals('jane@example.com'));
      expect(entity.birthday, equals('01/01/1990'));
      expect(entity.phoneNumber, equals('123456789'));
      expect(entity.instagramUser, equals('@jane'));
      expect(entity.educationDegree, equals('Higher'));
      expect(entity.jobPosition, equals('Designer'));
      expect(entity.cityZone.name, equals('Porto Alegre'));
    });

    test('fromSupabase handles missing metadata with fallbacks', () {
      final user = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: null,
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'testuser@example.com',
      );

      final entity = UserModel.fromSupabase(user);

      expect(entity.name, equals('testuser'));
      expect(entity.mail, equals('testuser@example.com'));
      expect(entity.birthday, equals(''));
      expect(entity.cityZone.id, equals(''));
    });

    test('fromProfileMap parses Map correctly', () {
      final map = {
        'name': 'Alice',
        'email': 'alice@example.com',
        'birthday': '02/02/1995',
        'phone_number': '987654321',
        'instagram': '@alice',
        'education_degree': 'Postgrad',
        'job_position': 'Manager',
      };

      final entity = UserModel.fromProfileMap(map);

      expect(entity.name, equals('Alice'));
      expect(entity.mail, equals('alice@example.com'));
      expect(entity.birthday, equals('02/02/1995'));
      expect(entity.phoneNumber, equals('987654321'));
      expect(entity.instagramUser, equals('@alice'));
      expect(entity.educationDegree, equals('Postgrad'));
      expect(entity.jobPosition, equals('Manager'));
    });
  });
}
