// ignore_for_file:  sort_constructors_first
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_utils/simple_utils.dart' as su;

import '../simple_form.dart';

sealed class DateType {
  DateType({
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    String? format,
  })  : formatter = DateInputFormatter(format: format),
        autofillHints = autofillHints ?? [] {
    this.inputFormatters = [
      formatter,
      ...?inputFormatters,
    ];
  }

  ///
  factory DateType.birthDate({String format}) = BirthDate;

  ///
  factory DateType.cardExpiryDate({String format}) = CardExpiryDate;

  ///
  factory DateType.other({String format}) = OtherDate;

  ///
  late final List<TextInputFormatter> inputFormatters;

  ///
  final Iterable<String> autofillHints;

  ///
  final DateInputFormatter formatter;
}

///
class CardExpiryDate extends DateType {
  CardExpiryDate({super.format = 'MM/YY'})
      : super(
          autofillHints: [AutofillHints.creditCardExpirationDate],
        );
}

///
class BirthDate extends DateType {
  BirthDate({super.format}) : super(autofillHints: [AutofillHints.birthday]);
}

///
class OtherDate extends DateType {
  OtherDate({super.format});
}

///
class SimpleDatePicker {
  ///
  SimpleDatePicker({
    DateTime? firstDate,
    DateTime? lastDate,
    this.initialDate,
    this.currentDate,
    this.initialEntryMode = DatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.locale,
    this.barrierDismissible = true,
    this.barrierColor,
    this.barrierLabel,
    this.useRootNavigator = true,
    this.routeSettings,
    this.textDirection,
    this.builder,
    this.initialDatePickerMode = DatePickerMode.day,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.anchorPoint,
    this.onDatePickerModeChange,
    this.switchToInputEntryModeIcon,
    this.switchToCalendarEntryModeIcon,
    this.dateFormat,
    this.type,
  })  : firstDate = firstDate ??
            DateTime.now().subtract(const Duration(days: 80 * 365)),
        lastDate =
            lastDate ?? DateTime.now().add(const Duration(days: 10 * 365));

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final DatePickerEntryMode initialEntryMode;
  final SelectableDayPredicate? selectableDayPredicate;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;
  final Locale? locale;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;
  final TextDirection? textDirection;
  final TransitionBuilder? builder;
  final DatePickerMode initialDatePickerMode;
  final String? errorFormatText;
  final String? errorInvalidText;
  final String? fieldHintText;
  final String? fieldLabelText;
  final TextInputType? keyboardType;
  final Offset? anchorPoint;
  final ValueChanged<DatePickerEntryMode>? onDatePickerModeChange;
  final Icon? switchToInputEntryModeIcon;
  final Icon? switchToCalendarEntryModeIcon;
  final su.DateFormat? dateFormat;
  final DateType? type;

  ///
  Future<DateTime?> open(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      initialEntryMode: initialEntryMode,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
      keyboardType: keyboardType,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      builder: builder,
      initialDatePickerMode: initialDatePickerMode,
      locale: locale,
      onDatePickerModeChange: onDatePickerModeChange,
      routeSettings: routeSettings,
      switchToCalendarEntryModeIcon: switchToCalendarEntryModeIcon,
      switchToInputEntryModeIcon: switchToCalendarEntryModeIcon,
      textDirection: textDirection,
      useRootNavigator: useRootNavigator,
    );
  }

  ///
  SimpleDatePicker copyWith({
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    DatePickerEntryMode? initialEntryMode,
    SelectableDayPredicate? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
    bool? barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    bool? useRootNavigator,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerMode? initialDatePickerMode,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TextInputType? keyboardType,
    Offset? anchorPoint,
    ValueChanged<DatePickerEntryMode>? onDatePickerModeChange,
    Icon? switchToInputEntryModeIcon,
    Icon? switchToCalendarEntryModeIcon,
  }) {
    return SimpleDatePicker(
      initialDate: initialDate ?? this.initialDate,
      firstDate: firstDate ?? this.firstDate,
      lastDate: lastDate ?? this.lastDate,
      currentDate: currentDate ?? this.currentDate,
      initialEntryMode: initialEntryMode ?? this.initialEntryMode,
      selectableDayPredicate:
          selectableDayPredicate ?? this.selectableDayPredicate,
      helpText: helpText ?? this.helpText,
      cancelText: cancelText ?? this.cancelText,
      confirmText: confirmText ?? this.confirmText,
      locale: locale ?? this.locale,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      barrierColor: barrierColor ?? this.barrierColor,
      barrierLabel: barrierLabel ?? this.barrierLabel,
      useRootNavigator: useRootNavigator ?? this.useRootNavigator,
      routeSettings: routeSettings ?? this.routeSettings,
      textDirection: textDirection ?? this.textDirection,
      builder: builder ?? this.builder,
      initialDatePickerMode:
          initialDatePickerMode ?? this.initialDatePickerMode,
      errorFormatText: errorFormatText ?? this.errorFormatText,
      errorInvalidText: errorInvalidText ?? this.errorInvalidText,
      fieldHintText: fieldHintText ?? this.fieldHintText,
      fieldLabelText: fieldLabelText ?? this.fieldLabelText,
      keyboardType: keyboardType ?? this.keyboardType,
      anchorPoint: anchorPoint ?? this.anchorPoint,
      onDatePickerModeChange:
          onDatePickerModeChange ?? this.onDatePickerModeChange,
      switchToInputEntryModeIcon:
          switchToInputEntryModeIcon ?? this.switchToInputEntryModeIcon,
      switchToCalendarEntryModeIcon:
          switchToCalendarEntryModeIcon ?? this.switchToCalendarEntryModeIcon,
    );
  }
}
