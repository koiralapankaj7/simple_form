import 'package:flutter/services.dart';
import 'package:simple_utils/simple_utils.dart';

///
typedef ValueRange = (num min, num max);

///
abstract class SimpleInputFormatter {
  /// Length limiting input formatter which will only accept value for
  /// given [size]
  // static TextInputFormatter length(int size) => TextInputFormatter.withFunction(
  //       (oldValue, newValue) =>
  //           newValue.text.length <= size ? newValue : oldValue,
  //     );
  static TextInputFormatter enforcedLength(int size) =>
      LengthLimitingTextInputFormatter(
        size,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
      );

  ///
  static TextInputFormatter enforcedRange(ValueRange range) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final enteredValue = num.tryParse(newValue.text);
      if (enteredValue == null ||
          enteredValue < range.$1 ||
          enteredValue > range.$2) {
        return oldValue;
      }
      return newValue;
    });
  }

  ///
  static TextInputFormatter enforcedDecimalPlace(int length) =>
      FilteringTextInputFormatter.allow(
        RegExp('^\\d+\\.?\\d{0,$length}'),
      );

  ///
  ///     Symbol    Meaning                Presentation       Example
  ///     ------    -------                ------------       -------
  ///     yyyy      year                   (Number)           1996
  ///     MM        month in year          (Number)           07
  ///     dd        day in month           (Number)           10
  ///     HH        hour in day (0~23)     (Number)           0
  ///     mm        minute in hour         (Number)           30
  ///     ss        second in minute       (Number)           55
  ///
  /// yyyy-MM-ddTHH:mm:ss, this will be the converted format
  ///
  /// `M` and `m` is case sensitive, uppercase refers to Month and lowercase
  /// refers to minute
  static TextInputFormatter enforcedDateFormat({String? format}) =>
      DateInputFormatter(format: format);

  ///
  static TextInputFormatter creditCard({
    int length = 16,
    int chunkSize = 4,
    String separator = ' ',
  }) =>
      CreditCardNumberInputFormatter(
        length: length,
        chunkSize: chunkSize,
        separator: separator,
      );
}

///
const defaultDateFormat = 'dd/MM/yyyy';

///
class _DateValue {
  _DateValue({
    required this.symbol,
    required this.delimiter,
  });

  final String symbol;
  final String delimiter;

  /// Actual date value
  String _value = '';

  void _setVal(String value) {
    if (value == _value) return;
    _value = value;
  }

  ///
  String get format => '${symbol.casedFromBase}$delimiter';

  int get length => symbol.length + delimiter.length;

  bool get isValid => _value.length == symbol.length;
}

///
///     Symbol    Meaning                Presentation       Example
///     ------    -------                ------------       -------
///     yy        year                   (Number)           1996
///     Mm        month in year          (Number)           07
///     dd        day in month           (Number)           10
///     hH        hour in day (0~23)     (Number)           0
///     mM        minute in hour         (Number)           30
///     ss        second in minute       (Number)           55
///
/// yyyy-MM-ddTHH:mm:ss, this will be the converted format
///
/// `M` and `m` is case sensitive, uppercase refers to Month and lowercase
/// refers to minute
class DateInputFormatter extends TextInputFormatter {
  ///
  DateInputFormatter({String? format}) {
    _map = _processFormat(format ?? defaultDateFormat);
  }

  // late final List<_DateValue> _items;
  late final Map<String, _DateValue> _map;

  ///
  late final String format =
      _map.entries.fold('', (pv, e) => '$pv${e.value.format}');

  ///
  late final _strLength = _map.values.fold(0, (pv, e) => pv + e.length);

  /// Get [DateTime] from the current state
  DateTime? get dateTime {
    if (_map.isEmpty) return null;
    try {
      var year = 0;
      var month = 1;
      var day = 1;
      var hour = 0;
      var minute = 0;
      var second = 0;

      if (_map['y'] ?? _map['Y'] case final _DateValue dateField) {
        if (!dateField.isValid) return null;
        year = dateField._value.toYear;
      }

      if (_map['M'] case final _DateValue dateField) {
        if (!dateField.isValid) return null;
        month = int.parse(dateField._value);
      }

      if (_map['d'] ?? _map['D'] case final _DateValue dateField) {
        if (!dateField.isValid) return null;
        day = int.parse(dateField._value);
      }

      if (_map['h'] ?? _map['H'] case final _DateValue dateField) {
        if (!dateField.isValid) return null;
        hour = int.parse(dateField._value);
      }

      if (_map['m'] case final _DateValue dateField) {
        if (!dateField.isValid) return null;
        minute = int.parse(dateField._value);
      }

      if (_map['s'] ?? _map['S'] case final _DateValue dateField) {
        if (!dateField.isValid) return null;
        second = int.parse(dateField._value);
      }

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      // In case of parsing errors
      return null;
    }
  }

