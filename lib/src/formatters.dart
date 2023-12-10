import 'package:flutter/services.dart';

///
typedef ValueRange = (num min, num max);

///
class RangeLimitingTextInputFormatter extends TextInputFormatter {
  ///
  const RangeLimitingTextInputFormatter({
    required this.range,
  });

  ///
  final ValueRange range;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final enteredValue = num.tryParse(newValue.text);
    if (enteredValue != null) {
      if (enteredValue < range.$1 || enteredValue > range.$2) {
        // Value is outside the desired range; return the old value.
        return oldValue;
      }
    }

    return newValue;
  }
}

///
class DateString {
  ///
  DateString(this.key, this.text, this.delimiter);

  ///
  final String key;

  ///
  final String text;

  ///
  final String? delimiter;

  ///
  int get length => text.length + (delimiter != null ? 1 : 0);
}

/// DD/MM/YYYY
class DateInputFormatter extends TextInputFormatter {
  ///
  DateInputFormatter({
    this.format = 'dd/mm/yyyy',
  }) {
    _init();
  }

  ///
  final String format;

  final _items = <DateString>[];

  String _convert(String string, bool delete) {
    final strBuffer = StringBuffer();
    var start = 0;
    for (final item in _items) {
      final end = item.text.length + start;

      if (string.length < end) {
        strBuffer.write(string.substring(start));
        return strBuffer.toString();
      }

      if (string.length == end && delete) {
        strBuffer.write(string.substring(start, end));
        return strBuffer.toString();
      }

      if (string.length >= end) {
        strBuffer.write(string.substring(start, end));
        if (item.delimiter != null) {
          strBuffer.write(item.delimiter);
        }
        start = end;
      }
    }
    return strBuffer.toString();
  }

  void _init() {
    final regExp = RegExp('([A-Za-z]+)([^A-Za-z]?)');
    final matches = regExp.allMatches(format);
    for (final match in matches) {
      final text = match.group(1);
      if (text?.isEmpty ?? true) continue;
      final key = text!.toLowerCase().split('').toSet();
      if (key.length == 1) {
        _items.add(DateString(key.first, text, match.group(2)));
      }
    }

    // // Assign default format if it is invalid
    // if (_items.length < 2 ||
    //     _items.firstWhereOrNull((e) => e.key == 'y') == null) {
    //   _items = _defaultDate;
    // }
  }

  late final _strLength = _items.fold(0, (pv, e) => pv + e.length);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final length = newValue.text.length;
    if (length > _strLength) return oldValue;

    // Support 0-9
    var newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    newText = _convert(newText, oldValue.text.length > newValue.text.length);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
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
