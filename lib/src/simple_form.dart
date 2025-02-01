import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:simple_form/src/country_lov.dart';

import '../simple_form.dart';

///
typedef Comparator<T> = bool Function(T? current, T item);

///
typedef ValueWidgetBuilder<T> = Widget Function(T item);

///
typedef SimpleFieldStateBuilder<T> = Widget Function(
  BuildContext context,
  SimpleFieldState<T> field,
);

///
typedef StringConverter<T> = T? Function(String? value);

///
typedef ValueConverter<T> = String? Function(T? value);

///
typedef JsonValueConverter<T> = dynamic Function(T? value);

///
class ValueSerializer<T> {
  ///
  const ValueSerializer({
    StringConverter<T>? stringConverter,
    ValueConverter<T>? valueConverter,
    JsonValueConverter<T>? jsonValueConverter,
  })  : stringConverter = stringConverter ?? defaultStringConverter,
        valueConverter = valueConverter ?? defaultValueConverter,
        jsonValueConverter =
            jsonValueConverter ?? valueConverter ?? defaultValueConverter;

  ///
  static T? defaultStringConverter<T>(String? source) {
    if (source == null) return null;
    return switch (T) {
      String => source as T?,
      int => int.tryParse(source) as T?,
      double => double.tryParse(source) as T?,
      num => num.tryParse(source) as T?,
      DateTime => DateTime.tryParse(source) as T?,
      bool => source.toBool as T?,
      _ => null,
    };
  }

  ///
  static String? defaultValueConverter<T>(T? value) => value?.toString();

  /// Convert [T] to [String]
  final StringConverter<T> stringConverter;

  /// Convert String to [T]
  final ValueConverter<T> valueConverter;

  /// Convert [T] to json value, by default [stringConverter] will be used
  final JsonValueConverter<T> jsonValueConverter;
}

///
class AutoScroll extends Equatable {
  ///
  const AutoScroll({
    this.alignment = 1.0,
    this.duration = kThemeChangeDuration,
    this.curve = Curves.easeIn,
    this.autofocus = true,
    this.onDone,
  });

  ///
  static const AutoScroll none = _NoScroll();

  /// 0.0 -> Top, 0.5 -> Center, 1.0 -> Bottom
  final double alignment;

  ///
  final Duration duration;

  ///
  final Curve curve;

  ///
  final bool autofocus;

  ///
  final void Function(FormFieldState<dynamic> fieldState)? onDone;

  ///
  Future<void> ensureVisible(FormFieldState<dynamic> fieldState) async {
    await Scrollable.ensureVisible(
      fieldState.context,
      alignment: alignment,
      duration: duration,
      curve: curve,
    );
    onDone?.call(fieldState);
    if (fieldState case final SimpleFieldState<dynamic> fieldState
        when autofocus) {
      fieldState.effectiveFocusNode.requestFocus();
    }
  }

  @override
  List<Object?> get props => [alignment, duration, curve];
}

class _NoScroll extends AutoScroll {
  const _NoScroll() : super();

  @override
  Future<void> ensureVisible(FormFieldState<dynamic> fieldState) async {}
}

///
class SimpleForm extends Form {
  ///
  const SimpleForm({
    required super.child,
    super.autovalidateMode,
    super.canPop,
    super.onPopInvokedWithResult,
    super.onChanged,
    super.key,
    this.json = const {},
    this.autoDispose = true,
    this.autoFillGroup = true,
    this.autoScroll = const AutoScroll(),
  });

  ///
  final Map<String, dynamic> json;

  /// Auto dispose fields controller, default to `true`
  final bool autoDispose;

  ///
  final bool autoFillGroup;

  ///
  final AutoScroll autoScroll;

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
  final _fields = <SimpleFieldState<dynamic>>{};

  @override
  SimpleForm get widget => super.widget as SimpleForm;

  void _register<T>(SimpleFieldState<T> field) {
    final initialValue = widget.json[field.widget.jsonKey]?.toString();
    if (field._toValue(initialValue) case final T value) {
      field.setValue(value);
    }
    _fields.add(field);
  }

  void _unregister<T>(SimpleFieldState<T> field) {
    _fields.remove(field);
  }

  ///
  Map<String, dynamic> get json => {
        for (final field in _fields)
          if (field._asJsonValue() case final Object value
              when field.widget.jsonKey != null)
            field.widget.jsonKey!: value,
      };

