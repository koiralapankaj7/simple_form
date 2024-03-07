// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_form/src/country_lov.dart';
import 'package:simple_form/src/field_focus.dart';
import 'package:simple_utils/simple_utils.dart';
import 'package:simple_widgets/simple_widgets.dart';

import '../simple_form.dart';

///
typedef Comparator<T> = bool Function(T? current, T item);

///
typedef ValueWidgetBuilder<T> = Widget Function(T item);

///
class SimpleForm extends Form {
  ///
  const SimpleForm({
    required super.child,
    super.autovalidateMode,
    super.canPop,
    super.onPopInvoked,
    super.onChanged,
    super.key,
    this.initialJson = const {},
    this.autoDispose = false,
    this.autoFillGroup = true,
  });

  ///
  final Map<String, dynamic> initialJson;

  /// Auto dispose fields controller, default to `true`
  final bool autoDispose;

  ///
  final bool autoFillGroup;

  ///
  static SimpleFormState? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope>();
    return scope?._formState;
  }

  ///
  static SimpleFormState of(BuildContext context) {
    final formState = maybeOf(context);
    assert(
      () {
        if (formState == null) {
          throw FlutterError(
            'FormBase.of() was called with a context that does not contain a FormBase widget.\n'
            'No FormBase widget ancestor could be found starting from the context that '
            'was passed to FormBase.of(). This can happen because you are using a widget '
            'that looks for a FormBase ancestor, but no such ancestor exists.\n'
            'The context used was:\n'
            '  $context',
          );
        }
        return true;
      }(),
      '',
    );
    return formState!;
  }

  @override
  FormState createState() => SimpleFormState();
}

///
class SimpleFormState extends FormState {
  final Set<SimpleFieldState<dynamic>> _fields = <SimpleFieldState<dynamic>>{};

  SimpleForm get _widget => widget as SimpleForm;

  void _register(SimpleFieldState<dynamic> field) {
    if (_widget.initialJson.isNotEmpty && field._widget.jsonKey != null) {
      final value = _widget.initialJson[field._widget.jsonKey];
      WidgetsBinding.instance.endOfFrame.then((_) {
        field.didChange(value);
      });
    }
    _fields.add(field);
  }

  void _unregister(SimpleFieldState<dynamic> field) {
    if (_widget.autoDispose) {
      field._widget.controller?.dispose();
    }
    _fields.remove(field);
  }

  ///
  Map<String, dynamic> get json => {
        for (final field in _fields)
          if (field._controller.hasEntry)
            field._controller.key: field._controller.entry.value,
      };

  @override
  Widget build(BuildContext context) {
    final child = _FormScope(
      formState: this,
      child: super.build(context),
    );

    if (_widget.autoFillGroup) {
      return AutofillGroup(
        child: child,
      );
    }
    return child;
  }

  @override
  void dispose() {
    if (_widget.autoDispose) {
      for (final field in _fields) {
        field._widget.controller?.dispose();
      }
    }
    super.dispose();
  }
}

///
typedef SimpleFieldStateBuilder<T> = Widget Function(
  BuildContext context,
  SimpleFieldState<T> field,
);

///
class SimpleField<T> extends FormField<T> {
  ///
  SimpleField({
    required SimpleFieldStateBuilder<T> builder,
    AutovalidateMode? autovalidateMode,
    T? initialValue,
    FormFieldValidator<T>? validator,
    bool isRequired = false,
    super.enabled,
    super.onSaved,
    super.restorationId,
    super.key,
    this.jsonKey,
    this.serializer,
    this.decoration,
    this.labelText,
    this.hintText,
    this.controller,
    this.onChanged,
    this.listenables = const [],
    this.onListenableChanged,
  }) : super(
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          initialValue: initialValue ?? controller?.value,
          validator: validator ??
              (value) {
                if (isRequired && value == null) {
                  return 'Required Field';
                }
                return null;
              },
          builder: (field) => Builder(
            builder: (context) =>
                builder(context, field as SimpleFieldState<T>),
          ),
        );

  ///
  final String? jsonKey;

  ///
  final ValueSerializer<T>? serializer;

  ///
  final InputDecoration? decoration;

  ///
  final String? labelText;

  ///
  final String? hintText;

  ///
  final TFCtrl<T>? controller;

