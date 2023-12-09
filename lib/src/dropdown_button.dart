import 'package:flutter/material.dart';
import 'package:simple_utils/simple_utils.dart';

import 'field_focus.dart';

///
class DropDownButton<T> extends StatefulWidget {
  ///
  const DropDownButton({
    required this.items,
    required this.child,
    required this.enabled,
    required this.isEmpty,
    required this.decoration,
    required this.menuItemBuilder,
    required this.onSelected,
    required this.isSelected,
    super.key,
  });

  ///
  final List<T> items;

  ///
  final Widget? child;

  ///
  final bool enabled;

  ///
  final bool isEmpty;

  ///
  final InputDecoration decoration;

  ///
  final Widget Function(BuildContext context, T item) menuItemBuilder;

  ///
  final ValueSetter<T> onSelected;

  ///
  final bool Function(T item) isSelected;

  @override
  State<DropDownButton<T>> createState() => _DropDownButtonState<T>();
}

///
class _DropDownButtonState<T> extends State<DropDownButton<T>> {
  late final _menuFocusNode = FocusNode();
  late final _menuController = MenuController();
  late FocusNode _fieldFocus;

  @override
  void initState() {
    _fieldFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    // _fieldFocus.dispose(); // TODO => issue
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MenuAnchor(
          controller: _menuController,
          onOpen: () {
            _fieldFocus.unfocus();
            _menuFocusNode.requestFocus();
          },
          onClose: () async {
            Future.delayed(kThemeChangeDuration, _fieldFocus.requestFocus);
          },
          menuChildren: widget.items.mapIndexed((index, e) {
            final selected = widget.isSelected(e);
            return ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Material(
                color: selected
                    ? Theme.of(context).focusColor
                    : Colors.transparent,
                child: MenuItemButton(
                  onPressed: () {
                    widget.onSelected(e);
                  },
                  focusNode: index == 0 ? _menuFocusNode : null,
                  child: widget.menuItemBuilder(context, e),
                ),
              ),
            );
          }).toList(),
          child: FieldFocus(
            isEmpty: widget.isEmpty,
            focusNode: _fieldFocus,
            decoration: widget.decoration,
            enabled: widget.enabled,
            onPressed: widget.items.isEmpty
                ? null
                : () async {
                    if (_menuController.isOpen) {
                      _menuController.close();
                    } else {
                      _menuController.open();
                    }
                  },
            child: widget.child,
          ),
        );
      },
    );
  }
}