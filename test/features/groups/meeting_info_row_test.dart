import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_info_row.dart';

const _label = 'Local: Café Literário - Rua das Flores, 12';
const _address = 'Café Literário - Rua das Flores, 12';
const _linkKey = ValueKey('meeting-info-link');

Widget _wrap(MeetingInfoRow row) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: row),
  );
}

/// O destaque do link só existe enquanto o dedo está encostado.
Finder _highlight() => find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint &&
      widget.painter?.runtimeType.toString() == '_LinkHighlightPainter',
);

List<TextSpan> _spans(WidgetTester tester) {
  final text = tester.widget<Text>(find.text(_label));
  final span = text.textSpan! as TextSpan;
  return span.children?.cast<TextSpan>() ?? [span];
}

void main() {
  testWidgets('given no onTap, when shown, then it is plain text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const MeetingInfoRow(icon: AppIcons.location, label: _label)),
    );

    expect(find.byKey(_linkKey), findsNothing);
    expect(_spans(tester).single.style?.decoration, isNull);
  });

  testWidgets(
    'given a link label, when pressed, then highlights it until released',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          MeetingInfoRow(
            icon: AppIcons.location,
            label: _label,
            linkLabel: _address,
            onTap: () => taps++,
          ),
        ),
      );
      expect(_highlight(), findsNothing);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text(_label)),
      );
      await tester.pump(kPressTimeout);
      expect(_highlight(), findsOneWidget);

      await gesture.up();
      await tester.pump();
      expect(_highlight(), findsNothing);
      expect(taps, 1);
    },
  );

  testWidgets(
    'given a press that turns into a drag, when cancelled, then removes the highlight',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          MeetingInfoRow(
            icon: AppIcons.location,
            label: _label,
            linkLabel: _address,
            onTap: () => taps++,
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text(_label)),
      );
      await tester.pump(kPressTimeout);
      expect(_highlight(), findsOneWidget);

      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(_highlight(), findsNothing);
      expect(taps, 0);
    },
  );

  testWidgets(
    'given no link label, when shown, then underlines the whole label',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeetingInfoRow(icon: AppIcons.location, label: _label, onTap: () {}),
        ),
      );

      final spans = _spans(tester);
      expect(spans.map((span) => span.text).join(), _label);
      expect(
        spans.singleWhere((span) => span.text == _label).style?.decoration,
        TextDecoration.underline,
      );
    },
  );

  testWidgets(
    'given a link label that is not in the text, when shown, then underlines the whole label',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeetingInfoRow(
            icon: AppIcons.location,
            label: _label,
            linkLabel: 'Outro lugar',
            onTap: () {},
          ),
        ),
      );

      expect(
        _spans(
          tester,
        ).singleWhere((span) => span.text == _label).style?.decoration,
        TextDecoration.underline,
      );
    },
  );
}
