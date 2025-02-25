// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// ///
// class FieldFocus extends StatefulWidget {
//   ///
//   const FieldFocus({
//     required this.isEmpty,
//     required this.decoration,
//     this.enabled = true,
//     this.onPressed,
//     this.focusNode,
//     this.onFocusChanged,
//     this.child,
//     super.key,
//   });

//   ///
//   final bool enabled;

//   ///
//   final bool isEmpty;

//   ///
//   final InputDecoration decoration;

//   ///
//   final AsyncCallback? onPressed;

//   ///
//   final ValueChanged<bool>? onFocusChanged;

//   ///
//   final FocusNode? focusNode;

//   ///
//   final Widget? child;

//   @override
//   State<FieldFocus> createState() => _FieldFocusState();
// }

// class _FieldFocusState extends State<FieldFocus> {
//   late FocusNode _node = widget.focusNode ?? FocusNode();

//   bool _isHovering = false;
//   bool _isActive = false;

//   Set<WidgetState> get _materialState {
//     return <WidgetState>{
//       if (_isHovering) WidgetState.hovered,
//       if (_node.hasFocus) WidgetState.focused,
//     };
//   }

//   void _handleHover(bool hovering) {
//     if (hovering != _isHovering) {
//       setState(() {
//         _isHovering = hovering;
//       });
//     }
//   }

//   void _onPressed() {
//     if (widget.onPressed == null) return;
//     _isActive = true;
//     widget.onPressed!().then((value) {
//       Future<void>.delayed(const Duration(milliseconds: 500)).then((value) {
//         _isActive = false;
//       });
//     });
//   }

//   @override
//   void didUpdateWidget(covariant FieldFocus oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.focusNode != oldWidget.focusNode) {
//       if (oldWidget.focusNode == null) {
//         _node.dispose();
//       }
//       _node = widget.focusNode ?? FocusNode();
//     }
//   }

//   @override
//   void dispose() {
//     _node.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       focusNode: _node,
//       canRequestFocus: false,
//       overlayColor: const WidgetStatePropertyAll(Colors.transparent),
//       onTap: !widget.enabled || widget.onPressed == null
//           ? null
//           : () async {
//               _node.requestFocus();
//               _onPressed();
//             },
//       child: AnimatedBuilder(
//         animation: _node,
//         builder: (context, child) {
//           return InputDecorator(
//             decoration: widget.decoration,
//             isHovering: _isHovering,
//             isFocused: _node.hasFocus,
//             isEmpty: widget.isEmpty,
//             child: child,
//           );
//         },
//         child: widget.child,
//       ),
//     );
//   }
// }