  /// Convert [dateTime] to current [format]
  String dateString(DateTime dateTime) {
    if (_map.isEmpty) return '';

    final strBuffer = StringBuffer();
    for (final MapEntry(:key, :value) in _map.entries) {
      final symbolLength = value.symbol.length;
      final dateValue = switch (key) {
        'y' || 'Y' => () {
            final year = '${dateTime.year}';
            final diff = year.length - symbolLength;
            if (diff.isNegative) {
              return year;
            }
            return year.substring(year.length - symbolLength);
          }(),
        'M' => '${dateTime.month}',
        'd' || 'D' => '${dateTime.day}',
        'h' || 'H' => '${dateTime.hour}',
        'm' => '${dateTime.minute}',
        's' || 'S' => '${dateTime.second}',
        _ => null,
      };

      if (dateValue != null) {
        strBuffer
            .write('${dateValue.padLeft(symbolLength, '0')}${value.delimiter}');
      }
    }

    return strBuffer.toString();
  }

  ///
  Map<String, _DateValue> _processFormat(String format) {
    final regExp = RegExp(
      r'\b(y{1,4}|M{1,2}|d{1,2}|H{1,2}|m{1,2}|s{1,2})(\W?)\b',
      caseSensitive: false,
    );
    final matches = regExp.allMatches(format.replaceFirst('T', ' '));
    final map = <String, _DateValue>{};
    for (final (index, match) in matches.indexed) {
      final text = match.group(1);
      if (text != null && !text.containsSameChar) continue;
      final key = text![0];
      if (map.containsKey(key)) {
        map.remove(key);
      }
      map[key] = _DateValue(
        symbol: text,
        delimiter: index == matches.length - 1 ? '' : match.group(2) ?? '',
      );
    }
    return map;
  }

  /// Converts the input string to the specified format.
  ///
  /// [value] - The input string to format.
  /// [delete] - A flag indicating whether the last action was a deletion.
  String _convert(String value, bool delete) {
    // Remove non-numeric characters and format the new text
    final string = value.replaceAll(RegExp('[^0-9]'), '');
    final buffer = StringBuffer();
    var start = 0;

    for (final item in _map.values) {
      final end = start + item.symbol.length;

      // Append the substring of the input that corresponds
      // to the current format component
      if (string.length < end) {
        final val = string.substring(start);
        buffer.write(val);
        item._setVal(val);
        break;
      }

      final val = string.substring(start, end);
      buffer.write(val);
      item._setVal(val);
      // Append the delimiter if not deleting or
      // if the string is longer than the current component
      if (!delete || string.length > end) {
        buffer.write(item.delimiter);
      }

      start = end;
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // final length = newValue.text.length;
    // if (length > _strLength) return oldValue;

    // Prevents the formatted text from exceeding the defined format length
    if (oldValue.text.isNotEmpty && newValue.text.length > _strLength) {
      return oldValue;
    }

    final newText = _convert(
      newValue.text,
      oldValue.text.length > newValue.text.length,
    );
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

///
class CreditCardNumberInputFormatter extends TextInputFormatter {
  ///
  const CreditCardNumberInputFormatter({
    this.length = 16,
    this.chunkSize = 4,
    this.separator = ' ',
  });

  /// Length of the card number, default to 16
  final int length;

  /// Number chunk size to add [separator], default to 4
  final int chunkSize;

  /// Character to use as a separator between formatted value
  final String separator;

  int _calculateMaxLength() {
    // Calculates the total length accounting for separators
    return length + (separator.isEmpty ? 0 : (length / chunkSize).ceil() - 1);
  }

  String _formatDigits(String text) {
    // Remove any existing formatting characters
    final digits = text.replaceAll(RegExp(r'\D'), '');
    // Chunk the string and join with separator
    final chunks = digits.chunks(chunkSize);
    return chunks.join(separator);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final maxLength = _calculateMaxLength();

    if (newValue.text.length > maxLength) return oldValue;

    final formatted = _formatDigits(newValue.text);

    // Calculate new cursor position
    final cursorIndex = newValue.selection.end;
    final offset = cursorIndex == formatted.length
        ? formatted.length
        : _calculateOffset(newValue.text, formatted, cursorIndex);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

//
  int _calculateOffset(
    String original,
    String formatted,
    int originalCursorPos,
  ) {
    if (originalCursorPos <= 0) {
      // Cursor at the start
      return 0;
    }

    final nonDigitsBeforeCursor = RegExp(r'\D')
        .allMatches(original.substring(0, originalCursorPos))
        .length;
    var newCursorPos = originalCursorPos - nonDigitsBeforeCursor;

    for (var i = 0; i < newCursorPos && i < formatted.length; i++) {
      if (formatted[i] == separator) {
        newCursorPos++;
      }
    }

    return newCursorPos;
  }
}

// ///
// class ExpiryDateInputFormatter extends TextInputFormatter {
//   ///
//   const ExpiryDateInputFormatter();

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.length > 7) return oldValue;

//     var newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

//     if (newText.length > 2) {
//       newText = '${newText.substring(0, 2)}/${newText.substring(2)}';
//     }

//     return TextEditingValue(
//       text: newText,
//       selection: TextSelection.collapsed(offset: newText.length),
//     );
//   }
// }