  ///
  final ValueChanged<T?>? onChanged;

  ///
  final Iterable<ValueListenable<dynamic>> listenables;

  ///
  final ValueChanged<Listenable>? onListenableChanged;

  ///
  static SimpleField<String> text({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<String>? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    FormFieldSetter<String>? onSubmitted,
    bool enabled = true,
    bool? autoFocus,
    FocusNode? focusNode,
    int? maxLines,
    String? restorationId,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction? textInputAction,
    TapRegionCallback? onTapOutside,
    Key? key,
  }) =>
      SimpleField<String>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        decoration: decoration,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field._controller.textController,
            onChanged: field.didChange,
            autofocus: autoFocus ?? false,
            focusNode: focusNode,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context),
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction ?? TextInputAction.next,
            minLines: 1,
            maxLines: maxLines,
            onTapOutside: onTapOutside,
            onSubmitted: onSubmitted,
          );
        },
      );

// textArea,email,

  ///
  static SimpleField<String> password({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<String>? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    String? obscuringCharacter,
    bool? obscureText,
    TextInputAction? textInputAction,
    int? min,
    Key? key,
  }) =>
      SimpleField<String>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator ??
            (min == null
                ? null
                : (value) {
                    if ((value?.length ?? 0) < min) return 'Password too short';
                    return null;
                  }),
        key: key,
        builder: (context, field) {
          final decor = DefaultInputDecoration.of(context);
          var obscure = obscureText ?? true;
          return StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                controller: field._controller.textController,
                onChanged: field.didChange,
                restorationId: restorationId,
                decoration: decor.copyWith(
                  suffixIcon: FocusScope(
                    canRequestFocus: false,
                    child: IconButton(
                      constraints: BoxConstraints.tight(
                        const Size.square(24),
                      ),
                      splashRadius: 24,
                      onPressed: () {
                        obscure = !obscure;
                        setState(() {});
                      },
                      icon: Icon(
                        obscure
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye,
                      ),
                    ),
                  ),
                ),
                autofillHints: [
                  ...?autofillHints,
                  AutofillHints.password,
                ],
                inputFormatters: inputFormatters,
                keyboardType: obscure ? null : TextInputType.visiblePassword,
                obscureText: obscure,
                obscuringCharacter:
                    obscuringCharacter ?? String.fromCharCode(0x2022),
                textInputAction: textInputAction ?? TextInputAction.next,
              );
            },
          );
        },
      );

  ///
  static SimpleField<int> pinCode({
    String? jsonKey,
    ValueSerializer<int>? serializer,
    AutovalidateMode? autovalidateMode,
    int? initialValue,
    FormFieldValidator<int>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<int>? controller,
    ValueChanged<int?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<int>? onSaved,
    bool enabled = true,
    String? restorationId,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    String? obscuringCharacter,
    bool? obscureText,
    TextInputAction? textInputAction,
    int length = 10,
    Key? key,
  }) =>
      SimpleField<int>(
        jsonKey: jsonKey,
        serializer: serializer,
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final decor = DefaultInputDecoration.of(context);
          var obscure = obscureText ?? true;
          return StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                controller: field._controller.textController,
                onChanged: field._onChangedHandler,
                restorationId: restorationId,
                decoration: decor.copyWith(
                  suffixIcon: FocusScope(
                    canRequestFocus: false,
                    child: IconButton(
                      constraints: BoxConstraints.tight(
                        const Size.square(24),
                      ),
                      splashRadius: 24,
                      onPressed: () {
                        obscure = !obscure;
                        setState(() {});
                      },
                      icon: Icon(
                        obscure
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye,
                      ),
                    ),
                  ),
                ),
                autofillHints: [...?autofillHints],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  SimpleInputFormatter.enforcedLength(length),
                  ...?inputFormatters,
                ],
                keyboardType: TextInputType.number,
                obscureText: obscure,
                obscuringCharacter:
                    obscuringCharacter ?? String.fromCharCode(0x2022),
                textInputAction: textInputAction ?? TextInputAction.next,
              );
            },
          );
        },
      );

  ///
  static SimpleField<Country> country({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    Country? initialValue,
    FormFieldValidator<Country>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<Country>? controller,
    ValueChanged<Country?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<Country>? onSaved,
    bool enabled = true,
    String? restorationId,
    Key? key,
  }) =>
      SimpleField<Country>(
        jsonKey: jsonKey,
        serializer: ValueSerializer(
          stringConverter: CountryRepository.instance.countryFrom,
          valueConverter: (value) => value?.name,
        ),
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final repo = CountryRepository.instance;
          return TextField(
            controller: field._controller.textController,
            onChanged: field._onChangedHandler,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context).copyWith(
              prefixIcon: field.value != null
                  ? SizedBox.square(
                      dimension: 32,
                      child: Center(
                        child: Text(
                          field.value?.unicodeFlag ?? '',
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : null,
            ),
            autofillHints: const [
              AutofillHints.countryName,
              AutofillHints.countryCode,
            ],
            readOnly: true,
            onTap: () async {
              final result = await CountryLov.open(
                context,
                repository: repo,
              );
              if (result == null) return;
              field.didChange(result);
              if (!context.mounted) return;
              FocusScope.of(context).nextFocus();
            },
          );
        },
      );

  ///
  static SimpleField<String> address({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<String>? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
    TextInputAction? textInputAction,
    Key? key,
  }) =>
      SimpleField<String>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field._controller.textController,
            onChanged: field.didChange,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context),
            keyboardType: TextInputType.streetAddress,
            autofillHints: const [AutofillHints.fullStreetAddress],
            textInputAction: textInputAction ?? TextInputAction.next,
          );
        },
      );

  ///
  static SimpleField<String> phone({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<String>? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
    TextInputAction? textInputAction,
    Key? key,
  }) =>
      SimpleField<String>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field._controller.textController,
            onChanged: field.didChange,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context),
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                15,
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
              ),
            ],
            textInputAction: textInputAction ?? TextInputAction.next,
          );
        },
      );

  ///
  static SimpleField<int> number({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    int? initialValue,
    FormFieldValidator<int>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<int>? controller,
    ValueChanged<int?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<int>? onSaved,
    bool enabled = true,
    String? restorationId,
    (int min, int max)? range,
    TextInputAction? textInputAction,
    Key? key,
  }) =>
      SimpleField<int>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        decoration: decoration,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator ??
            (value) =>
                isRequired && (value ?? 0) <= 0 ? 'Required field' : null,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field._controller.textController,
            onChanged: field._onChangedHandler,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context),
            keyboardType: TextInputType.number,
            inputFormatters: [
              // Allow numbers only
              FilteringTextInputFormatter.digitsOnly,
              if (range != null) SimpleInputFormatter.enforcedRange(range),
            ],
            textInputAction: textInputAction ?? TextInputAction.next,
          );
        },
      );

  ///
  static SimpleField<double> amount({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    double? initialValue,
    FormFieldValidator<double>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<double>? controller,
    ValueChanged<double?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<double>? onSaved,
    bool enabled = true,
    String? restorationId,
    (double min, double max)? range,
    int decimalPlace = 2,
    TextInputAction? textInputAction,
    Key? key,
  }) =>
      SimpleField<double>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        decoration: decoration,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator ??
            (value) =>
                isRequired && (value ?? 0) <= 0 ? 'Required field' : null,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field._controller.textController,
            onChanged: field._onChangedHandler,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context),
            keyboardType: TextInputType.number,
            inputFormatters: [
              SimpleInputFormatter.enforcedDecimalPlace(decimalPlace),
              if (range != null) SimpleInputFormatter.enforcedRange(range),
            ],
            textInputAction: textInputAction ?? TextInputAction.next,
          );
        },
      );

  /// TODO : 1. add time support
  static SimpleField<DateTime> date({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    DateTime? initialValue,
    FormFieldValidator<DateTime>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<DateTime>? controller,
    ValueChanged<DateTime?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<DateTime>? onSaved,
    bool enabled = true,
    bool editable = false,
    String? restorationId,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    DateType? type,
    SimpleDatePicker? picker,
    TextInputAction? textInputAction,
    Key? key,
  }) =>
      SimpleField<DateTime>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        decoration: decoration,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final datePicker = picker ?? SimpleDatePicker();
          final dateType = type ?? DateType.none();
          field._controller.serializer = ValueSerializer(
            valueConverter: (value) {
              if (value == null) return null;
              return datePicker.dateFormat?.format(value) ??
                  dateType.formatter.dateString(value);
            },
            stringConverter: (value) => dateType.formatter.dateTime,
            jsonValueConverter: (value) => value?.toIso8601String(),
          );

          Future<void> onPressed() async {
            final dateTime = await datePicker.open(context);
            if (dateTime == null) return;
            field.didChange(dateTime);
            if (!context.mounted) return;
            FocusScope.of(context).nextFocus();
          }

          return TextField(
            controller: field._controller.textController,
            onChanged: field._onChangedHandler,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context).copyWith(
              hintText: hintText ?? dateType.formatter.format,
              suffixIcon: Focus(
                canRequestFocus: false,
                child: InkWell(
                  canRequestFocus: false,
                  onTap: onPressed,
                  child: const SizedBox.square(
                    dimension: 32,
                    child: Icon(Icons.calendar_month_rounded),
                  ),
                ),
              ),
            ),
            autofillHints: [
              if (dateType.autofillHint != null) dateType.autofillHint!,
              ...?autofillHints,
            ],
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              FilteringTextInputFormatter.singleLineFormatter,
              dateType.formatter,
              ...?inputFormatters,
            ],
            readOnly: !editable,
            onTap: editable ? null : onPressed,
            textInputAction: textInputAction ?? TextInputAction.next,
          );
        },
      );

  ///
  static SimpleField<String> cardNo({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<String>? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
    int length = 16,
    int chunkSize = 4,
    String separator = ' ',
    TextInputAction? textInputAction,
    Key? key,
  }) =>
      SimpleField<String>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field._controller.textController,
            onChanged: field._onChangedHandler,
            restorationId: restorationId,
            decoration: DefaultInputDecoration.of(context),
            keyboardType: TextInputType.number,
            scrollPadding: const EdgeInsets.symmetric(vertical: 100),
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [
              SimpleInputFormatter.creditCard(
                length: length,
                chunkSize: chunkSize,
                separator: separator,
              ),
            ],
            textInputAction: textInputAction ?? TextInputAction.next,
          );
        },
      );

  ///
  static SimpleField<T> dropdown<T>({
    required List<T> items,
    ValueWidgetBuilder<T>? itemBuilder,
    ValueWidgetBuilder<T>? builder,
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    T? initialValue,
    FormFieldValidator<T>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    TFCtrl<T>? controller,
    ValueChanged<T?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<T>? onSaved,
    bool enabled = true,
    String? restorationId,
    Comparator<T>? comparator,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    Key? key,
  }) =>
      SimpleField<T>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        decoration: decoration,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final decor = DefaultInputDecoration.of(context);

          return SimpleDropdownButton(
            items: items,
            disabled: true,
            onSelected: (value) {
              if (value == null) return;
              field.didChange(value);
            },
            isSelected: (item) =>
                comparator?.call(field.value, item) ?? item == field.value,
            menuItemBuilder: (context, item) {
              return itemBuilder?.call(item) ??
                  Text(
                    '$item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
            },
            builder: (state) {
              return TextField(
                controller: field._controller.textController,
                focusNode: state.focusNode,
                onChanged: field._onChangedHandler,
                restorationId: restorationId,
                decoration: decor.copyWith(
                  suffixIcon: decor.suffixIcon ??
                      const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                autofillHints: autofillHints,
                keyboardType: TextInputType.datetime,
                inputFormatters: inputFormatters,
                readOnly: true,
                onTap: enabled ? state.onPressed : null,
              );
            },
          );
        },
      );

  ///
  static SimpleField<bool> switchBox({
    required String label,
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    bool? initialValue,
    FormFieldValidator<bool>? validator,
    bool isRequired = false,
    TFCtrl<bool>? controller,
    ValueChanged<bool?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<bool>? onSaved,
    bool enabled = true,
    String? restorationId,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
    bool isCollapsed = false,
    Key? key,
  }) =>
      SimpleField<bool>(
        jsonKey: jsonKey,
        autovalidateMode: autovalidateMode,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: padding,
          labelStyle: labelStyle,
          isCollapsed: isCollapsed,
        ),
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final decor = DefaultInputDecoration.of(context);
          return FieldFocus(
            isEmpty: true,
            enabled: false,
            decoration: decor.copyWith(
              // hintText: label,
              // hintStyle:
              //     decor.labelStyle ?? Theme.of(context).textTheme.bodyLarge,
              suffixIconConstraints: BoxConstraints.tight(
                Size(40.0 + decor.contentPadding.right, 20),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: decor.contentPadding.right),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: CupertinoSwitch(
                    value: field.value ?? false,
                    onChanged: field.didChange,
                  ),
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: labelStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        },
      );

  @override
  SimpleFieldState<T> createState() => SimpleFieldState<T>();
}

