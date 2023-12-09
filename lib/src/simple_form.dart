import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_form/src/country_lov.dart';
import 'package:simple_form/src/field_focus.dart';
import 'package:simple_utils/simple_utils.dart';

import '../simple_form.dart';
import 'country_repository.dart';
import 'dropdown_button.dart';
import 'formatters.dart';
import 'text_field_builder.dart';

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

  void _register(SimpleFieldState<dynamic>? field) {
    if (field == null) return;
    _fields.add(field);
  }

  void _unregister(SimpleFieldState<dynamic>? field) {
    if (field == null) return;
    if (_widget.autoDispose) {
      field._widget.controller?.dispose();
    }
    _fields.remove(field);
  }

  ///
  Map<String, dynamic> get json => {
        for (final field in _fields)
          if (field.hasEntry) field.key: field.value,
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
  final InputDecoration? decoration;

  ///
  final String? labelText;

  ///
  final String? hintText;

  ///
  final ValueCtrl<T>? controller;

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
    StringTFCtrl? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
    Iterable<String>? autofillHints,
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
          void onChangedHandler(String value) {
            field.didChange(value);
            onChanged?.call(value);
          }

          return TextFieldBuilder(
            ctrl: controller,
            initialValue: initialValue,
            builder: (ctrl) {
              return TextField(
                onChanged: onChangedHandler,
                restorationId: restorationId,
                decoration: DefaultInputDecoration.of(context),
                autofillHints: autofillHints,
              );
            },
          );
        },
      );

