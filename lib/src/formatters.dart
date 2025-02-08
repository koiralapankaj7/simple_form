import 'dart:math' as math;
import 'package:flutter/services.dart';

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

///
class ExpiryDateInputFormatter extends TextInputFormatter {
  ///
  const ExpiryDateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > 7) return oldValue;

    var newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (newText.length > 2) {
      newText = '${newText.substring(0, 2)}/${newText.substring(2)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// class DateFormatInputFormatter extends TextInputFormatter {
//   DateFormatInputFormatter(this.dateFormat) {
//     _parsePattern();
//   }

//   final DateFormat dateFormat;
//   late final List<String> components;
//   late final List<String> separators;
//   late final List<int> componentLengths;

//   void _parsePattern() {
//     String pattern = dateFormat.pattern!;
//     List<String> tokens = _splitPattern(pattern);
//     components = [];
//     separators = [];
//     StringBuffer currentSeparator = StringBuffer();

//     for (String token in tokens) {
//       if (_isComponent(token)) {
//         components.add(token);
//         if (components.length > 1) {
//           separators.add(currentSeparator.toString());
//           currentSeparator.clear();
//         }
//       } else {
//         currentSeparator.write(token);
//       }
//     }

//     // Add the last separator if there is any
//     if (currentSeparator.isNotEmpty) {
//       separators.add(currentSeparator.toString());
//     }

//     componentLengths = components.map((c) => c.length).toList();
//   }

//   List<String> _splitPattern(String pattern) {
//     RegExp exp = RegExp(r'([a-zA-Z]+)|([^a-zA-Z]+)');
//     Iterable<Match> matches = exp.allMatches(pattern);
//     List<String> tokens = [];
//     for (Match m in matches) {
//       String token = m.group(0)!;
//       tokens.add(token);
//     }
//     return tokens;
//   }

//   bool _isComponent(String token) {
//     if (token.isEmpty) return false;
//     return token[0].contains(RegExp(r'[a-zA-Z]'));
//   }

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) return newValue;

//     // Get clean digits and previous digits
//     final String oldText = oldValue.text;
//     final String newText = newValue.text;

//     final String oldDigits = oldText.replaceAll(RegExp(r'[^0-9]'), '');
//     final String newDigits = newText.replaceAll(RegExp(r'[^0-9]'), '');

//     // Calculate actual inserted/deleted digits
//     final int digitsBefore =
//         _countDigitsUpTo(oldText, oldValue.selection.start);
//     final int digitsAfter = _countDigitsUpTo(newText, newValue.selection.start);
//     final int digitDifference = digitsAfter - digitsBefore;

//     // Build formatted text
//     final formatted = _formatDigits(newDigits);
//     if (formatted == newValue.text) return newValue;

//     // Calculate new cursor position
//     int newOffset = _calculateCursorPosition(
//       formatted,
//       newDigits,
//       digitsBefore + digitDifference,
//     );

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: newOffset),
//     );
//   }

//   // String _formatDigits(String digits) {
//   //   final buffer = StringBuffer();
//   //   int start = 0;

//   //   for (int i = 0; i < components.length; i++) {
//   //     if (start >= digits.length) break;

//   //     final end = start + componentLengths[i];
//   //     final part = digits.substring(start, end.clamp(start, digits.length));
//   //     buffer.write(part);

//   //     if (i < separators.length && part.length == componentLengths[i]) {
//   //       buffer.write(separators[i]);
//   //     }

//   //     start = end;
//   //   }

//   //   return buffer.toString().replaceAll(RegExp(r'\D$'), '');
//   // }

//   String _formatDigits(String digits) {
//     final buffer = StringBuffer();
//     int start = 0;

//     // Calculate maximum allowed digits based on pattern
//     final maxDigits = componentLengths.reduce((a, b) => a + b);
//     final trimmedDigits =
//         digits.length > maxDigits ? digits.substring(0, maxDigits) : digits;

//     for (int i = 0; i < components.length; i++) {
//       if (start >= trimmedDigits.length) break;

//       final end = start + componentLengths[i];
//       final part = trimmedDigits.substring(
//           start, end.clamp(start, trimmedDigits.length));
//       buffer.write(part);

//       if (i < separators.length && part.length == componentLengths[i]) {
//         buffer.write(separators[i]);
//       }

//       start = end;
//     }

//     return buffer.toString().replaceAll(RegExp(r'\D$'), '');
//   }

//   int _calculateCursorPosition(
//       String formatted, String digits, int targetDigits) {
//     int digitCount = 0;
//     int cursorPos = 0;

//     while (cursorPos < formatted.length && digitCount < targetDigits) {
//       if (formatted.codeUnitAt(cursorPos) >= 48 &&
//           formatted.codeUnitAt(cursorPos) <= 57) {
//         digitCount++;
//       }
//       cursorPos++;
//     }

//     // Skip over next separator if needed
//     if (cursorPos < formatted.length &&
//         !isDigit(formatted[cursorPos]) &&
//         digitCount == digits.length) {
//       cursorPos++;
//     }

//     return cursorPos;
//   }

//   int _countDigitsUpTo(String text, int offset) {
//     int count = 0;
//     for (int i = 0; i < offset && i < text.length; i++) {
//       if (isDigit(text[i])) {
//         count++;
//       }
//     }
//     return count;
//   }