///
class SimpleFieldState<T> extends FormFieldState<T> {
  SimpleField<T> get _widget => widget as SimpleField<T>;
  late TFCtrl<T> _controller;

  @override
  void initState() {
    super.initState();
    _initController();
    for (final element in _widget.listenables) {
      element.addListener(() => _listenListenable(element));
    }
  }

  void _initController() {
    _controller = _widget.controller ?? TFCtrl<T>(value: widget.initialValue);
    _controller
      ..key = _widget.jsonKey
      ..update(widget.initialValue, silent: true)
      ..addListener(_listenController);
    if (_widget.serializer != null) {
      _controller.serializer = _widget.serializer;
    }
  }

  /// Update value
  void _listenController() {
    if (_controller.value == value) return;
    didChange(_controller.value);
  }

  /// Triggered when any one of listenable changed
  void _listenListenable(Listenable listenable) {
    // Ok to call didChange as these are from separate listenable
    didChange(null);
    _widget.onListenableChanged?.call(listenable);
  }

  /// TextField onChanged handler
  void _onChangedHandler(String value) {
    didChange(_controller.serializer.stringConverter(value));
  }

  @override
  void didChange(T? value) {
    if (this.value == value) return;
    super.didChange(value);
    // if (errorText != null && value == null) {
    //   validate();
    // }
    _widget.onChanged?.call(value);
    _controller.value = value;
  }

