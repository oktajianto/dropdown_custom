import 'package:flutter/material.dart';

import 'dropdown_decoration.dart';
import 'dropdown_direction.dart';
import 'dropdown_overlay.dart';

/// Signature for turning an item of type [T] into its display label.
typedef ItemLabel<T> = String Function(T item);

/// Signature for grouping items: returns the group name for an item, or `null`
/// to leave the item ungrouped.
typedef ItemGroup<T> = String? Function(T item);

/// Signature for deciding whether an item can be selected.
typedef ItemEnabled<T> = bool Function(T item);

/// Signature for building a fully custom row for an item.
typedef DropdownItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
  bool isEnabled,
);

/// A highly customizable single-select dropdown.
///
/// The simplest usage only needs [items] and [onChanged]:
///
/// ```dart
/// CustomDropdown<String>(
///   items: const ['Apple', 'Mango', 'Orange'],
///   onChanged: (value) => print(value),
/// )
/// ```
///
/// It scales up to grouped, searchable, custom-positioned menus over any model
/// type without wrapping items in a required class:
///
/// ```dart
/// CustomDropdown<City>(
///   items: cities,
///   value: selected,
///   itemLabel: (c) => c.name,
///   groupBy: (c) => c.province,
///   isItemEnabled: (c) => c.available,
///   enableSearch: true,
///   direction: DropdownDirection.auto,
///   onChanged: (c) => setState(() => selected = c),
/// )
/// ```
class CustomDropdown<T> extends StatefulWidget {
  /// Creates a single-select dropdown.
  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.itemLabel,
    this.groupBy,
    this.isItemEnabled,
    this.itemBuilder,
    this.enableSearch = false,
    this.searchHint = 'Search',
    this.searchMatcher,
    this.hintText = 'Select',
    this.direction = DropdownDirection.auto,
    this.decoration = const DropdownDecoration(),
    this.enabled = true,
    this.menuWidth,
    this.gap = 4,
    this.closeOnSelect = true,
    this.emptyText = 'No results',
    this.leading,
  });

  /// The list of selectable items.
  final List<T> items;

  /// Called with the newly selected item when the user picks one.
  final ValueChanged<T> onChanged;

  /// The currently selected item, or `null` if nothing is selected.
  final T? value;

  /// Maps an item to its display label. Defaults to `item.toString()`.
  final ItemLabel<T>? itemLabel;

  /// Optional grouping function. When provided, items are grouped under
  /// headers by the returned group name. Return `null` to leave an item
  /// ungrouped (it is placed before the first named group).
  final ItemGroup<T>? groupBy;

  /// Optional predicate deciding whether an item is selectable. Disabled items
  /// are shown greyed out and cannot be tapped. Defaults to always enabled.
  final ItemEnabled<T>? isItemEnabled;

  /// Optional builder for fully custom item rows. When `null`, a default row
  /// showing the label (and a check for the selected item) is used.
  final DropdownItemBuilder<T>? itemBuilder;

  /// Whether to show a search box at the top of the menu.
  final bool enableSearch;

  /// Placeholder text for the search box.
  final String searchHint;

  /// Optional custom search predicate. Receives the item and the lowercased
  /// query and returns whether the item matches. Defaults to a case-insensitive
  /// "label contains query" match.
  final bool Function(T item, String query)? searchMatcher;

  /// Text shown on the trigger when no item is selected.
  final String hintText;

  /// Where the menu opens relative to the trigger.
  final DropdownDirection direction;

  /// Visual configuration for the trigger and menu.
  final DropdownDecoration decoration;

  /// Whether the whole dropdown is interactive.
  final bool enabled;

  /// Explicit menu width. When `null`, top/bottom menus match the trigger
  /// width and left/right menus use an intrinsic width.
  final double? menuWidth;

  /// Space in logical pixels between the trigger and the menu.
  final double gap;

  /// Whether to close the menu after an item is selected.
  final bool closeOnSelect;

  /// Text shown when a search yields no matches.
  final String emptyText;

  /// Optional widget shown at the start of the trigger (e.g. an icon).
  final Widget? leading;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _isOpen = false;

  String _labelFor(T item) =>
      widget.itemLabel?.call(item) ?? item.toString();

  bool get _interactive => widget.enabled && widget.items.isNotEmpty;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    if (_isOpen || !_interactive) return;

    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Size triggerSize = box.size;
    final Offset triggerTopLeft = box.localToGlobal(Offset.zero);
    final Size screen = MediaQuery.of(context).size;

    final DropdownDirection resolved =
        _resolveDirection(triggerTopLeft, triggerSize, screen);

    _entry = OverlayEntry(
      builder: (context) {
        return DropdownOverlay<T>(
          link: _link,
          triggerSize: triggerSize,
          direction: resolved,
          gap: widget.gap,
          menuWidth: widget.menuWidth,
          decoration: widget.decoration,
          items: widget.items,
          value: widget.value,
          labelFor: _labelFor,
          groupBy: widget.groupBy,
          isItemEnabled: widget.isItemEnabled,
          itemBuilder: widget.itemBuilder,
          enableSearch: widget.enableSearch,
          searchHint: widget.searchHint,
          searchMatcher: widget.searchMatcher,
          emptyText: widget.emptyText,
          onSelected: (item) {
            widget.onChanged(item);
            if (widget.closeOnSelect) _close();
          },
          onDismiss: _close,
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  /// Picks a concrete side for [DropdownDirection.auto] based on available
  /// space, and otherwise honors the requested direction.
  DropdownDirection _resolveDirection(
    Offset topLeft,
    Size triggerSize,
    Size screen,
  ) {
    if (widget.direction != DropdownDirection.auto) return widget.direction;

    final double spaceBelow = screen.height - (topLeft.dy + triggerSize.height);
    final double spaceAbove = topLeft.dy;
    final double needed = widget.decoration.maxHeight + widget.gap;

    if (spaceBelow >= needed || spaceBelow >= spaceAbove) {
      return DropdownDirection.bottom;
    }
    return DropdownDirection.top;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DropdownDecoration deco = widget.decoration;
    final T? value = widget.value;

    final String triggerText =
        value != null ? _labelFor(value) : widget.hintText;
    final bool showingHint = value == null;

    return CompositedTransformTarget(
      link: _link,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: deco.borderRadius,
          onTap: _interactive ? _toggle : null,
          child: Container(
            padding: deco.itemPadding,
            decoration: BoxDecoration(
              borderRadius: deco.borderRadius,
              border: deco.border ??
                  Border.all(color: theme.dividerColor),
              color: deco.backgroundColor,
            ),
            child: Row(
              children: <Widget>[
                if (widget.leading != null) ...<Widget>[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    triggerText,
                    overflow: TextOverflow.ellipsis,
                    style: (deco.textStyle ?? theme.textTheme.bodyMedium)
                        ?.copyWith(
                      color: !widget.enabled
                          ? theme.disabledColor
                          : showingHint
                              ? theme.hintColor
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: widget.enabled
                        ? theme.iconTheme.color
                        : theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
