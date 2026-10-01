import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/media/image_content_type.dart';

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);

void main() {
  test('given jpeg bytes, when detected, then returns image/jpeg', () {
    expect(
      detectImageContentType(_bytes([0xFF, 0xD8, 0xFF, 0xE0])),
      'image/jpeg',
    );
  });

  test('given png bytes, when detected, then returns image/png', () {
    expect(
      detectImageContentType(_bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A])),
      'image/png',
    );
  });

  test('given webp bytes, when detected, then returns image/webp', () {
    final bytes = _bytes([
      ...'RIFF'.codeUnits,
      0,
      0,
      0,
      0,
      ...'WEBP'.codeUnits,
    ]);

    expect(detectImageContentType(bytes), 'image/webp');
  });

  test('given heic bytes, when detected, then returns image/heic', () {
    final bytes = _bytes([0, 0, 0, 24, ...'ftypheic'.codeUnits]);

    expect(detectImageContentType(bytes), 'image/heic');
  });

  test('given an ftyp video brand, when detected, then returns null', () {
    final bytes = _bytes([0, 0, 0, 24, ...'ftypmp42'.codeUnits]);

    expect(detectImageContentType(bytes), isNull);
  });

  test('given gif or short bytes, when detected, then returns null', () {
    expect(detectImageContentType(_bytes('GIF89a'.codeUnits)), isNull);
    expect(detectImageContentType(_bytes([0xFF])), isNull);
  });
}
