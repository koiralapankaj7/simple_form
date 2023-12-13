import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_form/src/formatters.dart';

void main() {
  group('FormatValidation Tests', () {
    // yyyy-MM-ddTHH:mm:ss
    final differentFormats = {
      'dd/MM/yyyyTHH:mm:ss': 'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm:ss': 'dd/MM/yyyy HH:mm:ss',
      'DD/MM/YYYYTHH:mm:SS': 'DD/MM/YYYY HH:mm:SS',
      'dD/Mm/yYYYThH:mm:sS': 'dd/MM/yyyy hh:mm:ss',
      'Dd/Mm/YyyyTHh:mM:Ss': 'DD/MM/YYYY HH:mm:SS',
      'dd/MM/yYYyTHH:mm:ss': 'dd/MM/yyyy HH:mm:ss',
      'dd/MM/YyyYTHH:mm:ss': 'dd/MM/YYYY HH:mm:ss',
      'dd/MM/yyyy': 'dd/MM/yyyy',
      'dd/MM/yyy': 'dd/MM/yyy',
      'dd/MM/yy': 'dd/MM/yy',
      'd/M/y': 'd/M/y',
      'MM/yy': 'MM/yy',
      'M/y': 'M/y',
      // Previous occurrence will be removed and new one will be added
      'ss/ii/dd/ff/MM/kk/yyyyTdd:HH:vv:mm:pp:ss': 'MM/yyyy dd:HH:mm:ss',
      // Delimiters
      'Dd-Mm-YyyyTHh,mM,Ss': 'DD-MM-YYYY HH,mm,SS',
      'Dd-Mm-YyyyTHh mM,Ss': 'DD-MM-YYYY HH mm,SS',
      'Dd Mm,YyyyTHh mM Ss': 'DD MM,YYYY HH mm SS',
      // Invalid
      'ra/da/da': '',
      'dds/yydd/mmdd': '',
      'da12/ds25/dsds125': '',
    };

    test('parse date format', () {
      for (final MapEntry(:key, :value) in differentFormats.entries) {
        final formatter = DateInputFormatter(format: key);
        expect(formatter.format, value);
      }
    });
  });

  group('DateInputFormatter Tests', () {
    // 'format' : (input,output, DateTime)
    final formats = {
      'dd/MM/yyyyTHH:mm:ss': (
        '25052023131055',
        '25/05/2023 13:10:55',
        DateTime(2023, 05, 25, 13, 10, 55),
      ),
      'dd/MM/yyyy HH:mm:ss': (
        '25052023131055',
        '25/05/2023 13:10:55',
        DateTime(2023, 05, 25, 13, 10, 55),
      ),
      'd/M/yyyTH:m:s': (
        '25023315',
        '2/5/023 3:1:5',
        DateTime(2023, 05, 02, 03, 01, 05),
      ),
      'd/M/yyTH:m:s': (
        '2523315',
        '2/5/23 3:1:5',
        DateTime(2023, 05, 02, 03, 01, 05),
      ),
      'd/M/yTH:m:s': (
        '253315',
        '2/5/3 3:1:5',
        DateTime(2023, 05, 02, 03, 01, 05),
      ),
      'dd/MM/yyyy': (
        '23062022',
        '23/06/2022',
        DateTime(2022, 06, 23),
      ),
      'd/M/yyy': (
        '36022',
        '3/6/022',
        DateTime(2022, 06, 03),
      ),
      'd/M/yy': (
        '3622',
        '3/6/22',
        DateTime(2022, 06, 03),
      ),
      'd/M/y': (
        '362',
        '3/6/2',
        DateTime(2022, 06, 03),
      ),
      'MM/yyyy': (
        '102023',
        '10/2023',
        DateTime(2023, 10),
      ),
      'MM/yyy': (
        '10023',
        '10/023',
        DateTime(2023, 10),
      ),
      'MM/yy': (
        '1023',
        '10/23',
        DateTime(2023, 10),
      ),
      'M/y': (
        '13',
        '1/3',
        DateTime(2023),
      ),
      'yyyy-MM-dd': (
        '20220623',
        '2022-06-23',
        DateTime(2022, 06, 23),
      ),
    };

    test('parse string to date string', () {
      for (final MapEntry(:key, :value) in formats.entries) {
        final formatter = DateInputFormatter(format: key);
        const oldValue = TextEditingValue.empty;
        final newValue = TextEditingValue(text: value.$1);
        expect(
          formatter.formatEditUpdate(oldValue, newValue).text,
          value.$2,
        );
      }
    });

    test('parse date string to DateTime', () {
      for (final MapEntry(:key, :value) in formats.entries) {
        final formatter = DateInputFormatter(format: key)
          ..formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: value.$1),
          );
        expect(formatter.dateTime, value.$3);
      }
    });

    // Test for handling invalid characters
    test('ignores invalid characters', () {
      final formatter = DateInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '23ab06c2022');
      expect(formatter.formatEditUpdate(oldValue, newValue).text, '23/06/2022');
    });

    // Test for handling over-length input
    test('ignores characters beyond the max length of the format', () {
      final formatter = DateInputFormatter();
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '230620221234');
      expect(formatter.formatEditUpdate(oldValue, newValue).text, '23/06/2022');
    });

    // Test for handling deletion
    test('handles deletion correctly', () {
      final formatter = DateInputFormatter();
      const oldValue = TextEditingValue(text: '23/06/2022');
      const newValue = TextEditingValue(text: '23/06/202');
      expect(formatter.formatEditUpdate(oldValue, newValue).text, '23/06/202');
    });
  });

  group('CreditCardNumberInputFormatter Tests', () {
    const formatter = CreditCardNumberInputFormatter();

    test('Formats simple credit card number', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '1234567890123456');
      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, equals('1234 5678 9012 3456'));
    });

    test('Respects maximum length', () {
      const oldValue = TextEditingValue(text: '1234 5678 9012 3456');
      const newValue = TextEditingValue(text: '1234 5678 9012 34567');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('1234 5678 9012 3456'));
    });

    test('Inserting digit in the middle', () {
      const oldValue = TextEditingValue(
        text: '1234 567 8901 2345',
        selection: TextSelection.collapsed(offset: 8),
      );
      const newValue = TextEditingValue(
        text: '1234 5678 8901 2345',
        selection: TextSelection.collapsed(offset: 9),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('1234 5678 8901 2345'));
      expect(result.selection.end, equals(9));
    });

    test('Deleting digit in the middle', () {
      const oldValue = TextEditingValue(
        text: '1234 5678 8901 2345',
        selection: TextSelection.collapsed(offset: 9),
      );
      const newValue = TextEditingValue(
        text: '1234 567 8901 2345',
        selection: TextSelection.collapsed(offset: 8),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('1234 5678 9012 345'));
      expect(result.selection.end, equals(8));
    });

    test(
        'Formats credit card number with custom length, chunk size, and separator',
        () {
      const formatter = CreditCardNumberInputFormatter(
        length: 18,
        chunkSize: 3,
        separator: '-',
      );

      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '123456789012345678');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('123-456-789-012-345-678'));
    });

    test('Handles shorter length and different separator', () {
      const formatter = CreditCardNumberInputFormatter(
        length: 12,
        separator: '.',
      );

      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '123456789012');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('1234.5678.9012'));
    });

    test('Handles no separator and different chunk size', () {
      const formatter = CreditCardNumberInputFormatter(
        length: 14,
        chunkSize: 2,
        separator: '',
      );

      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(text: '12345678901234');
      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, equals('12345678901234')); // No separator
    });
  });
}