// textArea,email,password,pinCode,phone,address,

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
          return CountryFieldBuilder(
            ctrl: controller,
            initialValue: initialValue,
            fieldBuilder: (ctrl, repo) {
              void onChangedHandler(String value) {
                field.didChange(repo.countryFrom(value));
                onChanged?.call(field.value);
              }

              return TextField(
                controller: ctrl,
                onChanged: onChangedHandler,
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
                  ctrl.text = result.name;
                },
              );
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
    StringTFCtrl? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
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
          void onChangedHandler(String value) {
            field.didChange(value);
            onChanged?.call(value);
          }

          return TextFieldBuilder(
            ctrl: controller,
            initialValue: initialValue,
            builder: (ctrl) {
              return TextField(
                onChanged: onChangedHandler,
                restorationId: restorationId,
                decoration: DefaultInputDecoration.of(context),
                keyboardType: TextInputType.streetAddress,
                autofillHints: const [AutofillHints.fullStreetAddress],
              );
            },
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
    StringTFCtrl? controller,
    ValueChanged<String?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String? restorationId,
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
          void onChangedHandler(String value) {
            field.didChange(value);
            onChanged?.call(value);
          }

          return TextFieldBuilder(
            ctrl: controller,
            initialValue: initialValue,
            builder: (ctrl) {
              return TextField(
                onChanged: onChangedHandler,
                restorationId: restorationId,
                decoration: DefaultInputDecoration.of(context),
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
              );
            },
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
          void onChangedHandler(String value) {
            final val = int.tryParse(value);
            field.didChange(val);
            onChanged?.call(val);
          }

          return TextFieldBuilder(
            ctrl: controller,
            initialValue: initialValue,
            builder: (ctrl) {
              return TextField(
                controller: ctrl,
                onChanged: onChangedHandler,
                restorationId: restorationId,
                decoration: DefaultInputDecoration.of(context),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  // Allow numbers only
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                  if (range != null)
                    RangeLimitingTextInputFormatter(range: range),
                ],
              );
            },
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
    DoubleTFCtrl? controller,
    ValueChanged<double?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<double>? onSaved,
    bool enabled = true,
    String? restorationId,
    (double min, double max)? range,
    int decimalPlace = 2,
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
          void onChangedHandler(String value) {
            final val = double.tryParse(value);
            field.didChange(val);
            onChanged?.call(val);
          }

          return TextFieldBuilder(
            ctrl: controller,
            initialValue: initialValue,
            builder: (ctrl) {
              return TextField(
                controller: controller?.editingController,
                onChanged: onChangedHandler,
                restorationId: restorationId,
                decoration: DefaultInputDecoration.of(context),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('^\\d+\\.?\\d{0,$decimalPlace}'),
                  ),
                  if (range != null)
                    RangeLimitingTextInputFormatter(range: range),
                ],
              );
            },
          );
        },
      );

  /// TODO : Try to implement autofill
  static SimpleField<DateTime> date({
    String? jsonKey,
    AutovalidateMode? autovalidateMode,
    DateTime? initialValue,
    FormFieldValidator<DateTime>? validator,
    bool isRequired = false,
    String? labelText,
    String? hintText,
    InputDecoration? decoration,
    ValueCtrl<DateTime>? controller,
    ValueChanged<DateTime?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<DateTime>? onSaved,
    bool enabled = true,
    String? restorationId,
    (DateTime min, DateTime max)? range,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    SelectableDayPredicate? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TextInputType? keyboardType,
    DateFormat? dateFormat,
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
        hintText: hintText,
        listenables: listenables,
        onChanged: onChanged,
        onSaved: onSaved,
        onListenableChanged: onListenableChanged,
        restorationId: restorationId,
        validator: validator ??
            (value) => isRequired && value == null ? 'Required field' : null,
        key: key,
        builder: (context, field) {
          final decor = DefaultInputDecoration.of(context);
          return FieldFocus(
            isEmpty: field.value == null,
            enabled: enabled ? listenables.hasValue : enabled,
            onPressed: () async {
              final dateTime = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: range?.$1 ??
                    DateTime.now().subtract(const Duration(days: 80 * 365)),
                lastDate: range?.$2 ?? DateTime.now(),
                currentDate: initialValue,
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
              );

              if (dateTime != null) {
                field.didChange(dateTime);
              }
            },
            decoration: decor.copyWith(
              suffixIcon: field.value != null
                  ? InkWell(
                      canRequestFocus: false,
                      onTap: () => field.didChange(null),
                      radius: 24,
                      borderRadius: BorderRadius.circular(24),
                      child: const Icon(Icons.clear),
                    )
                  : const Icon(Icons.calendar_month_rounded),
            ),
            child: Text(field.value?.formatted(dateFormat) ?? ''),
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
    ValueCtrl<T>? controller,
    ValueChanged<T?>? onChanged,
    Iterable<ValueListenable<dynamic>> listenables = const [],
    ValueChanged<Listenable>? onListenableChanged,
    FormFieldSetter<T>? onSaved,
    bool enabled = true,
    String? restorationId,
    Comparator<T>? comparator,
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
          return DropDownButton<T>(
            items: items,
            enabled: enabled ? listenables.hasValue : enabled,
            isEmpty: field.value == null,
            decoration: decor.copyWith(
              suffixIcon: decor.suffixIcon ??
                  const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            onSelected: field.didChange,
            isSelected: (item) =>
                comparator?.call(field.value, item) ?? item == field.value,
            menuItemBuilder: (context, item) {
              return itemBuilder?.call(item) ??
                  Text(
                    '$item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
            },
            child: field.value != null
                ? builder?.call(field.value as T) ??
                    Text(
                      '${field.value}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                : null,
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
    ValueCtrl<bool>? controller,
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
                Size(40.0 + decor.contentPadding.right, 20.0),
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

  ///
  bool get hasValue => value != null;

  ///
  bool get hasKey => _widget.jsonKey != null;

  ///
  bool get hasEntry => hasValue && hasKey;

  ///
  String? get keyOrNull => _widget.jsonKey;

  ///
  String get key => keyOrNull!;

  ///
  MapEntry<String, T>? get entryOrNull => hasEntry ? entry : null;

  ///
  MapEntry<String, T> get entry => MapEntry(key, value as T);

  @override
  void initState() {
    super.initState();
    // Update initial value inside the controller
    _widget.controller?.silentUpdate(value);
    _widget.controller?.addListener(_listenController);
    for (final element in _widget.listenables) {
      element.addListener(() => _listenListenable(element));
    }
  }

  /// Update value
  void _listenController() {
    didChange(_widget.controller?.value);
  }

  void _listenListenable(Listenable listenable) {
    didChange(null);
    _widget.onListenableChanged?.call(listenable);
  }

  @override
  void didChange(T? value) {
    if (this.value == value) return;
    super.didChange(value);
    if (errorText != null && value != null) {
      validate();
    }
    _widget.controller?.value = value;
    _widget.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(SimpleField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
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

    final border = OutlineInputBorder(
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
        decoration.floatingLabelBehavior ?? FloatingLabelBehavior.never;

    decoration = decoration
        .copyWith(
          labelText: floatingLabelBehavior.canFloat
              ? _widget.labelText ?? _widget.decoration?.labelText
              : null,
          hintText: _widget.decoration?.hintText ?? _widget.hintText,
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
      labelText: _widget.labelText ?? _widget.decoration?.labelText,
      child: super.build(context),
    );

    return DefaultInputDecoration(
      decoration: decoration,
      child: child,
    );
  }

  @override
  void dispose() {
    _widget.controller?.removeListener(_listenController);
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

extension on OutlineInputBorder {
  OutlineInputBorder withColor(Color? color) {
    if (color == null) return this;
    return copyWith(borderSide: borderSide.copyWith(color: color));
  }
}

extension on FloatingLabelBehavior {
  bool get canFloat => this != FloatingLabelBehavior.never;
}

extension on DateTime {
  String formatted(DateFormat? dateFormat) {
    final formatter = dateFormat ?? DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }
}

///
extension SimpleFormBuildContextX on BuildContext {
  ///
  SimpleFormState? get simpleForm => SimpleForm.maybeOf(this);
}
