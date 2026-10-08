import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/icons/app_icons.dart';

void main() {
  group('AppIcons', () {
    test('exposes every compiled si file and no extra path', () {
      final onDisk = Directory('assets/icons/si')
          .listSync()
          .whereType<File>()
          .map((file) => file.uri.pathSegments.last)
          .where((name) => name.endsWith('.si'))
          .map((name) => 'assets/icons/si/$name')
          .toSet();
      final mapped = AppIcons.all.map((icon) => icon.assetPath).toSet();

      expect(mapped, onDisk);
      expect(AppIcons.all, hasLength(mapped.length));
    });

    test('named icons point at their own file', () {
      expect(AppIcons.book.assetPath, 'assets/icons/si/book.si');
      expect(AppIcons.home.assetPath, 'assets/icons/si/home.si');
      expect(AppIcons.user.assetPath, 'assets/icons/si/user.si');
      expect(AppIcons.book == AppIcons.user, isFalse);
      expect(AppIcons.book == AppIcons.book, isTrue);
      expect(AppIcons.book.hashCode, isNot(AppIcons.user.hashCode));
    });
  });
}