  @override
  bool validate() {
    return widget.autoScroll == AutoScroll.none
        ? super.validate()
        : validateGranularly().isEmpty;
  }

  @override
  Set<FormFieldState<Object?>> validateGranularly() {
    final invalidFields = super.validateGranularly();
    if (widget.autoScroll == AutoScroll.none) return invalidFields;
    if (invalidFields.firstOrNull case final FormFieldState<dynamic> state) {
      widget.autoScroll.ensureVisible(state);
    }
    return invalidFields;
  }

  @override
  void dispose() {
    if (widget.autoDispose) {
      for (final field in _fields) {
        field.widget.controller?.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _FormScope(
      formState: this,
      child: super.build(context),
    );
    return widget.autoFillGroup ? AutofillGroup(child: child) : child;
  }
}

///
class SimpleField<T> extends FormField<T> {
  ///
  SimpleField({
    required SimpleFieldStateBuilder<T> builder,
    FormFieldValidator<T>? validator,
    bool isRequired = false,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    this.readOnly = false,
    this.jsonKey,
    this.serializer,
    this.decoration,
    this.labelText,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onFocusChanged,
    this.onHover,
  }) : super(
          validator: validator ?? (isRequired ? _defaultValidator<T> : null),
          builder: (field) {
            return Builder(
              builder: (context) {
                return UnmanagedRestorationScope(
                  child: builder(context, field as SimpleFieldState<T>),
                );
              },
            );
          },
        );

  static String? _defaultValidator<T>(T? value) {
    if (value case final String stringValue) {
      return stringValue.isEmpty ? 'Required Field' : null;
    }
    if (value == null) return 'Required Field';
    return null;
  }

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
  final SimpleFieldController<T>? controller;

  ///
  final FocusNode? focusNode;

  ///
  final bool readOnly;

  ///
  final GestureTapCallback? onTap;

  ///
  final ValueChanged<T?>? onChanged;

  ///
  final ValueChanged<bool>? onFocusChanged;

  ///
  final ValueSetter<bool>? onHover;

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
    SimpleFieldController<String>? controller,
    ValueChanged<String?>? onChanged,
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
        focusNode: focusNode,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        decoration: decoration,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
            onChanged: field._onChangedHandler,
            autofocus: autoFocus ?? false,
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
    SimpleFieldController<String>? controller,
    FocusNode? focusNode,
    ValueChanged<String?>? onChanged,
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
        focusNode: focusNode,
        enabled: enabled,
        initialValue: initialValue,
        isRequired: isRequired,
        labelText: labelText,
        hintText: hintText,
        onChanged: onChanged,
        onSaved: onSaved,
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
                controller: field.effectiveController,
                onChanged: field.didChange,
                focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<int>? controller,
    ValueChanged<int?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final decor = DefaultInputDecoration.of(context);
          var obscure = obscureText ?? true;
          return StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                controller: field.effectiveController,
                focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<Country>? controller,
    ValueChanged<Country?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          final repo = CountryRepository.instance;
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<String>? controller,
    ValueChanged<String?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<String>? controller,
    ValueChanged<String?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<int>? controller,
    ValueChanged<int?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator ??
            (value) =>
                isRequired && (value ?? 0) <= 0 ? 'Required field' : null,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<double>? controller,
    ValueChanged<double?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator ??
            (value) =>
                isRequired && (value ?? 0) <= 0 ? 'Required field' : null,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<DateTime>? controller,
    ValueChanged<DateTime?>? onChanged,
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<DateTime>? onSaved,
    bool enabled = true,
    bool editable = false,
    String? restorationId,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    DateType? type,
    DateFormat? dateFormat,
    // SimpleDatePicker? picker,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        serializer: ValueSerializer(
          valueConverter: (value) {
            if (value == null) return null;
            return dateFormat?.format(value) ??
                (type ?? DateType.none()).formatter.dateString(value);
          },
          stringConverter: (value) =>
              (type ?? DateType.none()).formatter.dateTime,
          jsonValueConverter: (value) => value?.toIso8601String(),
        ),
        builder: (context, field) {
          final datePicker = SimpleDatePicker(dateFormat: dateFormat);
          final dateType = type ?? DateType.none();

          Future<void> onPressed() async {
            final dateTime = await datePicker.open(context);
            if (dateTime == null) return;
            field.didChange(dateTime);
            if (!context.mounted) return;
            FocusScope.of(context).nextFocus();
          }

          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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
    SimpleFieldController<String>? controller,
    ValueChanged<String?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          return TextField(
            controller: field.effectiveController,
            focusNode: field.effectiveFocusNode,
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

  // ///
  // static SimpleField<T> dropdown<T>({
  //   required List<T> items,
  //   ValueWidgetBuilder<T>? itemBuilder,
  //   ValueWidgetBuilder<T>? builder,
  //   String? jsonKey,
  //   AutovalidateMode? autovalidateMode,
  //   T? initialValue,
  //   FormFieldValidator<T>? validator,
  //   bool isRequired = false,
  //   String? labelText,
  //   String? hintText,
  //   InputDecoration? decoration,
  //   SimpleFieldController<T>? controller,
  //   ValueChanged<T?>? onChanged,
  //   ValueChanged<Listenable>? onListenableChanged,
  //   FormFieldSetter<T>? onSaved,
  //   bool enabled = true,
  //   String? restorationId,
  //   Comparator<T>? comparator,
  //   List<TextInputFormatter>? inputFormatters,
  //   Iterable<String>? autofillHints,
  //   ValueSerializer<T>? serializer,
  //   Key? key,
  // }) =>
  //     SimpleField<T>(
  //       jsonKey: jsonKey,
  //       autovalidateMode: autovalidateMode,
  //       controller: controller,
  //       decoration: decoration,
  //       enabled: enabled,
  //       initialValue: initialValue,
  //       isRequired: isRequired,
  //       labelText: labelText,
  //       hintText: hintText,
  //       onChanged: onChanged,
  //       onSaved: onSaved,
  //
  //       restorationId: restorationId,
  //       validator: validator,
  //       serializer: serializer,
  //       key: key,
  //       builder: (context, field) {
  //         final decor = DefaultInputDecoration.of(context);

  //         return SimpleDropdownButton(
  //           items: items,
  //           disabled: true,
  //           onSelected: (value) {
  //             if (value == null) return;
  //             field.didChange(value);
  //           },
  //           isSelected: (item) =>
  //               comparator?.call(field.value, item) ?? item == field.value,
  //           menuItemBuilder: (context, item) {
  //             return itemBuilder?.call(item) ??
  //                 Text(
  //                   '$item',
  //                   style: Theme.of(context).textTheme.bodyMedium,
  //                 );
  //           },
  //           builder: (state) {
  //             return TextField(
  //               controller: field.controller,
  //               focusNode: state.focusNode,
  //               onChanged: field._onChangedHandler,
  //               restorationId: restorationId,
  //               decoration: decor.copyWith(
  //                 suffixIcon: decor.suffixIcon ??
  //                     const Icon(Icons.keyboard_arrow_down_rounded),
  //               ),
  //               autofillHints: autofillHints,
  //               keyboardType: TextInputType.datetime,
  //               inputFormatters: inputFormatters,
  //               readOnly: true,
  //               onTap: enabled ? state.onPressed : null,
  //             );
  //           },
  //         );
  //       },
  //     );

  ///
  static SimpleField<bool> switchBox({
    required String label,
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    bool? initialValue,
    FormFieldValidator<bool>? validator,
    bool isRequired = false,
    SimpleFieldController<bool>? controller,
    ValueChanged<bool?>? onChanged,
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
        onChanged: onChanged,
        onSaved: onSaved,
        restorationId: restorationId,
        validator: validator,
        key: key,
        builder: (context, field) {
          // final decor = DefaultInputDecoration.of(context);
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: labelStyle ?? Theme.of(context).textTheme.bodyMedium,
            ),
          );
          // return FieldFocus(
          //   isEmpty: true,
          //   enabled: false,
          //   decoration: decor.copyWith(
          //     // hintText: label,
          //     // hintStyle:
          //     //     decor.labelStyle ?? Theme.of(context).textTheme.bodyLarge,
          //     suffixIconConstraints: BoxConstraints.tight(
          //       Size(40.0 + decor.contentPadding.right, 20),
          //     ),
          //     suffixIcon: Padding(
          //       padding: EdgeInsets.only(right: decor.contentPadding.right),
          //       child: FittedBox(
          //         fit: BoxFit.fitWidth,
          //         child: CupertinoSwitch(
          //           value: field.value ?? false,
          //           onChanged: field.didChange,
          //         ),
          //       ),
          //     ),
          //   ),
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: Text(
          //       label,
          //       style: labelStyle ?? Theme.of(context).textTheme.bodyMedium,
          //     ),
          //   ),
          // );
        },
      );

  @override
  SimpleFieldState<T> createState() => SimpleFieldState<T>();
}

///
class SimpleFieldState<T> extends FormFieldState<T> {
  ValueSerializer<T>? _serializer;
  RestorableTextEditingController? _controller;
  FocusNode? _focusNode;

  ///
  TextEditingController get effectiveController =>
      widget.controller ?? _controller!.value;

  ///
  ValueSerializer<T> get effectiveSerializer =>
      widget.serializer ?? (_serializer ??= ValueSerializer<T>());

  ///
  FocusNode get effectiveFocusNode => widget.focusNode ?? _focusNode!;

  // TODO(pankajKoirala): Check if this works as intended.
  T? _toValue(String? value) {
    return effectiveSerializer.stringConverter(value);
  }

  String? _asString(T? value) {
    return effectiveSerializer.valueConverter(value);
  }

  dynamic _asJsonValue([T? value]) {
    return effectiveSerializer.jsonValueConverter(value ?? this.value);
  }

  @override
  SimpleField<T> get widget => super.widget as SimpleField<T>;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    // Make sure to update the internal [FormFieldState] value to sync up with
    // text editing controller value.
    setValue(_toValue(effectiveController.text));
  }

  void _registerController() {
    assert(_controller != null, '');
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null, '');
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  void _createLocalFocusNode() {
    assert(_focusNode == null, '');
    _focusNode = FocusNode(debugLabel: 'SimpleField<$T>');
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    } else {
      widget.controller!
        .._attach(this)
        ..addListener(_handleControllerChanged);
    }
    if (widget.focusNode == null) {
      _createLocalFocusNode();
    }
    if (widget.onFocusChanged != null) {
      effectiveFocusNode.addListener(_focusListener);
    }
  }

  void _focusListener() {
    widget.onFocusChanged?.call(effectiveFocusNode.hasFocus);
  }

  @override
  void didUpdateWidget(SimpleField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
      if (oldWidget.controller != null && widget.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }
      if (widget.controller != null) {
        setValue(_toValue(widget.controller!.text));
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_focusListener);
      if (oldWidget.focusNode != null && widget.focusNode == null) {
        _createLocalFocusNode();
      }
      if (widget.focusNode != null) {
        _focusNode
          ?..removeListener(_focusListener)
          ..dispose();
        _controller = null;
      }
      if (widget.onFocusChanged != null) {
        effectiveFocusNode.addListener(_focusListener);
      }
    }
  }

