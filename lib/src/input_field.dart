// import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// ///
// class InputField extends StatefulWidget {
//   ///
//   InputField({
//     super.key,
//     Object groupId = EditableText,
//     TextEditingController? controller,
//     InputDecoration? decoration = const InputDecoration(),
//     TextInputType? keyboardType,
//     TextCapitalization textCapitalization = TextCapitalization.none,
//     TextInputAction? textInputAction,
//     TextStyle? style,
//     StrutStyle? strutStyle,
//     TextDirection? textDirection,
//     TextAlign textAlign = TextAlign.start,
//     TextAlignVertical? textAlignVertical,
//     bool autofocus = false,
//     bool? showCursor,
//     String obscuringCharacter = '•',
//     bool obscureText = false,
//     bool autocorrect = true,
//     SmartDashesType? smartDashesType,
//     SmartQuotesType? smartQuotesType,
//     bool enableSuggestions = true,
//     MaxLengthEnforcement? maxLengthEnforcement,
//     int? maxLines = 1,
//     int? minLines,
//     bool expands = false,
//     int? maxLength,
//     ValueChanged<String>? onChanged,
//     bool onTapAlwaysCalled = false,
//     TapRegionCallback? onTapOutside,
//     VoidCallback? onEditingComplete,
//     ValueChanged<String>? onSubmitted,
//     List<TextInputFormatter>? inputFormatters,
//     bool? enabled,
//     bool? ignorePointers,
//     double cursorWidth = 2.0,
//     double? cursorHeight,
//     Radius? cursorRadius,
//     Color? cursorColor,
//     Color? cursorErrorColor,
//     Brightness? keyboardAppearance,
//     EdgeInsets scrollPadding = const EdgeInsets.all(20),
//     bool? enableInteractiveSelection,
//     TextSelectionControls? selectionControls,
//     InputCounterWidgetBuilder? buildCounter,
//     ScrollPhysics? scrollPhysics,
//     Iterable<String>? autofillHints,
//     ScrollController? scrollController,
//     String? restorationId,
//     bool enableIMEPersonalizedLearning = true,
//     MouseCursor? mouseCursor,
//     EditableTextContextMenuBuilder? contextMenuBuilder =
//         _defaultContextMenuBuilder,
//     SpellCheckConfiguration? spellCheckConfiguration,
//     TextMagnifierConfiguration? magnifierConfiguration,
//     UndoHistoryController? undoController,
//     AppPrivateCommandCallback? onAppPrivateCommand,
//     bool? cursorOpacityAnimates,
//     ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
//     ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
//     DragStartBehavior dragStartBehavior = DragStartBehavior.start,
//     ContentInsertionConfiguration? contentInsertionConfiguration,
//     WidgetStatesController? statesController,
//     Clip clipBehavior = Clip.hardEdge,
//     bool scribbleEnabled = true,
//     bool canRequestFocus = true,
//     this.focusNode,
//     this.readOnly = false,
//     this.onTap,
//     this.onFocusChanged,
//     this.onHover,
//   })  : enabled = enabled ?? decoration?.enabled ?? true,
//         _textFieldBuilder = ((BuildContext context, _InputFieldState state) {
//           return TextField(
//             groupId: groupId,
//             restorationId: restorationId,
//             controller: controller,
//             focusNode: state._focusNode,
//             decoration: decoration,
//             keyboardType: keyboardType,
//             textInputAction: textInputAction,
//             style: style,
//             strutStyle: strutStyle,
//             textAlign: textAlign,
//             textAlignVertical: textAlignVertical,
//             textDirection: textDirection,
//             textCapitalization: textCapitalization,
//             autofocus: autofocus,
//             statesController: statesController,
//             readOnly: readOnly,
//             showCursor: showCursor,
//             obscuringCharacter: obscuringCharacter,
//             obscureText: obscureText,
//             autocorrect: autocorrect,
//             smartDashesType: smartDashesType ??
//                 (obscureText
//                     ? SmartDashesType.disabled
//                     : SmartDashesType.enabled),
//             smartQuotesType: smartQuotesType ??
//                 (obscureText
//                     ? SmartQuotesType.disabled
//                     : SmartQuotesType.enabled),
//             enableSuggestions: enableSuggestions,
//             maxLengthEnforcement: maxLengthEnforcement,
//             maxLines: maxLines,
//             minLines: minLines,
//             expands: expands,
//             maxLength: maxLength,
//             onChanged: onChanged,
//             onTap: onTap,
//             onTapAlwaysCalled: onTapAlwaysCalled,
//             onTapOutside: onTapOutside,
//             onEditingComplete: onEditingComplete,
//             onSubmitted: onSubmitted,
//             inputFormatters: inputFormatters,
//             enabled: state.widget.enabled,
//             ignorePointers: ignorePointers,
//             cursorWidth: cursorWidth,
//             cursorHeight: cursorHeight,
//             cursorRadius: cursorRadius,
//             cursorColor: cursorColor,
//             cursorErrorColor: cursorErrorColor,
//             scrollPadding: scrollPadding,
//             scrollPhysics: scrollPhysics,
//             keyboardAppearance: keyboardAppearance,
//             enableInteractiveSelection:
//                 enableInteractiveSelection ?? (!obscureText || !readOnly),
//             selectionControls: selectionControls,
//             buildCounter: buildCounter,
//             autofillHints: autofillHints,
//             scrollController: scrollController,
//             enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
//             mouseCursor: mouseCursor,
//             contextMenuBuilder: contextMenuBuilder,
//             spellCheckConfiguration: spellCheckConfiguration,
//             magnifierConfiguration: magnifierConfiguration,
//             undoController: undoController,
//             onAppPrivateCommand: onAppPrivateCommand,
//             cursorOpacityAnimates: cursorOpacityAnimates,
//             selectionHeightStyle: selectionHeightStyle,
//             selectionWidthStyle: selectionWidthStyle,
//             dragStartBehavior: dragStartBehavior,
//             contentInsertionConfiguration: contentInsertionConfiguration,
//             clipBehavior: clipBehavior,
//             scribbleEnabled: scribbleEnabled,
//             canRequestFocus: canRequestFocus,
//           );
//         });