  @override
  void didUpdateWidget(SimpleField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != _widget.controller) {
      if (oldWidget.controller == null) {
        _controller
          ..removeListener(_listenController)
          ..dispose();
      }
      _controller = _widget.controller ?? TFCtrl<T>(value: widget.initialValue);
    }
    if (oldWidget.serializer != _widget.serializer) {
      _controller.serializer = _widget.serializer;
    }

    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
      _controller.value = widget.initialValue;
    }
    if (_widget.jsonKey != oldWidget.jsonKey) {
      _controller.key = _widget.jsonKey;
    }
  }

  @override
  void deactivate() {
    SimpleForm.maybeOf(context)?._unregister(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    SimpleForm.maybeOf(context)?._register(this);

    final theme = Theme.of(context);
    final enabled =
        widget.enabled ? _widget.listenables.hasValue : widget.enabled;

    final border = _widget.decoration?.border ??
        OutlineInputBorder(
          borderSide: BorderSide(
            width: 0.5,
            color: theme.colorScheme.onBackground,
          ),
          borderRadius: BorderRadius.circular(10),
        );
    final errorStyle = enabled
        ? null
        : const TextStyle(height: 0.01, color: Colors.transparent);

    var decoration = _widget.decoration ?? const InputDecoration();

    final floatingLabelBehavior =
        decoration.floatingLabelBehavior ?? FloatingLabelBehavior.auto;

    final label = _widget.labelText ??
        _widget.decoration?.labelText ??
        _widget.jsonKey?.camelCaseToTitle;

    decoration = decoration
        .copyWith(
          labelText: floatingLabelBehavior.canFloat ? label : null,
          hintText: _widget.decoration?.hintText ?? _widget.hintText ?? label,
          errorText: _widget.decoration?.errorText ?? errorText,
          enabled: enabled,
          fillColor: decoration.fillColor ?? Colors.transparent,
          border: decoration.border ?? border,
          enabledBorder: decoration.enabledBorder ?? border,
          focusedBorder: decoration.focusedBorder ??
              border.withColor(theme.colorScheme.secondary),
          errorBorder: decoration.errorBorder ??
              border.withColor(theme.colorScheme.error),
          disabledBorder: decoration.disabledBorder ??
              border.withColor(theme.disabledColor),
          contentPadding: decoration.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12),
          errorStyle: decoration.errorStyle ?? errorStyle,
          floatingLabelBehavior: floatingLabelBehavior,
        )
        .applyDefaults(Theme.of(context).inputDecorationTheme);

    final child = _LabelBuilder(
      floatingLabel: floatingLabelBehavior.canFloat,
      label: _widget.decoration?.label,
      labelText: label,
      child: super.build(context),
    );

    return DefaultInputDecoration(
      decoration: decoration,
      child: child,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_listenController);
    if (_widget.controller == null) {
      _controller.dispose();
    }
    for (final element in _widget.listenables) {
      element.removeListener(() => _listenListenable(element));
    }
    super.dispose();
  }
}

