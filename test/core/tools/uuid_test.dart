import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/uuid.dart';

void main() {
  test('accepts a generated uuid and upper case', () {
    final uuid = generateUuidV4();

    expect(isUuid(uuid), isTrue);
    expect(isUuid(uuid.toUpperCase()), isTrue);
  });

  test('rejects empty, malformed and padded values', () {
    for (final value in [
      '',
      'abc',
      '11111111-1111-1111-1111-11111111111',
      '11111111-1111-1111-1111-111111111111-x',
      ' 11111111-1111-1111-1111-111111111111',
    ]) {
      expect(isUuid(value), isFalse, reason: value);
    }
  });
}
