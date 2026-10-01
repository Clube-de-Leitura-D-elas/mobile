import 'dart:typed_data';

String? detectImageContentType(Uint8List bytes) {
  if (_startsWith(bytes, 0, const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (_startsWith(bytes, 0, const [0x89, 0x50, 0x4E, 0x47])) {
    return 'image/png';
  }
  if (_startsWith(bytes, 0, 'RIFF'.codeUnits) &&
      _startsWith(bytes, 8, 'WEBP'.codeUnits)) {
    return 'image/webp';
  }
  if (_startsWith(bytes, 4, 'ftyp'.codeUnits)) return 'image/heic';
  return null;
}

bool _startsWith(Uint8List bytes, int offset, List<int> signature) {
  if (bytes.length < offset + signature.length) return false;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[offset + i] != signature[i]) return false;
  }
  return true;
}