///
class _FormScope extends InheritedWidget {
  const _FormScope({
    required super.child,
    required SimpleFormState formState,
  }) : _formState = formState;

  final SimpleFormState _formState;

  /// The [SimpleForm] associated with this widget.
  SimpleForm get form => _formState.widget as SimpleForm;

  @override
  bool updateShouldNotify(_FormScope old) => false;
}

///
class DefaultInputDecoration extends InheritedWidget {
  ///
  const DefaultInputDecoration({
    required this.decoration,
    required super.child,
    super.key,
  });

  ///
  static InputDecoration? maybeOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DefaultInputDecoration>();
    return scope?.decoration;
  }

  ///
  static InputDecoration of(BuildContext context) {
    final decoration = maybeOf(context);
    assert(
      () {
        if (decoration == null) {
          throw FlutterError(
            'DefaultInputDecoration.of() was called with a context that does not contain a DefaultInputDecoration widget.\n'
            'No DefaultInputDecoration widget ancestor could be found starting from the context that '
            'was passed to DefaultInputDecoration.of(). This can happen because you are using a widget '
            'that looks for a DefaultInputDecoration ancestor, but no such ancestor exists.\n'
            'The context used was:\n'
            '  $context',
          );
        }
        return true;
      }(),
      '',
    );
    return decoration!;
  }

  ///
  final InputDecoration decoration;

  @override
  bool updateShouldNotify(covariant DefaultInputDecoration oldWidget) =>
      oldWidget.decoration != decoration;
}

