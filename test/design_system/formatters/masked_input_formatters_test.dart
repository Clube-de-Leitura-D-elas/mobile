import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

TextEditingValue _value(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

TextEditingValue _type(TextInputFormatter formatter, String keys) {
  var value = TextEditingValue.empty;
  for (final key in keys.split('')) {
    final next = value.text + key;
    value = formatter.formatEditUpdate(value, _value(next));
  }
  return value;
}

TextEditingValue _backspace(
  TextInputFormatter formatter,
  TextEditingValue value,
) {
  final cursor = value.selection.extentOffset;
  final text =
      value.text.substring(0, cursor - 1) + value.text.substring(cursor);
  return formatter.formatEditUpdate(value, _value(text, cursor - 1));
}

void main() {
  group('DateInputFormatter', () {
    const formatter = DateInputFormatter();

    test('masks each prefix while typing and keeps the cursor at the end', () {
      const expected = {
        '1': '1',
        '12': '12',
        '120': '12/0',
        '1203': '12/03',
        '12032': '12/03/2',
        '12032026': '12/03/2026',
      };
      expected.forEach((keys, text) {
        final result = _type(formatter, keys);
        expect(result.text, text);
        expect(result.selection.extentOffset, text.length);
      });
    });

    test('ignores digits beyond the limit', () {
      final full = _type(formatter, '12032026');
      final result = formatter.formatEditUpdate(full, _value('12/03/20269'));

      expect(result.text, '12/03/2026');
    });

    test('ignores a digit inserted in the middle of a full field', () {
      final full = _value('12/03/2026', 0);
      final result = formatter.formatEditUpdate(full, _value('912/03/2026', 1));

      expect(result.text, '12/03/2026');
    });

    test('drops non-digits from pasted text', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('data: 12-03-2026!'),
      );

      expect(result.text, '12/03/2026');
      expect(result.selection.extentOffset, 10);
    });

    test('truncates pasted text longer than the mask', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('120320261234'),
      );

      expect(result.text, '12/03/2026');
    });

    test('keeps already masked text unchanged', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('12/03/2026'),
      );

      expect(result.text, '12/03/2026');
      expect(formatter.format('12/03/2026'), '12/03/2026');
    });

    test('backspace deletes digits until the field is empty', () {
      var value = _type(formatter, '12032026');
      final seen = <String>[];
      while (value.text.isNotEmpty) {
        value = _backspace(formatter, value);
        seen.add(value.text);
      }

      expect(seen, [
        '12/03/202',
        '12/03/20',
        '12/03/2',
        '12/03',
        '12/0',
        '12',
        '1',
        '',
      ]);
    });

    test('backspace right after a separator removes the digit before it', () {
      final start = _value('12/03/2026', 3);
      final result = _backspace(formatter, start);

      expect(result.text, '10/32/026');
      expect(result.selection.extentOffset, 1);
    });

    test('inserting a digit in the middle keeps the cursor after it', () {
      final result = formatter.formatEditUpdate(
        _value('12/3', 3),
        _value('12/03', 4),
      );

      expect(result.text, '12/03');
      expect(result.selection.extentOffset, 4);
    });

    test('formats a prefilled raw value', () {
      expect(formatter.format('12032026'), '12/03/2026');
      expect(formatter.format(''), '');
    });
  });

  group('TimeInputFormatter', () {
    const formatter = TimeInputFormatter();

    test('masks each prefix while typing', () {
      expect(_type(formatter, '1').text, '1');
      expect(_type(formatter, '19').text, '19');
      expect(_type(formatter, '193').text, '19:3');
      expect(_type(formatter, '1930').text, '19:30');
    });

    test('ignores digits beyond the limit', () {
      final full = _type(formatter, '1930');
      final result = formatter.formatEditUpdate(full, _value('19:305'));

      expect(result.text, '19:30');
    });

    test('backspace after the colon removes the hour digit', () {
      final result = _backspace(formatter, _value('19:30', 3));

      expect(result.text, '13:0');
      expect(result.selection.extentOffset, 1);
    });

    test('drops non-digits from pasted text', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('19h30'),
      );

      expect(result.text, '19:30');
    });
  });

  group('PhoneInputFormatter', () {
    const formatter = PhoneInputFormatter();

    test('masks each prefix while typing a mobile number', () {
      const expected = {
        '5': '(5',
        '51': '(51',
        '519': '(51) 9',
        '519999': '(51) 9999',
        '5199999': '(51) 9999-9',
        '5199999999': '(51) 9999-9999',
        '51999999999': '(51) 99999-9999',
      };
      expected.forEach((keys, text) {
        final result = _type(formatter, keys);
        expect(result.text, text);
        expect(result.selection.extentOffset, text.length);
      });
    });

    test('accepts a 10-digit landline', () {
      expect(_type(formatter, '5133333333').text, '(51) 3333-3333');
    });

    test('switches back to the landline mask on backspace', () {
      final mobile = _type(formatter, '51999999999');

      expect(_backspace(formatter, mobile).text, '(51) 9999-9999');
    });

    test('ignores a 12th typed digit, even with area code 55', () {
      final full = _type(formatter, '55999999999');
      final result = formatter.formatEditUpdate(full, _value('${full.text}1'));

      expect(result.text, '(55) 99999-9999');
    });

    test('backspace deletes digits until the field is empty', () {
      var value = _type(formatter, '51999999999');
      var steps = 0;
      while (value.text.isNotEmpty && steps < 20) {
        value = _backspace(formatter, value);
        steps++;
      }

      expect(value.text, '');
      expect(steps, 11);
    });

    test('backspace right after the hyphen removes the digit before it', () {
      final start = _value('(51) 99999-8888', 11);
      final result = _backspace(formatter, start);

      expect(result.text, '(51) 9999-8888');
      expect(result.selection.extentOffset, 9);
    });

    test('drops non-digits from pasted text', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _value('tel. 51 99999 9999'),
      );

      expect(result.text, '(51) 99999-9999');
    });

    test('keeps already masked text unchanged', () {
      expect(formatter.format('(51) 99999-9999'), '(51) 99999-9999');
      expect(formatter.format('(51) 3333-3333'), '(51) 3333-3333');
    });

    test('formats prefilled values, dropping the +55 country code', () {
      expect(formatter.format('51999999999'), '(51) 99999-9999');
      expect(formatter.format('+55 51 99999-9999'), '(51) 99999-9999');
      expect(formatter.format('+55 51 3333-3333'), '(51) 3333-3333');
      expect(formatter.format('55999999999'), '(55) 99999-9999');
    });
  });
}
