import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_form/simple_form.dart' hide DateInputFormatter;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  TextSpan _buildJson(
    BuildContext context,
    Map<String, dynamic> json, {
    double space = 16,
  }) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;
    final children = <TextSpan>[];
    children.add(const TextSpan(text: '{\n'));

    for (final item in json.entries) {
      final value = item.value == null ? null : '"${item.value}"';
      final span = TextSpan(
        children: [
          WidgetSpan(child: SizedBox(width: space)),
          TextSpan(
            text: '"${item.key}"',
            style: style!.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const TextSpan(text: ': '),
          TextSpan(
            text: '$value,\n',
            style: style.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
      children.add(span);
    }
    children.add(const TextSpan(text: '}\n'));
    return TextSpan(children: children);
  }

  List<Widget> _fields(BuildContext context) {
    return [
      const TextField(
        inputFormatters: [
          // PhoneTextFormatter(),
          // NumberTextFormatter(NumberFormat(",##,##0.##")),
          // DateInputFormatter(
          //   rawPattern: 'mmmm-ddddd-yyyyyyy',
          //   autoFormatDate: true,
          // ),
          // DateFormatInputFormatter(DateFormat('MM/dd/yyyy')),
        ],
      ),

      SimpleField.text(
        jsonKey: 'textField',
        isRequired: true,
      ),
      SimpleField.email(
        jsonKey: 'emailField',
        isRequired: true,
      ),
      SimpleField.number(
        jsonKey: 'numberField',
        isRequired: true,
      ),
      SimpleField.date(
        jsonKey: 'dateField',
        isRequired: true,
      ),
      SimpleField.password(
        jsonKey: 'passwordField',
        isRequired: true,
      ),
      SimpleField.pinCode(
        jsonKey: 'pinCodeField',
        isRequired: true,
      ),
      SimpleField.cardNo(
        jsonKey: 'cardNoField',
        isRequired: true,
      ),
      SimpleField.phone(
        jsonKey: 'phoneField',
        isRequired: true,
      ),
      SimpleField.address(
        jsonKey: 'addressField',
        isRequired: true,
      ),
      SimpleField.country(
        jsonKey: 'countryField',
        // isRequired: true,
      ),
      // SimpleField.dropdown<String>(
      //   labelText: "Dropdown Field",
      //   items: List.generate(5, (index) => 'Item -${index + 1}'),
      // ),
      SimpleField.boolean(
        jsonKey: 'booleanField',
      ),
    ];
  }

  Widget _buttons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          OutlinedButton(
            onPressed: SimpleForm.of(context).reset,
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () {
              if (SimpleForm.of(context).validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Validation Success'),
                  ),
                );
              }
            },
            child: const Text('Validate'),
          ),
        ],
      ),
    );
  }

  Widget _jsonView(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 400,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText.rich(
        _buildJson(context, SimpleForm.of(context).json),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SimpleForm(
          onChanged: () {
            setState(() {});
          },
          child: Builder(
            builder: (context) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              // horizontal: max(16, (width - 400) * 0.5),
                              vertical: 16,
                            ),
                            child: Column(
                              spacing: 16,
                              children: _fields(context),
                            ),
                          ),
                        ),
                        _buttons(context),
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  _jsonView(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class NumberTextFormatter extends TextInputFormatter {
  final NumberFormat format;

  NumberTextFormatter(this.format);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Strip all formatting to get raw number string
    String newText = newValue.text.replaceAll(RegExp('[^0-9.-]'), '');

    // Handle special case for negative numbers
    bool isNegative = newText.startsWith('-');
    if (isNegative) {
      newText = newText.substring(1);
    }

    // Convert to number if possible
    num? number;
    try {
      if (newText.isEmpty) return newValue;
      number = num.parse(newText);
      if (isNegative) number = -number;
    } catch (e) {
      return oldValue;
    }

    // Format the number
    String formatted = format.format(number);

    // Calculate new cursor position
    int cursorPosition = newValue.selection.end;
    int oldLength = newValue.text.length;
    int newLength = formatted.length;
    cursorPosition += newLength - oldLength;
    cursorPosition = cursorPosition.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

// class PhoneTextFormatter extends TextInputFormatter {
//   final String pattern;
//   final String separator;
//   final int maxLength;
//   final bool autoCompleteBracket;

//   // Track bracket positions
//   final int _openBracketPos;
//   final int _closeBracketPos;

//   PhoneTextFormatter({
//     this.pattern = '(XXX) XXX-XXXX',
//     this.separator = '',
//     this.maxLength = 15,
//     this.autoCompleteBracket = true,
//   })  : _openBracketPos = pattern.indexOf('('),
//         _closeBracketPos = pattern.indexOf(')');

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) return newValue;

//     String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
//     if (digitsOnly.length > maxLength) {
//       digitsOnly = digitsOnly.substring(0, maxLength);
//     }

//     var formatted = '';
//     var index = 0;
//     var bracketAdded = false;

//     // Handle first digit - add opening bracket
//     if (digitsOnly.isNotEmpty && autoCompleteBracket) {
//       formatted += '(';
//     }

//     // Format digits
//     for (var i = 0; i < pattern.length && index < digitsOnly.length; i++) {
//       if (pattern[i] == 'X') {
//         formatted += digitsOnly[index];
//         index++;

//         // Add closing bracket after 3rd digit
//         if (autoCompleteBracket &&
//             index == 3 &&
//             !bracketAdded &&
//             !formatted.contains(')')) {
//           formatted += ') ';
//           bracketAdded = true;
//         }
//       } else if (pattern[i] != '(' && pattern[i] != ')') {
//         formatted += pattern[i];
//       }
//     }

//     // Add remaining digits
//     if (index < digitsOnly.length) {
//       formatted += digitsOnly.substring(index);
//     }

//     // Calculate cursor position
//     final cursorPos = newValue.selection.end +
//         (formatted.length - newValue.text.length) +
//         (bracketAdded ? 2 : 0); // Account for ') ' addition

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(
//         offset: cursorPos.clamp(0, formatted.length),
//       ),
//     );
//   }
// }

class DateInputFormatter extends TextInputFormatter {
  final String rawPattern;
  final bool autoFormatDate;
  late final String pattern;

  DateInputFormatter({
    required this.rawPattern,
    this.autoFormatDate = false,
  }) {
    pattern = _normalizePattern(rawPattern);
  }

  String _normalizePattern(String input) {
    int mCount = 0, dCount = 0, yCount = 0;
    final buffer = StringBuffer();

    for (final char in input.split('')) {
      if (char.toLowerCase() == 'm' && mCount < 2) {
        buffer.write('M');
        mCount++;
      } else if (char.toLowerCase() == 'd' && dCount < 2) {
        buffer.write('d');
        dCount++;
      } else if (char.toLowerCase() == 'y' && yCount < 4) {
        buffer.write('y');
        yCount++;
      } else if (!RegExp(r'[mdy]', caseSensitive: false).hasMatch(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final cursorPosition = newValue.selection.start;
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return newValue;

    String month = '', day = '', year = '';
    int digitIndex = 0;
    bool monthCorrected = false, dayCorrected = false;

    // Extract digits into segments
    for (int i = 0; i < pattern.length && digitIndex < digitsOnly.length; i++) {
      final char = pattern[i];
      if (char == 'M' && month.length < 2) {
        month += digitsOnly[digitIndex++];
        // Auto-correct month instantly if > 1
        if (autoFormatDate && month.length == 1 && int.parse(month) > 1) {
          month = '0$month';
          monthCorrected = true;
        }
      } else if (char == 'd' && day.length < 2) {
        day += digitsOnly[digitIndex++];
        // Auto-correct day instantly if > 3
        if (autoFormatDate && day.length == 1 && int.parse(day) > 3) {
          day = '0$day';
          dayCorrected = true;
        }
      } else if (char == 'y') {
        year += digitsOnly[digitIndex++];
      }
    }

    // Build formatted string with separators
    final formatted = StringBuffer();
    if (month.isNotEmpty) {
      formatted.write(month);
      if ((month.length == 2 || monthCorrected) && pattern.contains('-')) {
        formatted.write('-');
      }
    }

    if (day.isNotEmpty) {
      formatted.write(day);
      if ((day.length == 2 || dayCorrected) && pattern.contains('-')) {
        formatted.write('-');
      }
    }

    if (year.isNotEmpty) {
      formatted.write(year);
    }

    // Calculate cursor position
    final formattedText = formatted.toString();
    int newOffset;

    if (monthCorrected || dayCorrected) {
      // Move cursor after correction
      newOffset = formattedText.length;
    } else {
      // Maintain relative cursor position
      int actualDigitsCount = 0;
      newOffset = 0;
      final digitsBeforeCursor = newValue.text
          .substring(0, cursorPosition)
          .replaceAll(RegExp(r'[^0-9]'), '')
          .length;

      while (newOffset < formattedText.length &&
          actualDigitsCount < digitsBeforeCursor) {
        if (RegExp(r'[0-9]').hasMatch(formattedText[newOffset])) {
          actualDigitsCount++;
        }
        newOffset++;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

// 1

// class DateInputFormatter extends TextInputFormatter {
//   DateInputFormatter({required this.rawPattern}) {
//     pattern = _fixPattern(rawPattern);
//   }
//   final String rawPattern;
//   late final String pattern;

//   String _fixPattern(String input) {
//     int mCount = 0, dCount = 0, yCount = 0;
//     final buffer = StringBuffer();
//     for (int i = 0; i < input.length; i++) {
//       final char = input[i];
//       if (char.toLowerCase() == 'm') {
//         if (mCount < 2) {
//           buffer.write('M');
//           mCount++;
//         }
//       } else if (char.toLowerCase() == 'd') {
//         if (dCount < 2) {
//           buffer.write('d');
//           dCount++;
//         }
//       } else if (char.toLowerCase() == 'y') {
//         if (yCount < 4) {
//           buffer.write('y');
//           yCount++;
//         }
//       } else {
//         buffer.write(char);
//       }
//     }
//     return buffer.toString();
//   }

//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.text.isEmpty) return newValue;

//     final cursorPosition = newValue.selection.start;
//     final digitsBeforeCursor = newValue.text
//         .substring(0, cursorPosition)
//         .replaceAll(RegExp(r'[^0-9]'), '')
//         .length;

//     final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

//     String formatted = '';
//     int digitIndex = 0;
//     for (var i = 0; i < pattern.length; i++) {
//       if (digitIndex >= digitsOnly.length) break;
//       if (RegExp(r'[dmyDMyY]').hasMatch(pattern[i])) {
//         formatted += digitsOnly[digitIndex++];
//       } else {
//         formatted += pattern[i];
//       }
//     }

//     int actualDigitsCount = 0;
//     int newOffset = 0;
//     while (newOffset < formatted.length &&
//         actualDigitsCount < digitsBeforeCursor) {
//       if (RegExp(r'[0-9]').hasMatch(formatted[newOffset])) {
//         actualDigitsCount++;
//       }
//       newOffset++;
//     }

//     while (newOffset < formatted.length &&
//         !RegExp(r'[0-9]').hasMatch(formatted[newOffset])) {
//       newOffset++;
//     }

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: newOffset),
//     );
//   }
// }

// 2

// class DateInputFormatter extends TextInputFormatter {
//   final String pattern;
//   DateInputFormatter({required this.pattern});

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) return newValue;

//     // Count digits before the cursor
//     final cursorPosition = newValue.selection.start;
//     final digitsBeforeCursor = newValue.text
//         .substring(0, cursorPosition)
//         .replaceAll(RegExp(r'[^0-9]'), '')
//         .length;

//     // Extract digits
//     final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

//     // Build formatted string
//     String formatted = '';
//     int digitIndex = 0;
//     for (var i = 0; i < pattern.length; i++) {
//       if (digitIndex >= digitsOnly.length) break;
//       if (RegExp(r'[dDmMyY]').hasMatch(pattern[i])) {
//         formatted += digitsOnly[digitIndex++];
//       } else {
//         formatted += pattern[i];
//       }
//     }

//     // Compute new cursor offset
//     int actualDigitsCount = 0;
//     int newOffset = 0;
//     while (newOffset < formatted.length &&
//         actualDigitsCount < digitsBeforeCursor) {
//       if (RegExp(r'[0-9]').hasMatch(formatted[newOffset])) {
//         actualDigitsCount++;
//       }
//       newOffset++;
//     }

//     // If offset lands on a slash or any non-digit, move past it
//     while (newOffset < formatted.length &&
//         !RegExp(r'[0-9]').hasMatch(formatted[newOffset])) {
//       newOffset++;
//     }

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: newOffset),
//     );
//   }
// }


// I need to create a DateInputFormatter which does following things:
// 1. It should take a rawPattern as input, which can be any combination of 'm', 'd', 'y' characters.
// 2. raw pattern can be garbage like 'mmmm-ddddd-yyyyyyy' which should be normalized to valid format.
//    while formatting keep in mind that there should be max 2 'm', 2 'd' and 4 'y' characters.
// 3. Once pattern is normalized, it should format the input text accordingly.
// 
// 4. There will be autoFormatDate flag, which when true, will auto correct the date if it exceeds the limit.
// 5. For example, if user type number > 1 in the month field whatever the user type next, month will never be a valid.
//   as next number will cause month value greater than 12. In that case month should be corrected by prefixing 0 to its first digit and autoformat without waiting user next input.
//   So, if user type 2 in month field then it will be 02 instantly. 
// 6. Similarly, if user type number > 3 in the day field whatever the user type next, day will never be a valid. So similar to month, day should be corrected by prefixing 0 to its first digit.
// 7. Year will not be validated as it is not possible to validate year.
// 
// 8. During all this process cursor position should be maintained.