///
class _LabelBuilder extends StatelessWidget {
  ///
  const _LabelBuilder({
    required this.floatingLabel,
    required this.labelText,
    required this.label,
    required this.child,
  });

  ///
  final bool floatingLabel;

  ///
  final String? labelText;

  ///
  final Widget? label;

  ///
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!floatingLabel && (label != null || labelText != null)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (label != null)
            label!
          else ...[
            Text(labelText ?? 'Label'),
            const SizedBox(height: 8),
          ],
          child,
        ],
      );
    }

    return child;
  }
}

extension on InputBorder {
  InputBorder withColor(Color? color) {
    if (color == null) return this;
    return copyWith(borderSide: borderSide.copyWith(color: color));
  }
}

extension on FloatingLabelBehavior {
  bool get canFloat => this != FloatingLabelBehavior.never;
}

///
extension SimpleFormBuildContextX on BuildContext {
  ///
  SimpleFormState? get simpleForm => SimpleForm.maybeOf(this);
}

extension on InputDecoration {
  InputDecorationTheme get toTheme {
    return InputDecorationTheme(
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      helperStyle: helperStyle,
      helperMaxLines: helperMaxLines,
      hintStyle: hintStyle,
      hintFadeDuration: hintFadeDuration,
      errorStyle: errorStyle,
      errorMaxLines: errorMaxLines,
      floatingLabelBehavior:
          floatingLabelBehavior ?? FloatingLabelBehavior.auto,
      floatingLabelAlignment:
          floatingLabelAlignment ?? FloatingLabelAlignment.start,
      isDense: isDense ?? false,
      contentPadding: contentPadding,
      isCollapsed: isCollapsed ?? false,
      iconColor: iconColor,
      prefixStyle: prefixStyle,
      prefixIconColor: prefixIconColor,
      suffixStyle: suffixStyle,
      suffixIconColor: suffixIconColor,
      counterStyle: counterStyle,
      filled: filled ?? false,
      fillColor: fillColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      errorBorder: errorBorder,
      focusedBorder: focusedBorder,
      focusedErrorBorder: focusedErrorBorder,
      disabledBorder: disabledBorder,
      enabledBorder: enabledBorder,
      border: border,
      alignLabelWithHint: alignLabelWithHint ?? false,
      constraints: constraints,
    );
  }
}
