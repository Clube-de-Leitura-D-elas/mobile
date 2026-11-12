import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/marionette/app_marionette_configuration.dart';

void main() {
  const configuration = appMarionetteConfiguration;

  test('recognizes material_ui interactive widgets', () {
    for (final type in [IconButton, ElevatedButton, TextField, Checkbox]) {
      expect(
        configuration.isInteractiveWidgetType(type),
        isTrue,
        reason: '$type',
      );
    }
  });

  test('does not treat a plain Text as interactive', () {
    expect(configuration.isInteractiveWidgetType(Text), isFalse);
  });

  test('stops traversal at material_ui buttons but not at InkWell', () {
    expect(configuration.shouldStopAtType(IconButton), isTrue);
    expect(configuration.shouldStopAtType(InkWell), isFalse);
  });

  testWidgets('extracts the text of a material_ui TextField', (tester) async {
    final controller = TextEditingController(text: 'Clube');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TextField(controller: controller)),
      ),
    );

    final element = tester.element(find.byType(TextField));
    expect(configuration.extractTextFromWidget(element), 'Clube');
  });
}
