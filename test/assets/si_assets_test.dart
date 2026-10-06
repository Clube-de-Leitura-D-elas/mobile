import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jovial_svg/jovial_svg.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('compiled si assets', () {
    test('every svg source has a compiled si file', () {
      final svgNames = _baseNames('assets/icons/svg', '.svg');
      final siNames = _baseNames('assets/icons/si', '.si');

      expect(svgNames, isNotEmpty);
      expect(siNames, svgNames);
    });

    test('every si file is in the bundle and is readable', () async {
      final paths = [
        for (final name in _baseNames('assets/icons/si', '.si'))
          'assets/icons/si/$name.si',
      ];
      final bundled = (await AssetManifest.loadFromAssetBundle(rootBundle))
          .listAssets();

      for (final path in paths) {
        expect(bundled, contains(path));

        final data = await rootBundle.load(path);
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        expect(bytes.length, greaterThan(2));
        expect(bytes[0], 0xB0);
        expect(bytes[1], 0xB0);

        final image = ScalableImage.fromSIBytes(bytes, compact: true);
        expect(image.viewport.width, greaterThan(0));
        expect(image.viewport.height, greaterThan(0));
      }
    });

    test('a truncated si payload is not readable', () {
      expect(
        () => ScalableImage.fromSIBytes(Uint8List(0), compact: true),
        throwsA(anything),
      );
      expect(
        () => ScalableImage.fromSIBytes(
          Uint8List.fromList([0xB0, 0xB0]),
          compact: true,
        ),
        throwsA(anything),
      );
    });
  });
}

Set<String> _baseNames(String directory, String extension) {
  return Directory(directory)
      .listSync()
      .whereType<File>()
      .map((file) => file.uri.pathSegments.last)
      .where((name) => name.endsWith(extension))
      .map((name) => name.substring(0, name.length - extension.length))
      .toSet();
}
