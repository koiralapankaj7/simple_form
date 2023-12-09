import 'package:flutter/widgets.dart';
import 'package:simple_form/src/country_repository.dart';
import '../simple_form.dart';

///
class TextFieldBuilder<T> extends StatefulWidget {
  ///
  const TextFieldBuilder({
    required this.ctrl,
    required this.initialValue,
    required this.builder,
    this.converter,
    super.key,
  });

  ///
  final TFCtrl<T>? ctrl;

  ///
  final T? initialValue;

  ///
  final String? Function(T?)? converter;

  ///
  final Widget Function(TextEditingController controller)? builder;

  @override
  State<TextFieldBuilder<T>> createState() => _TextFieldBuilderState<T>();
}

class _TextFieldBuilderState<T> extends State<TextFieldBuilder<T>> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  String? get _text =>
      widget.converter?.call(widget.initialValue) ??
      widget.initialValue?.toString();

  void _initController() {
    widget.ctrl?.silentUpdate(widget.initialValue);
    _controller =
        widget.ctrl?.editingController ?? TextEditingController(text: _text);
  }

  @override
  void didUpdateWidget(covariant TextFieldBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ctrl != widget.ctrl) {
      if (oldWidget.ctrl == null) {
        _controller.dispose();
      }
      _initController();
    }
  }

  @override
  void dispose() {
    if (widget.ctrl == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder?.call(_controller) ?? const SizedBox.shrink();
}

///
class CountryFieldBuilder extends TextFieldBuilder<Country> {
  ///
  const CountryFieldBuilder({
    required super.ctrl,
    required super.initialValue,
    required this.fieldBuilder,
    super.key,
  }) : super(builder: null);

  ///
  final Widget Function(
    TextEditingController controller,
    CountryRepository countryRepository,
  ) fieldBuilder;

  @override
  State<TextFieldBuilder<Country>> createState() => _CountryFieldState();
}

class _CountryFieldState extends _TextFieldBuilderState<Country> {
  late final _repo = CountryRepository();

  @override
  Widget build(BuildContext context) {
    return (widget as CountryFieldBuilder).fieldBuilder(_controller, _repo);
  }
}
