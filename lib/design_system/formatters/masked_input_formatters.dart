import 'package:flutter/services.dart';

abstract class MaskedDigitsInputFormatter extends TextInputFormatter {
  const MaskedDigitsInputFormatter();

  int get maxDigits;

  String maskFor(int digitCount);

  bool get padsShortGroups => false;

  String normalizeDigits(String digits) => digits;

  bool isComplete(String digits) => digits.length == maxDigits;

  String format(String raw) {
    final digits = normalizeDigits(_groupedDigits(raw));
    return _applyMask(
      digits.length > maxDigits ? digits.substring(0, maxDigits) : digits,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final edit = _Edit.between(
      oldValue.text,
      newValue.text,
      oldValue.selection,
    );
    return edit.inserted.isEmpty
        ? _onDelete(oldValue, newValue, edit)
        : _onInsert(oldValue, edit);
  }

  TextEditingValue _onDelete(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    _Edit edit,
  ) {
    var digits = _digitsOf(newValue.text);
    final cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, newValue.text.length)
        : edit.start;
    var digitsBeforeCursor = _digitsOf(
      newValue.text.substring(0, cursor),
    ).length;

    final removed = oldValue.text.substring(edit.start, edit.oldEnd);
    if (removed.isNotEmpty && _digitsOf(removed).isEmpty) {
      if (!oldValue.selection.isCollapsed) {
        return oldValue.copyWith(
          selection: TextSelection.collapsed(offset: oldValue.selection.start),
        );
      }
      final isBackspace = cursor < oldValue.selection.extentOffset;
      if (isBackspace) {
        if (digitsBeforeCursor > 0 && digitsBeforeCursor < digits.length) {
          digits =
              digits.substring(0, digitsBeforeCursor - 1) +
              digits.substring(digitsBeforeCursor);
          digitsBeforeCursor--;
        }
      } else if (digitsBeforeCursor < digits.length) {
        digits =
            digits.substring(0, digitsBeforeCursor) +
            digits.substring(digitsBeforeCursor + 1);
      }
    }

    return _masked(digits, digitsBeforeCursor);
  }

  TextEditingValue _onInsert(TextEditingValue oldValue, _Edit edit) {
    final inserted = edit.inserted;
    final before = _digitsOf(oldValue.text.substring(0, edit.start));
    final after = _digitsOf(oldValue.text.substring(edit.oldEnd));

    if (padsShortGroups &&
        inserted.length == 1 &&
        !_isDigit(inserted.codeUnitAt(0)) &&
        after.isEmpty) {
      final digits = _padCurrentGroup(before);
      if (_endsGroup(digits.length)) {
        final formatted = _applyMask(digits, withTrailingSeparator: true);
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      return _masked(digits, digits.length);
    }

    final isBulk = inserted.length > 1;
    final insertedDigits = isBulk && before.isEmpty
        ? _groupedDigits(inserted)
        : _digitsOf(inserted);

    if (isBulk) {
      final alone = normalizeDigits(insertedDigits);
      if (isComplete(alone)) return _masked(alone, alone.length);
    }

    final raw = before + insertedDigits + after;
    var digits = normalizeDigits(raw);
    final digitsBeforeCursor =
        before.length + insertedDigits.length - (raw.length - digits.length);

    if (digits.length > maxDigits) {
      final isPureInsertion =
          oldValue.selection.isCollapsed && edit.start == edit.oldEnd;
      if (isPureInsertion && _digitsOf(oldValue.text).length >= maxDigits) {
        return oldValue;
      }
      digits = digits.substring(0, maxDigits);
    }

    return _masked(digits, digitsBeforeCursor);
  }

  TextEditingValue _masked(String digits, int digitsBeforeCursor) {
    final formatted = _applyMask(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(
          formatted,
          digitsBeforeCursor.clamp(0, digits.length),
        ),
      ),
    );
  }

  String _groupedDigits(String text) {
    final pieces = text
        .split(RegExp(r'\D+'))
        .where((piece) => piece.isNotEmpty)
        .toList();
    if (!padsShortGroups || pieces.length < 2) return _digitsOf(text);

    final groups = _groupSizes(maskFor(maxDigits));
    final buffer = StringBuffer();
    for (var i = 0; i < pieces.length; i++) {
      final padded =
          i < groups.length - 1 && groups[i] == 2 && pieces[i].length == 1;
      buffer.write(padded ? '0${pieces[i]}' : pieces[i]);
    }
    return buffer.toString();
  }

