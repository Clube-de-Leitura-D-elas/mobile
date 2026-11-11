import 'package:flutter/services.dart';

abstract class MaskedDigitsInputFormatter extends TextInputFormatter {
  const MaskedDigitsInputFormatter();

  int get maxDigits;

  String maskFor(int digitCount);

  bool get padsShortGroups => false;

  String normalizeDigits(String digits) => digits;

  String format(String raw) {
    final digits = normalizeDigits(_digitsOf(raw));
    return _applyMask(
      digits.length > maxDigits ? digits.substring(0, maxDigits) : digits,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = _digitsOf(oldValue.text);
    final rawDigits = _digitsOf(newValue.text);

    if (rawDigits.length > maxDigits && oldDigits.length >= maxDigits) {
      return oldValue;
    }

    final cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    var digitsBeforeCursor = _digitsOf(
      newValue.text.substring(0, cursor),
    ).length;

    var digits = normalizeDigits(rawDigits);
    digitsBeforeCursor -= rawDigits.length - digits.length;
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    digitsBeforeCursor = digitsBeforeCursor.clamp(0, digits.length);

    final removedOnlySeparator =
        digits == oldDigits && newValue.text.length < oldValue.text.length;
    if (removedOnlySeparator) {
      final isBackspace =
          oldValue.selection.isCollapsed &&
          cursor < oldValue.selection.extentOffset;
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

    var showTrailingSeparator = false;
    if (_appendedSeparator(oldValue, newValue, cursor)) {
      digits = _padCurrentGroup(digits);
      digitsBeforeCursor = digits.length;
      showTrailingSeparator = _endsGroup(digits.length);
    }

    final formatted = _applyMask(
      digits,
      withTrailingSeparator: showTrailingSeparator,
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: showTrailingSeparator
            ? formatted.length
            : _offsetAfterDigits(formatted, digitsBeforeCursor),
      ),
    );
  }

  bool _appendedSeparator(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    int cursor,
  ) {
    final text = newValue.text;
    return padsShortGroups &&
        text.length == oldValue.text.length + 1 &&
        cursor == text.length &&
        text.startsWith(oldValue.text) &&
        !_isDigit(text.codeUnitAt(text.length - 1));
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

  // O 55 só sai com 12 ou 13 dígitos: 55 também é DDD (Santa Maria/RS), e um
  // número com esse DDD tem no máximo 11.
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