//   bool isDigit(String s) {
//     if (s.isEmpty) return false;
//     return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
//   }
// }

// class DateFormatInputFormatter extends TextInputFormatter {
//   DateFormatInputFormatter(this.dateFormat) {
//     _parsePattern();
//   }

//   final DateFormat dateFormat;
//   late final List<String> components;
//   late final List<String> separators;
//   late final List<int> componentLengths;

//   void _parsePattern() {
//     String pattern = dateFormat.pattern!;
//     List<String> tokens = _splitPattern(pattern);
//     components = [];
//     separators = [];
//     StringBuffer currentSeparator = StringBuffer();

//     for (String token in tokens) {
//       if (_isComponent(token)) {
//         components.add(token);
//         if (components.length > 1) {
//           separators.add(currentSeparator.toString());
//           currentSeparator.clear();
//         }
//       } else {
//         currentSeparator.write(token);
//       }
//     }

//     componentLengths = components.map((c) => c.length).toList();
//   }

//   List<String> _splitPattern(String pattern) {
//     RegExp exp = RegExp(r'([a-zA-Z]+)|([^a-zA-Z]+)');
//     Iterable<Match> matches = exp.allMatches(pattern);
//     List<String> tokens = [];
//     for (Match m in matches) {
//       String token = m.group(0)!;
//       tokens.add(token);
//     }
//     return tokens;
//   }

//   bool _isComponent(String token) {
//     if (token.isEmpty) return false;
//     return token[0].contains(RegExp(r'[a-zA-Z]'));
//   }

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     String newText = newValue.text;
//     String digits = newText.replaceAll(RegExp(r'[^0-9]'), '');
//     List<String> groups = [];
//     int start = 0;

//     for (int length in componentLengths) {
//       if (start >= digits.length) break;
//       int end = start + length;
//       end = end.clamp(start, digits.length);
//       groups.add(digits.substring(start, end));
//       start = end;
//     }

//     StringBuffer formattedText = StringBuffer();
//     for (int i = 0; i < groups.length; i++) {
//       formattedText.write(groups[i]);
//       if (i < separators.length && i < groups.length - 1) {
//         formattedText.write(separators[i]);
//       }
//     }

//     String formattedString = formattedText.toString();

//     int originalDigitCount =
//         _countDigitsUpTo(newValue.text, newValue.selection.extentOffset);
//     int newOffset = _calculateNewOffset(formattedString, originalDigitCount);

//     return TextEditingValue(
//       text: formattedString,
//       selection: TextSelection.collapsed(offset: newOffset),
//     );
//   }

//   int _countDigitsUpTo(String text, int offset) {
//     int count = 0;
//     for (int i = 0; i < offset && i < text.length; i++) {
//       if (isDigit(text[i])) {
//         count++;
//       }
//     }
//     return count;
//   }

//   int _calculateNewOffset(String formattedText, int originalDigitCount) {
//     int newOffset = 0;
//     int currentDigitCount = 0;
//     while (newOffset < formattedText.length &&
//         currentDigitCount < originalDigitCount) {
//       if (isDigit(formattedText[newOffset])) {
//         currentDigitCount++;
//       }
//       newOffset++;
//     }
//     return newOffset;
//   }

//   bool isDigit(String s) {
//     if (s.isEmpty) return false;
//     return s.codeUnitAt(0) >= 48 && s.codeUnitAt(0) <= 57;
//   }
// }

extension on String {
  /// Returns true if all characters in the string are in lower case.
  bool get isLower => toLowerCase() == this;

  // /// Returns true if all characters in the string are in upper case.
  // bool get isUpper => toUpperCase() == this;

  /// Converts string to lowerCase/upperCase based on the first character (base).
  /// If the first character is not a letter, the original string is returned.
  String get casedFromBase {
    if (isEmpty) return '';

    // String has initial numeric value return as it is
    if (RegExp(r'^\d').hasMatch(this)) {
      return this;
    }

    return this[0].isLower ? toLowerCase() : toUpperCase();
  }

  /// Returns true if the string consists of the same character,
  /// case insensitive.
  bool get containsSameChar {
    if (trim().isEmpty) return false;
    final char = this[0].toLowerCase();
    for (var i = 1; i < length; i++) {
      if (this[i].toLowerCase() != char) return false;
    }
    return true;
  }

  /// Splits the string into chunks of the given [size].
  ///
  /// The last chunk may be shorter if the string length is not a multiple of
  /// chunk [size]
  List<String> chunks(int size) {
    if (size <= 0) return [this];
    final chunks = <String>[];
    for (var i = 0; i < length; i += size) {
      final end = math.min(i + size, length);
      chunks.add(substring(i, end));
    }
    return chunks;
  }

  /// Convert string into the year
  int get toYear {
    final input = int.tryParse(this) ?? 0;
    if (input == 0) return 0;
    final currentYear = DateTime.now().year;
    final delta = '$currentYear'.length - length;
    if (delta.isNegative) return 0;
    if (delta > 0) {
      final factor = math.pow(10, length);
      final prefix = (currentYear ~/ factor) * factor;
      return (prefix + input).toInt();
    }
    return input;
  }
}
