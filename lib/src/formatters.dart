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

    // if (newValue.text.length > maxLength) {
    //   // Input exceeds the desired length; return the old value.
    //   return oldValue;
    // }

    return newValue;
  }
}
