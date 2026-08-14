import 'package:flutter/material.dart';

import 'custom_dropdown.dart';
import 'dropdown_decoration.dart';
import 'dropdown_direction.dart';

/// The floating menu shown while a [CustomDropdown] is open.
///
/// This is an internal widget managed by [CustomDropdown]; it is exported only
/// so its behavior can be documented. It owns the search field state and the
/// filtered/grouped row layout, and anchors itself to the trigger via
/// [CompositedTransformFollower].
class DropdownOverlay<T> extends StatefulWidget {
  /// Creates the overlay menu. Instantiated by [CustomDropdown].
  const DropdownOverlay({
    super.key,
    required this.link,
    required this.triggerSize,
    required this.direction,
    required this.gap,
    required this.menuWidth,
    required this.decoration,
    required this.items,
    required this.multiSelect,
    required this.showSelectAll,
    required this.selectAllLabel,
    required this.clearAllLabel,
    required this.value,
    required this.initialSelected,
    required this.labelFor,
    required this.groupBy,
    required this.isItemEnabled,
    required this.itemBuilder,
    required this.enableSearch,
    required this.searchHint,
    required this.searchMatcher,
    required this.emptyText,
    required this.onSelected,
    required this.onSelectionChanged,
    required this.onDismiss,
  });

  /// Links the menu to the trigger so it follows during scroll/resize.
  final LayerLink link;

  /// Size of the trigger, used to align and size the menu.
  final Size triggerSize;

  /// Resolved side the menu opens on (never [DropdownDirection.auto] here).
  final DropdownDirection direction;

  /// Space between the trigger and the menu.
  final double gap;

  /// Explicit menu width, or `null` to derive one.
  final double? menuWidth;

  /// Visual configuration.
  final DropdownDecoration decoration;

  /// Selectable items.
  final List<T> items;

  /// Whether the menu is in multi-select (checkbox) mode.
  final bool multiSelect;

  /// Multi-select: whether to show the select-all / clear action row.
  final bool showSelectAll;

  /// Label for the select-all action.
  final String selectAllLabel;

  /// Label for the clear action.
  final String clearAllLabel;

  /// Single-select: the currently selected item.
  final T? value;

  /// Multi-select: the items selected when the menu opened.
  final List<T> initialSelected;

  /// Resolves an item's display label.
  final ItemLabel<T> labelFor;

  /// Optional grouping function.
  final ItemGroup<T>? groupBy;

  /// Optional per-item enabled predicate.
  final ItemEnabled<T>? isItemEnabled;

  /// Optional custom item row builder.
  final DropdownItemBuilder<T>? itemBuilder;

  /// Whether the search box is shown.
  final bool enableSearch;

  /// Search box placeholder.
  final String searchHint;

  /// Optional custom search predicate.
  final bool Function(T item, String query)? searchMatcher;

  /// Text shown when nothing matches the search.
  final String emptyText;

  /// Single-select: called when the user selects an enabled item.
  final ValueChanged<T> onSelected;

  /// Multi-select: called with the full selection whenever it changes.
  final ValueChanged<List<T>> onSelectionChanged;

  /// Called when the user taps outside the menu.
  final VoidCallback onDismiss;

  @override
  State<DropdownOverlay<T>> createState() => _DropdownOverlayState<T>();
}

/// A single laid-out row: either a group header or a selectable item.
class _Row<T> {
  const _Row.header(this.header) : item = null, isHeader = true;
  const _Row.item(this.item) : header = null, isHeader = false;

  final bool isHeader;
  final String? header;
  final T? item;
}

