// import 'package:flutter/material.dart';
// import 'package:simple_utils/simple_utils.dart';

// /// Text Field Value Controller
// class TFCtrl<T> extends ValueCtrl<T> {
//   ///
//   TFCtrl({super.value});

//   ///
//   TextEditingController? _editingController;

//   ///
//   TextEditingController get textController =>
//       _editingController ??= TextEditingController(
//         text: serializer.valueConverter(value) ?? value?.toString(),
//       );

//   void _updateTextController() {
//     if (_editingController != null) {
//       _editingController!.text = serializer.valueConverter(value) ?? '';
//     }
//   }

//   @override
//   void update(T? newValue, {bool silent = false}) {
//     super.update(newValue, silent: silent);
//     if (_editingController != null) {
//       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//         _editingController!.text = serializer.valueConverter(newValue) ?? '';
//       });
//     }
//   }

//   @override
//   set value(T? newValue) {
//     if (value == newValue) return;
//     super.value = newValue;
//     _updateTextController();
//   }

//   @override
//   void clear({bool notifyListener = true}) {
//     super.clear(notifyListener: notifyListener);
//     _editingController?.clear();
//   }

//   @override
//   void dispose() {
//     _editingController?.dispose();
//     super.dispose();
//   }
// }