  @override
  void dispose() {
    effectiveFocusNode.removeListener(_focusListener);
    _focusNode?.dispose();
    widget.controller
      ?.._detach(this)
      ..removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(T? value) {
    if (this.value == value) return;
    super.didChange(value);
    widget.onChanged?.call(value);
    final string = _asString(value);
    if (effectiveController.text != string) {
      effectiveController.text = string ?? '';
    }
  }

  @override
  void reset() {
    // Set the controller value before calling super.reset() to let
    // _handleControllerChanged suppress the change.
    effectiveController.text = _asString(widget.initialValue) ?? '';
    super.reset();
    widget.onChanged?.call(widget.initialValue);
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (effectiveController.text != _asString(value)) {
      didChange(_toValue(effectiveController.text));
    }
  }

  /// TextField onChanged handler
  void _onChangedHandler(String value) {
    didChange(_toValue(value));
  }

  @override
  void setValue(T? value) {
    super.setValue(value);
  }

  @override
  void deactivate() {
    SimpleForm.maybeOf(context)?._unregister(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    SimpleForm.maybeOf(context)?._register(this);
    var child = super.build(context);
    // final enabled =
    //     widget.enabled ? widget.listenables.hasValue : widget.enabled;
    final enabled = widget.enabled;
    final border = widget.decoration?.border ?? const OutlineInputBorder();
    final errorStyle = enabled
        ? null
        : const TextStyle(height: 0.01, color: Colors.transparent);

    final floatingLabelBehavior =
        widget.decoration?.floatingLabelBehavior ?? FloatingLabelBehavior.auto;

    final label = widget.labelText ??
        widget.decoration?.labelText ??
        widget.jsonKey?.camelCaseToTitle;

// && widget.readOnly
    if (widget.enabled) {
      child = CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.tab):
              FocusScope.of(context).nextFocus,
          // const SingleActivator(LogicalKeyboardKey.arrowRight):
          //     FocusScope.of(context).nextFocus,
          // const SingleActivator(LogicalKeyboardKey.arrowDown):
          //     FocusScope.of(context).nextFocus,
          const SingleActivator(LogicalKeyboardKey.tab, shift: true):
              FocusScope.of(context).previousFocus,
          // const SingleActivator(LogicalKeyboardKey.arrowUp):
          //     FocusScope.of(context).previousFocus,
          // const SingleActivator(LogicalKeyboardKey.arrowLeft):
          //     FocusScope.of(context).previousFocus,
          if (widget.onTap != null)
            const SingleActivator(LogicalKeyboardKey.enter): widget.onTap!,
        },
        child: child,
      );
    }