//   static Widget _defaultContextMenuBuilder(
//     BuildContext context,
//     EditableTextState editableTextState,
//   ) {
//     return AdaptiveTextSelectionToolbar.editableText(
//       editableTextState: editableTextState,
//     );
//   }

//   ///
//   final FocusNode? focusNode;

//   ///
//   final bool enabled;

//   ///
//   final bool readOnly;

//   ///
//   final GestureTapCallback? onTap;

//   ///
//   final ValueChanged<bool>? onFocusChanged;

//   ///
//   final ValueSetter<bool>? onHover;

//   final TextField Function(BuildContext context, _InputFieldState state)
//       _textFieldBuilder;

//   @override
//   State<InputField> createState() => _InputFieldState();
// }

// class _InputFieldState extends State<InputField> {
//   late FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();
//     _initNode();
//   }

//   void _initNode() {
//     _focusNode = (widget.focusNode ?? FocusNode())..addListener(_focusListener);
//   }

//   void _focusListener() {
//     widget.onFocusChanged?.call(_focusNode.hasFocus);
//   }

//   @override
//   void didUpdateWidget(covariant InputField oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.focusNode != widget.focusNode) {
//       _disposeNode(oldWidget);
//       _initNode();
//     }
//   }

//   void _disposeNode(InputField widget) {
//     _focusNode.removeListener(_focusListener);
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//   }

//   @override
//   void dispose() {
//     _disposeNode(widget);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget child = widget._textFieldBuilder(context, this);

//     if (widget.enabled && widget.readOnly) {
//       // TODO(pankajKoirala): Simplify this
//       return CallbackShortcuts(
//         bindings: <ShortcutActivator, VoidCallback>{
//           const SingleActivator(LogicalKeyboardKey.tab):
//               FocusScope.of(context).nextFocus,
//           const SingleActivator(LogicalKeyboardKey.arrowRight):
//               FocusScope.of(context).nextFocus,
//           // const SingleActivator(LogicalKeyboardKey.arrowDown):
//           //     FocusScope.of(context).nextFocus,
//           const SingleActivator(LogicalKeyboardKey.tab, shift: true):
//               FocusScope.of(context).previousFocus,
//           // const SingleActivator(LogicalKeyboardKey.arrowUp):
//           //     FocusScope.of(context).previousFocus,
//           const SingleActivator(LogicalKeyboardKey.arrowLeft):
//               FocusScope.of(context).previousFocus,
//           if (widget.onTap != null)
//             const SingleActivator(LogicalKeyboardKey.enter): widget.onTap!,
//         },
//         child: child,
//       );
//     }

//     if (widget.onHover != null) {
//       child = MouseRegion(
//         onEnter: (event) => widget.onHover?.call(true),
//         onExit: (event) => widget.onHover?.call(false),
//         child: child,
//       );
//     }

//     return child;
//   }
// }