class _DropdownOverlayState<T> extends State<DropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  String _query = '';

  /// Working copy of the multi-select selection, mutated as the user toggles
  /// items while the menu stays open.
  late final List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.of(widget.initialSelected);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    )..forward();
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  bool _isSelected(T item) =>
      widget.multiSelect ? _selected.contains(item) : item == widget.value;

  void _onItemTap(T item) {
    if (!widget.multiSelect) {
      widget.onSelected(item);
      return;
    }
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
    widget.onSelectionChanged(List<T>.of(_selected));
  }

  bool _isEnabled(T item) => widget.isItemEnabled?.call(item) ?? true;

  /// Items currently visible in the menu (after the search filter).
  Iterable<T> get _visibleItems => widget.items.where(_matches);

  /// Selects every visible, enabled item (union with the existing selection).
  void _selectAllVisible() {
    setState(() {
      for (final T item in _visibleItems) {
        if (_isEnabled(item) && !_selected.contains(item)) {
          _selected.add(item);
        }
      }
    });
    widget.onSelectionChanged(List<T>.of(_selected));
  }

  /// Deselects every visible item, leaving items hidden by the filter intact.
  void _clearVisible() {
    final Set<T> visible = _visibleItems.toSet();
    setState(() => _selected.removeWhere(visible.contains));
    widget.onSelectionChanged(List<T>.of(_selected));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _matches(T item) {
    if (_query.isEmpty) return true;
    final String q = _query.toLowerCase();
    if (widget.searchMatcher != null) return widget.searchMatcher!(item, q);
    return widget.labelFor(item).toLowerCase().contains(q);
  }

  /// Builds the flat, filtered, grouped list of rows to render.
  List<_Row<T>> _buildRows() {
    final List<T> filtered = widget.items.where(_matches).toList();
    if (widget.groupBy == null) {
      return filtered.map((T i) => _Row<T>.item(i)).toList();
    }

    // Preserve first-seen group order.
    final Map<String, List<T>> grouped = <String, List<T>>{};
    final List<T> ungrouped = <T>[];
    for (final T item in filtered) {
      final String? group = widget.groupBy!(item);
      if (group == null) {
        ungrouped.add(item);
      } else {
        grouped.putIfAbsent(group, () => <T>[]).add(item);
      }
    }

    final List<_Row<T>> rows = <_Row<T>>[];
    for (final T item in ungrouped) {
      rows.add(_Row<T>.item(item));
    }
    grouped.forEach((String group, List<T> items) {
      rows.add(_Row<T>.header(group));
      for (final T item in items) {
        rows.add(_Row<T>.item(item));
      }
    });
    return rows;
  }

  ({Alignment target, Alignment follower, Offset offset}) _anchors() {
    switch (widget.direction) {
      case DropdownDirection.bottom:
      case DropdownDirection.auto:
        return (
          target: Alignment.bottomLeft,
          follower: Alignment.topLeft,
          offset: Offset(0, widget.gap),
        );
      case DropdownDirection.top:
        return (
          target: Alignment.topLeft,
          follower: Alignment.bottomLeft,
          offset: Offset(0, -widget.gap),
        );
      case DropdownDirection.right:
        return (
          target: Alignment.topRight,
          follower: Alignment.topLeft,
          offset: Offset(widget.gap, 0),
        );
      case DropdownDirection.left:
        return (
          target: Alignment.topLeft,
          follower: Alignment.topRight,
          offset: Offset(-widget.gap, 0),
        );
    }
  }

  Alignment _scaleAlignment() {
    switch (widget.direction) {
      case DropdownDirection.top:
        return Alignment.bottomCenter;
      case DropdownDirection.left:
        return Alignment.centerRight;
      case DropdownDirection.right:
        return Alignment.centerLeft;
      case DropdownDirection.bottom:
      case DropdownDirection.auto:
        return Alignment.topCenter;
    }
  }

  double get _menuWidth {
    if (widget.menuWidth != null) return widget.menuWidth!;
    final bool vertical =
        widget.direction == DropdownDirection.top ||
        widget.direction == DropdownDirection.bottom ||
        widget.direction == DropdownDirection.auto;
    return vertical ? widget.triggerSize.width : 250;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DropdownDecoration deco = widget.decoration;
    final anchors = _anchors();

    return Stack(
      children: <Widget>[
        // Tap-outside barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          targetAnchor: anchors.target,
          followerAnchor: anchors.follower,
          offset: anchors.offset,
          child: Align(
            alignment: anchors.follower,
            child: FadeTransition(
              opacity: _anim,
              child: ScaleTransition(
                scale: _anim,
                alignment: _scaleAlignment(),
                child: _buildMenu(theme, deco),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(ThemeData theme, DropdownDecoration deco) {
    final List<_Row<T>> rows = _buildRows();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: _menuWidth,
        constraints: BoxConstraints(maxHeight: deco.maxHeight),
        decoration: BoxDecoration(
          color: deco.backgroundColor ?? theme.colorScheme.surface,
          borderRadius: deco.borderRadius,
          border: deco.border,
          boxShadow: deco.elevation > 0
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: deco.elevation * 2,
                    offset: Offset(0, deco.elevation / 2),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.enableSearch) _buildSearchField(theme),
            if (widget.multiSelect && widget.showSelectAll)
              _buildSelectAllRow(theme),
            Flexible(
              child: rows.isEmpty
                  ? _buildEmpty(theme)
                  : ListView.builder(
                      padding: deco.menuPadding,
                      shrinkWrap: true,
                      itemCount: rows.length,
                      itemBuilder: (context, index) =>
                          _buildRow(theme, deco, rows[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAllRow(ThemeData theme) {
    final Color color = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: _selectAllVisible,
            icon: const Icon(Icons.done_all, size: 18),
            label: Text(widget.selectAllLabel),
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _clearVisible,
            icon: const Icon(Icons.clear_all, size: 18),
            label: Text(widget.clearAllLabel),
            style: TextButton.styleFrom(
              foregroundColor: theme.hintColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: TextField(
        autofocus: true,
        onChanged: (String value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.emptyText,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      ),
    );
  }

  Widget _buildRow(ThemeData theme, DropdownDecoration deco, _Row<T> row) {
    if (row.isHeader) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          row.header!,
          style:
              deco.groupHeaderStyle ??
              theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
      );
    }

    final T item = row.item as T;
    final bool isSelected = _isSelected(item);
    final bool isEnabled = widget.isItemEnabled?.call(item) ?? true;

    final Widget content = widget.itemBuilder != null
        ? widget.itemBuilder!(context, item, isSelected, isEnabled)
        : _defaultRowContent(theme, deco, item, isSelected, isEnabled);

    return _HoverableRow(
      enabled: isEnabled,
      // In multi-select a checkbox already signals state, so don't also tint
      // the whole row background for selection.
      selected: isSelected && !widget.multiSelect,
      highlightColor:
          deco.highlightColor ??
          theme.colorScheme.primary.withValues(alpha: 0.08),
      selectedColor:
          deco.selectedColor ??
          theme.colorScheme.primary.withValues(alpha: 0.12),
      onTap: isEnabled ? () => _onItemTap(item) : null,
      child: content,
    );
  }

  Widget _defaultRowContent(
    ThemeData theme,
    DropdownDecoration deco,
    T item,
    bool isSelected,
    bool isEnabled,
  ) {
    final TextStyle base =
        deco.textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final TextStyle style = !isEnabled
        ? base.copyWith(color: deco.disabledColor ?? theme.disabledColor)
        : isSelected
        ? (deco.selectedTextStyle ?? base.copyWith(fontWeight: FontWeight.w600))
        : base;

    return Padding(
      padding: deco.itemPadding,
      child: Row(
        children: <Widget>[
          if (widget.multiSelect) ...<Widget>[
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: !isEnabled
                  ? (deco.disabledColor ?? theme.disabledColor)
                  : isSelected
                  ? theme.colorScheme.primary
                  : theme.hintColor,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              widget.labelFor(item),
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          if (isSelected && !widget.multiSelect)
            Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

/// An item row that paints a highlight while hovered or selected.
class _HoverableRow extends StatefulWidget {
  const _HoverableRow({
    required this.child,
    required this.enabled,
    required this.selected,
    required this.highlightColor,
    required this.selectedColor,
    required this.onTap,
  });

  final Widget child;
  final bool enabled;
  final bool selected;
  final Color highlightColor;
  final Color selectedColor;
  final VoidCallback? onTap;

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color? background;
    if (widget.selected) {
      background = widget.selectedColor;
    } else if (_hovering && widget.enabled) {
      background = widget.highlightColor;
    }

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(color: background, child: widget.child),
      ),
    );
  }
}