    if (widget.onHover != null) {
      child = MouseRegion(
        onEnter: (event) => widget.onHover?.call(true),
        onExit: (event) => widget.onHover?.call(false),
        child: child,
      );
    }

    return DefaultInputDecoration(
      decoration: (widget.decoration ?? const InputDecoration())
          .copyWith(
            labelText: floatingLabelBehavior.canFloat ? label : null,
            hintText: widget.decoration?.hintText ?? widget.hintText,
            errorText: widget.decoration?.errorText ?? errorText,
            enabled: enabled,
            border: widget.decoration?.border ?? border,
            contentPadding: widget.decoration?.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 12),
            errorStyle: widget.decoration?.errorStyle ?? errorStyle,
            floatingLabelBehavior: floatingLabelBehavior,
          )
          .applyDefaults(Theme.of(context).inputDecorationTheme),
      child: child,
    );
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
  SimpleForm get form => _formState.widget;

  @override
  bool updateShouldNotify(_FormScope old) => false;
}

///
class SimpleFieldController<T> extends TextEditingController {
  ///
  SimpleFieldController({super.text});

  /// Creates a controller for an simple field from an initial [TextEditingValue].
  ///
  /// This constructor treats a null [value] argument as if it were
  /// [TextEditingValue.empty].
  SimpleFieldController.fromValue(TextEditingValue? value)
      : super.fromValue(value ?? TextEditingValue.empty);

