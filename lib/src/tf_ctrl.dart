import 'package:flutter/material.dart';
import 'package:simple_utils/simple_utils.dart';

/// Text Field Value Controller
abstract class TFCtrl<T> extends ValueCtrl<T> {
  ///
  TFCtrl({super.key, super.value})
      : editingController = TextEditingController(text: value?.toString()) {
    editingController.addListener(_listener);
  }

  ///
  final TextEditingController editingController;

  ///
  void _listener() {
    value = convertedValue;
    notifyListeners();
  }

  ///
  T? get convertedValue;

  /// Convert [T] to [String]
  String? stringValue(T? value) => value?.toString();

  @override
  void silentUpdate(T? value) {
    super.silentUpdate(value);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      editingController.text = stringValue(value) ?? '';
    });
  }

  @override
  set value(T? newValue) {
    super.value = newValue;
    editingController.text = stringValue(newValue) ?? '';
  }

  @override
  void clear() {
    super.clear();
    editingController.clear();
  }

  @override
  void dispose() {
    editingController
      ..removeListener(_listener)
      ..dispose();
    super.dispose();
  }
}

/// Text Field Integer Value Controller
class IntTFCtrl extends TFCtrl<int> {
  ///
  IntTFCtrl({super.key, super.value}) : super();

  @override
  int? get convertedValue => int.tryParse(editingController.text);
}

/// Text Field Double Value Controller
class DoubleTFCtrl extends TFCtrl<double> {
  ///
  DoubleTFCtrl({super.key, super.value});

  @override
  double? get convertedValue => double.tryParse(editingController.text);
}

/// Text Field String Value Controller
class StringTFCtrl extends TFCtrl<String> {
  ///
  StringTFCtrl({super.key, super.value}) : super();

  @override
  String? get convertedValue => editingController.text;

  @override
  bool get hasValue => value?.isNotEmpty ?? false;
}
