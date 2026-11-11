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

TextEditingValue _delete(TextInputFormatter formatter, TextEditingValue value) {
  final cursor = value.selection.extentOffset;
  final text =
      value.text.substring(0, cursor) + value.text.substring(cursor + 1);
  return formatter.formatEditUpdate(value, _value(text, cursor));
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

    test('typing a separator after a single digit pads it with zero', () {
      const expected = {
        '1/': '01/',
        '1/5': '01/5',
        '1/5/': '01/05/',
        '1/5/2026': '01/05/2026',
        '1/5/1960': '01/05/1960',
        '12/': '12/',
        '12/3-': '12/03/',
        '/': '',
      };
      expected.forEach((keys, text) {
        final result = _type(formatter, keys);
        expect(result.text, text, reason: keys);
        expect(result.selection.extentOffset, text.length, reason: keys);
      });
    });

    test('backspace on the trailing separator keeps the digits', () {
      final result = _backspace(formatter, _type(formatter, '1/'));

      expect(result.text, '01');
      expect(result.selection.extentOffset, 2);
    });

    test('delete before a separator removes the digit after it', () {
      final result = _delete(formatter, _value('12/03/2026', 2));

      expect(result.text, '12/32/026');
      expect(result.selection.extentOffset, 2);
    });

    test('deleting a selected separator keeps the value', () {
      const start = TextEditingValue(
        text: '12/03/2026',
        selection: TextSelection(baseOffset: 2, extentOffset: 3),
      );
      final result = formatter.formatEditUpdate(start, _value('1203/2026', 2));

      expect(result.text, '12/03/2026');
      expect(result.selection.extentOffset, 2);
    });

    test('pasted or dictated dates pad single-digit groups', () {
      const pasted = {
        '1/5/2026': '01/05/2026',
        '10/1/1960': '10/01/1960',
        '1 de 5 de 1960': '01/05/1960',
      };
      pasted.forEach((input, text) {
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _value(input),
        );
        expect(result.text, text, reason: input);
        expect(result.selection.extentOffset, text.length, reason: input);
      });
    });

    test('pasting the rest of a date after typing part of it', () {
      final partial = _type(formatter, '1/');
      final result = formatter.formatEditUpdate(
        partial,
        _value('${partial.text}5/2026'),
      );

      expect(result.text, '01/05/2026');
      expect(result.selection.extentOffset, 10);
    });

    test('pasted ISO dates are read as year-month-day', () {
      for (final input in ['2026-05-01', '2026-5-1']) {
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _value(input),
        );
        expect(result.text, '01/05/2026', reason: input);
      }
      expect(formatter.format('2026-05-01'), '01/05/2026');
    });

    test('pasting a full date over a selection replaces it', () {
      const start = TextEditingValue(
        text: '12/03/2026',
        selection: TextSelection(baseOffset: 0, extentOffset: 10),
      );
      final result = formatter.formatEditUpdate(start, _value('1/5/1960'));

      expect(result.text, '01/05/1960');
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
      expect(formatter.format('1/5/1960'), '01/05/1960');
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

    test('typing a separator after a single hour digit pads it', () {
      expect(_type(formatter, '9:').text, '09:');
      expect(_type(formatter, '9:30').text, '09:30');
      expect(_type(formatter, '9h30').text, '09:30');
    });

    test('pasted or dictated times pad the hour', () {
      for (final input in ['9:30', '9h30', '9 30']) {
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _value(input),
        );
        expect(result.text, '09:30', reason: input);
      }
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

    test('ignores a 12th typed digit', () {
      final full = _type(formatter, '51999999999');
      final result = formatter.formatEditUpdate(full, _value('${full.text}1'));

      expect(result.text, '(51) 99999-9999');
    });

    test('ignores a 12th typed digit with area code 55', () {
      final full = _type(formatter, '55999999999');
      final result = formatter.formatEditUpdate(full, _value('${full.text}1'));

      expect(result.text, '(55) 99999-9999');
    });

    test('typing +55 key by key keeps it raw, then drops the country code', () {
      expect(_type(formatter, '+').text, '+');
      expect(_type(formatter, '+5551').text, '+5551');
      expect(_type(formatter, '+555199999888').text, '(51) 9999-9888');

      final result = _type(formatter, '+5551999998888');
      expect(result.text, '(51) 99999-8888');
      expect(result.selection.extentOffset, result.text.length);
    });

    test('delete in front of the leading + keeps every digit', () {
      final result = _delete(formatter, _value('+5551', 0));

      expect(result.text, '(55) 51');
      expect(result.selection.extentOffset, 0);
    });

    test('editing in the middle of a + number keeps the cursor there', () {
      final result = formatter.formatEditUpdate(
        _value('+5551', 3),
        _value('+55751', 4),
      );

      expect(result.text, '+55751');
      expect(result.selection.extentOffset, 4);

      final deleted = _backspace(formatter, _value('+55751', 4));
      expect(deleted.text, '+5551');
      expect(deleted.selection.extentOffset, 3);
    });

    test('typing digits without + never goes past 11', () {
      final result = _type(formatter, '5551999998888');

      expect(result.text, '(55) 51999-9988');
    });

    test('pasting +55 or a carrier zero over a full number replaces it', () {
      const full = TextEditingValue(
        text: '(51) 99999-9999',
        selection: TextSelection(baseOffset: 0, extentOffset: 15),
      );
      for (final input in ['+55 51 98888-7777', '051 98888-7777']) {
        final result = formatter.formatEditUpdate(full, _value(input));
        expect(result.text, '(51) 98888-7777', reason: input);
      }
    });

    test('replacing a selection in a full number is not rejected', () {
      const full = TextEditingValue(
        text: '(51) 99999-9999',
        selection: TextSelection(baseOffset: 5, extentOffset: 6),
      );
      final result = formatter.formatEditUpdate(
        full,
        _value('(51) 889999-9999', 7),
      );

      expect(result.text, '(51) 88999-9999');
      expect(result.selection.extentOffset, 7);
    });

    test('pasting a full number after partial input uses only the paste', () {
      final partial = _type(formatter, '519');
      final result = formatter.formatEditUpdate(
        partial,
        _value('${partial.text}+55 51 99999-9999'),
      );

      expect(result.text, '(51) 99999-9999');
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

    test('does not pad phone groups when a separator is typed', () {
      expect(_type(formatter, '5 ').text, '(5');
    });

    test('pasting drops the +55 country code and the carrier zero', () {
      const pasted = {
        '+55 51 99999-9999': '(51) 99999-9999',
        '+55 51 3333-3333': '(51) 3333-3333',
        '051 99999-9999': '(51) 99999-9999',
        '051 3333-3333': '(51) 3333-3333',
      };
      pasted.forEach((input, text) {
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          _value(input),
        );
        expect(result.text, text, reason: input);
        expect(result.selection.extentOffset, text.length, reason: input);
      });
    });

    test('delete before the hyphen removes the digit after it', () {
      final result = _delete(formatter, _value('(51) 99999-8888', 10));

      expect(result.text, '(51) 9999-9888');
      expect(result.selection.extentOffset, 11);
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
      expect(formatter.format('051999999999'), '(51) 99999-9999');
    });
  });
}