  String _padCurrentGroup(String digits) {
    final groups = _groupSizes(maskFor(digits.length));
    var groupStart = 0;
    for (var i = 0; i < groups.length - 1; i++) {
      final inGroup = digits.length - groupStart;
      if (inGroup < groups[i]) {
        return inGroup == 1 && groups[i] == 2
            ? '${digits.substring(0, groupStart)}0${digits.substring(groupStart)}'
            : digits;
      }
      groupStart += groups[i];
    }
    return digits;
  }

  bool _endsGroup(int digitCount) {
    final groups = _groupSizes(maskFor(digitCount));
    var boundary = 0;
    for (var i = 0; i < groups.length - 1; i++) {
      boundary += groups[i];
      if (boundary == digitCount) return true;
    }
    return false;
  }

  static List<int> _groupSizes(String mask) => RegExp(
    '#+',
  ).allMatches(mask).map((match) => match.end - match.start).toList();

  String _applyMask(String digits, {bool withTrailingSeparator = false}) {
    final mask = maskFor(digits.length);
    final buffer = StringBuffer();
    var index = 0;
    for (final char in mask.split('')) {
      if (char == '#') {
        if (index >= digits.length) break;
        buffer.write(digits[index++]);
      } else {
        if (index >= digits.length && !withTrailingSeparator) break;
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  static String _digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  static int _offsetAfterDigits(String text, int digitCount) {
    if (digitCount <= 0) return 0;
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      if (_isDigit(text.codeUnitAt(i)) && ++seen == digitCount) return i + 1;
    }
    return text.length;
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;
}

class _Edit {
  const _Edit(this.start, this.oldEnd, this.inserted);

  factory _Edit.between(
    String oldText,
    String newText,
    TextSelection oldSelection,
  ) {
    if (oldSelection.isValid && oldSelection.end <= oldText.length) {
      final start = oldSelection.start;
      final end = oldSelection.end;
      final tail = oldText.substring(end);
      if (newText.length >= start + tail.length &&
          newText.startsWith(oldText.substring(0, start)) &&
          newText.endsWith(tail)) {
        return _Edit(
          start,
          end,
          newText.substring(start, newText.length - tail.length),
        );
      }
    }

    final maxPrefix = oldText.length < newText.length
        ? oldText.length
        : newText.length;
    var prefix = 0;
    while (prefix < maxPrefix &&
        oldText.codeUnitAt(prefix) == newText.codeUnitAt(prefix)) {
      prefix++;
    }
    var suffix = 0;
    while (suffix < maxPrefix - prefix &&
        oldText.codeUnitAt(oldText.length - 1 - suffix) ==
            newText.codeUnitAt(newText.length - 1 - suffix)) {
      suffix++;
    }
    return _Edit(
      prefix,
      oldText.length - suffix,
      newText.substring(prefix, newText.length - suffix),
    );
  }

  final int start;
  final int oldEnd;
  final String inserted;
}

class DateInputFormatter extends MaskedDigitsInputFormatter {
  const DateInputFormatter();

  @override
  int get maxDigits => 8;

  @override
  bool get padsShortGroups => true;

  @override
  String maskFor(int digitCount) => '##/##/####';
}

class TimeInputFormatter extends MaskedDigitsInputFormatter {
  const TimeInputFormatter();

  @override
  int get maxDigits => 4;

  @override
  bool get padsShortGroups => true;

  @override
  String maskFor(int digitCount) => '##:##';
}

class PhoneInputFormatter extends MaskedDigitsInputFormatter {
  const PhoneInputFormatter();

  @override
  int get maxDigits => 11;

  @override
  String maskFor(int digitCount) =>
      digitCount > 10 ? '(##) #####-####' : '(##) ####-####';

  @override
  bool isComplete(String digits) => digits.length == 10 || digits.length == 11;

  // 12 ou 13 dígitos começando com 55 são DDI. Com 11 ou menos, 55 é DDD
  // (Santa Maria/RS) e fica.
  @override
  String normalizeDigits(String digits) {
    if (digits.startsWith('55') &&
        (digits.length == 12 || digits.length == 13)) {
      return digits.substring(2);
    }
    if (digits.startsWith('0') &&
        (digits.length == 11 || digits.length == 12)) {
      return digits.substring(1);
    }
    return digits;
  }
}
