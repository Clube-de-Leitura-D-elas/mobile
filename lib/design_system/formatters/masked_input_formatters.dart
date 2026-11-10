import 'package:flutter/services.dart';

/// Formats digit-only input with a mask where `#` is a digit slot and any
/// other character is a literal separator.
abstract class MaskedDigitsInputFormatter extends TextInputFormatter {
  const MaskedDigitsInputFormatter();

  int get maxDigits;

  String maskFor(int digitCount);

  /// Formats a raw value (e.g. a prefilled one) with the same rules applied
  /// while typing.
  String format(String raw) {
    final digits = _digitsOf(raw);
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
    var digits = _digitsOf(newValue.text);

    if (digits.length > maxDigits) {
      if (oldDigits.length >= maxDigits) return oldValue;
      digits = digits.substring(0, maxDigits);
    }

    final cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    var digitsBeforeCursor = _digitsOf(
      newValue.text.substring(0, cursor),
    ).length.clamp(0, digits.length);

    final removedOnlySeparator =
        digits == oldDigits && newValue.text.length < oldValue.text.length;
    if (removedOnlySeparator && digitsBeforeCursor > 0) {
      digits =
          digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor--;
    }

    final formatted = _applyMask(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetAfterDigits(formatted, digitsBeforeCursor),
      ),
    );
  }

  String _applyMask(String digits) {
    final mask = maskFor(digits.length);
    final buffer = StringBuffer();
    var index = 0;
    for (final char in mask.split('')) {
      if (index >= digits.length) break;
      if (char == '#') {
        buffer.write(digits[index++]);
      } else {
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

/// Date mask `dd/MM/yyyy`.
class DateInputFormatter extends MaskedDigitsInputFormatter {
  const DateInputFormatter();

  @override
  int get maxDigits => 8;

  @override
  String maskFor(int digitCount) => '##/##/####';
}

/// Time mask `HH:mm`.
class TimeInputFormatter extends MaskedDigitsInputFormatter {
  const TimeInputFormatter();

  @override
  int get maxDigits => 4;

  @override
  String maskFor(int digitCount) => '##:##';
}

/// Brazilian phone mask with area code: `(51) 3333-3333` for landlines and
/// `(51) 99999-9999` for mobiles.
class PhoneInputFormatter extends MaskedDigitsInputFormatter {
  const PhoneInputFormatter();

  @override
  int get maxDigits => 11;

  @override
  String maskFor(int digitCount) =>
      digitCount > 10 ? '(##) #####-####' : '(##) ####-####';

  /// Also drops a leading `55` country code from stored values such as
  /// `+55 51 99999-9999`. Not done while typing: 55 is a valid area code.
  @override
  String format(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final hasCountryCode =
        digits.startsWith('55') && (digits.length == 12 || digits.length == 13);
    return super.format(hasCountryCode ? digits.substring(2) : digits);
  }
}