  SimpleFieldState<T>? _client;

  /// Set serializer
  ValueSerializer<T>? get serializer => _client?.widget.serializer;

  void _attach(SimpleFieldState<T> client) {
    assert(_client == null, '');
    _client = client;
  }

  void _detach(SimpleFieldState<T> client) {
    assert(_client == client, '');
    _client = null;
  }

  ///
  T get data => dataOrNull!;

  ///
  T? get dataOrNull => _client?.value;

  ///
  dynamic get jsonValue => serializer?.jsonValueConverter(data);

  ///
  String? get keyOrNull => _client?.widget.jsonKey;

  ///
  String get key => keyOrNull!;

  // ///
  // MapEntry<String, dynamic> get entry =>
  //     MapEntry(_key!, serializer.jsonValueConverter(data));

  // ///
  // MapEntry<String, dynamic>? get entryOrNull => hasEntry ? entry : null;

  // ///
  // bool get hasEntry => hasValue && hasKey;

  // ///
  // bool get hasKey => _key != null;
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

extension on FloatingLabelBehavior {
  bool get canFloat => this != FloatingLabelBehavior.never;
}

///
extension SimpleFormBuildContextX on BuildContext {
  ///
  SimpleFormState? get simpleForm => SimpleForm.maybeOf(this);
}

extension on String {
  /// Convert camelCase string into title `Camel Case`
  String get camelCaseToTitle {
    if (isEmpty) return this;

    final buffer = StringBuffer(this[0].toUpperCase());

    for (var i = 1; i < length; i++) {
      final char = this[i];
      if (char.toUpperCase() == char) {
        buffer.write(' ');
      }
      buffer.write(char);
    }

    return buffer.toString();
  }

  ///
  bool get toBool {
    switch (toLowerCase()) {
      case 'true' || '1':
        return true;
      case 'false' || '0':
        return false;
      default:
        return false;
    }
  }
}
