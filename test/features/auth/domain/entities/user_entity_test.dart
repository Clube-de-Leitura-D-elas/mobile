import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';

void main() {
  group('UserEntity', () {
    const cityZone = (id: 'cz-1', name: 'Centro', acronym: 'CTR');
    const user = UserEntity(
      name: 'Maria Silva',
      mail: 'maria@example.com',
      birthday: '1990-01-01',
      phoneNumber: '11999999999',
      instagramUser: '@maria',
      educationDegree: 'Superior',
      jobPosition: 'Engenheira',
      cityZone: cityZone,
    );

    test('props includes all fields', () {
      expect(
        user.props,
        equals([
          'Maria Silva',
          'maria@example.com',
          '1990-01-01',
          '11999999999',
          '@maria',
          'Superior',
          'Engenheira',
          cityZone,
        ]),
      );
    });

    test('copyWith copies all or specific fields correctly', () {
      final updated = user.copyWith(
        name: 'Maria Souza',
        jobPosition: 'Arquiteta',
      );

      expect(updated.name, 'Maria Souza');
      expect(updated.mail, 'maria@example.com');
      expect(updated.jobPosition, 'Arquiteta');

      final copiedSame = user.copyWith();
      expect(copiedSame, equals(user));
    });
  });

  group('UserFailure', () {
    test('UserFailure props and equality', () {
      const failure = UserFailure(message: 'Error message');
      expect(failure.message, 'Error message');
      expect(failure.props, equals(const ['Error message']));
    });

    test('MissingGoogleIdTokenFailure inherits UserFailure', () {
      const failure = MissingGoogleIdTokenFailure(message: 'Token missing');
      expect(failure, isA<UserFailure>());
      expect(failure.message, 'Token missing');
    });
  });
}
