import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_dropdown.dart';
import 'dropdown_direction.dart';
import 'dropdown_loading.dart';
import 'dropdown_menu_style.dart';
import 'dropdown_search_style.dart';

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
    required this.menuStyle,
    required this.searchStyle,
    required this.items,
    required this.multiSelect,
    required this.maxSelection,
    required this.showSelectAll,
    required this.selectAllLabel,
    required this.clearAllLabel,
    required this.async,
    required this.loader,
    required this.debounce,
    required this.errorText,
    required this.retryText,
    required this.loading,
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
    required this.emptyBuilder,
    required this.errorBuilder,
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

  /// Styling for the menu box and its rows.
  final DropdownMenuStyle menuStyle;

  /// Styling for the search box.
  final DropdownSearchStyle searchStyle;

  /// Selectable items.
  final List<T> items;

  /// Whether the menu is in multi-select (checkbox) mode.
  final bool multiSelect;

  /// Multi-select: maximum selectable items, or `null` for no limit.
  final int? maxSelection;

  /// Multi-select: whether to show the select-all / clear action row.
  final bool showSelectAll;

  /// Label for the select-all action.
  final String selectAllLabel;

  /// Label for the clear action.
  final String clearAllLabel;

  /// Whether items are loaded asynchronously via [loader].
  final bool async;

  /// Async: fetches items for the given (debounced) search query.
  final Future<List<T>> Function(String query)? loader;

  /// Async: debounce before calling [loader] after a keystroke.
  final Duration debounce;

  /// Async: message shown when [loader] throws.
  final String errorText;

  /// Async: label for the retry action.
  final String retryText;

  /// Async: how the loading state is rendered.
  final DropdownLoading loading;

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

  /// Optional builder for a custom empty state.
  final WidgetBuilder? emptyBuilder;

  /// Async: optional builder for a custom error state.
  final DropdownErrorBuilder? errorBuilder;

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

  // Async loading state.
  List<T> _asyncItems = <T>[];
  bool _loading = false;
  Object? _error;
  Timer? _debounce;
  int _requestId = 0;

  // Keyboard navigation state.
  final ScrollController _scroll = ScrollController();

  /// Handles arrow/Enter/Escape keys when there is no search box (this node is
  /// the primary focus). Assigned in [initState] so it can reference [_handleKey].
  late final FocusNode _menuFocus;

  /// The search field's own focus node. Its [_handleKey] handler runs at the
  /// leaf, ahead of the text field's built-in arrow-key handling.
  late final FocusNode _searchFocus;

  /// The rows currently laid out, kept so the key handler can navigate them.
  List<_Row<T>> _rows = <_Row<T>>[];

  /// Index into [_rows] of the keyboard-highlighted item, or -1 for none.
  int _activeIndex = -1;

  /// Whether the initial highlight (the selected item) has been applied.
  bool _initHighlight = false;

  /// Set when the highlight moves by keyboard so the next frame scrolls it in.
  bool _scrollToActive = false;

  /// Marks the currently highlighted row so it can be scrolled into view.
  final GlobalKey _activeRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selected = List<T>.of(widget.initialSelected);
    _menuFocus = FocusNode(debugLabel: 'dropdownMenu', onKeyEvent: _handleKey);
    _searchFocus = FocusNode(
      debugLabel: 'dropdownSearch',
      onKeyEvent: _handleKey,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    )..forward();
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.async) _load(_query);
    // Claim focus so arrow/Enter/Escape reach the right handler: the search
    // field when present, otherwise the menu node.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (widget.enableSearch ? _searchFocus : _menuFocus).requestFocus();
    });
  }

  bool _isSelected(T item) =>
      widget.multiSelect ? _selected.contains(item) : item == widget.value;

  void _onItemTap(T item) {
    if (!widget.multiSelect) {
      widget.onSelected(item);
      return;
    }
    final bool alreadySelected = _selected.contains(item);
    // Block adding a new item once the selection cap is reached.
    if (!alreadySelected && _atLimit) return;
    setState(() {
      if (alreadySelected) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
    widget.onSelectionChanged(List<T>.of(_selected));
  }

  /// The item's own enabled state, ignoring the selection cap.
  bool _isEnabled(T item) => widget.isItemEnabled?.call(item) ?? true;

  /// Whether the multi-select cap has been reached.
  bool get _atLimit =>
      widget.maxSelection != null && _selected.length >= widget.maxSelection!;

  /// Whether [item] can be interacted with right now: enabled, and either
  /// already selected (so it can be unchecked) or the cap is not yet reached.
  bool _isSelectable(T item) =>
      _isEnabled(item) && (!_atLimit || _selected.contains(item));

  /// Items currently visible in the menu (after the search filter).
  Iterable<T> get _visibleItems => widget.items.where(_matches);

  /// Selects every visible, enabled item (union with the existing selection),
  /// stopping once [DropdownOverlay.maxSelection] is reached.
  void _selectAllVisible() {
    setState(() {
      for (final T item in _visibleItems) {
        if (_atLimit) break;
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
    _debounce?.cancel();
    _controller.dispose();
    _scroll.dispose();
    _menuFocus.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // --- Keyboard navigation ---------------------------------------------------

  /// Indices in [_rows] that can hold the highlight: item rows that are
  /// currently selectable (respecting the selection cap).
  List<int> _navigableIndices() {
    final List<int> out = <int>[];
    for (int i = 0; i < _rows.length; i++) {
      final _Row<T> r = _rows[i];
      if (!r.isHeader && _isSelectable(r.item as T)) out.add(i);
    }
    return out;
  }

  /// Row index of the currently selected item (single-select), or -1.
  int _indexOfSelected() {
    if (widget.multiSelect) return -1;
    for (int i = 0; i < _rows.length; i++) {
      final _Row<T> r = _rows[i];
      if (!r.isHeader && r.item == widget.value) return i;
    }
    return -1;
  }

  /// Moves the highlight to the next navigable row in [dir] (+1 down, -1 up).
  void _moveHighlight(int dir) {
    final List<int> nav = _navigableIndices();
    if (nav.isEmpty) return;
    int pos;
    if (_activeIndex < 0 || !nav.contains(_activeIndex)) {
      pos = dir > 0 ? 0 : nav.length - 1;
    } else {
      pos = (nav.indexOf(_activeIndex) + dir).clamp(0, nav.length - 1);
    }
    setState(() {
      _activeIndex = nav[pos];
      _scrollToActive = true;
    });
  }

  /// Selects the highlighted item, if any.
  void _activateHighlighted() {
    if (_activeIndex < 0 || _activeIndex >= _rows.length) return;
    final _Row<T> row = _rows[_activeIndex];
    if (row.isHeader) return;
    final T item = row.item as T;
    if (_isEnabled(item)) _onItemTap(item);
  }

  /// Handles arrow/Enter/Escape keys. Attached to both the menu focus node and
  /// the search field's node, so it runs ahead of the text field's own arrow
  /// handling (which would otherwise move the caret instead of the highlight).
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _activateHighlighted();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Runs [DropdownOverlay.loader] for [query]. A per-call [_requestId] guards
  /// against a slow earlier request overwriting a newer one (race condition).
  Future<void> _load(String query) async {
    final int id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<T> result = await widget.loader!(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _asyncItems = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      // The filtered list changes, so drop the highlight; it re-initializes to
      // the first match on the next build.
      _activeIndex = -1;
      _initHighlight = false;
    });
    if (!widget.async) return;
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => _load(value));
  }

  bool _matches(T item) {
    if (_query.isEmpty) return true;
    final String q = _query.toLowerCase();
    if (widget.searchMatcher != null) return widget.searchMatcher!(item, q);
    return widget.labelFor(item).toLowerCase().contains(q);
  }

  /// Builds the flat, filtered, grouped list of rows to render. In async mode
  /// the loader is responsible for filtering, so results are used as-is.
  List<_Row<T>> _buildRows() {
    final List<T> filtered =
        widget.async ? _asyncItems : widget.items.where(_matches).toList();
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
    final DropdownMenuStyle deco = widget.menuStyle;
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

  Widget _buildMenu(ThemeData theme, DropdownMenuStyle deco) {
    _rows = _buildRows();

    // Initialize the highlight to the selected item (or first match after a
    // search), then keep it valid if the row layout changed underneath it.
    if (!_initHighlight) {
      _initHighlight = true;
      final int selected = _indexOfSelected();
      final List<int> nav = _navigableIndices();
      _activeIndex =
          selected >= 0
              ? selected
              : (nav.isNotEmpty && _query.isNotEmpty ? nav.first : -1);
    } else if (_activeIndex >= _rows.length ||
        (_activeIndex >= 0 && _rows[_activeIndex].isHeader)) {
      _activeIndex = -1;
    }

    // After layout, bring a keyboard-moved highlight into view.
    if (_scrollToActive) {
      _scrollToActive = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? ctx = _activeRowKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.5,
            duration: const Duration(milliseconds: 120),
          );
        }
      });
    }

    return Material(
      color: Colors.transparent,
      child: Focus(
        focusNode: _menuFocus,
        child: Container(
          width: _menuWidth,
          constraints: BoxConstraints(maxHeight: deco.maxHeight),
          decoration: BoxDecoration(
            color: deco.backgroundColor ?? theme.colorScheme.surface,
            borderRadius: deco.borderRadius,
            border:
                deco.borderColor != null
                    ? Border.all(
                      color: deco.borderColor!,
                      width: deco.borderWidth,
                    )
                    : null,
            boxShadow:
                deco.elevation > 0
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
              Flexible(child: _buildBody(theme, deco, _rows)),
            ],
          ),
        ),
      ),
    );
  }

  /// Chooses what to render inside the scroll area: async loading/error
  /// states take precedence, then the empty state, then the item list.
  Widget _buildBody(
    ThemeData theme,
    DropdownMenuStyle deco,
    List<_Row<T>> rows,
  ) {
    if (widget.async) {
      if (_loading && rows.isEmpty) return _buildLoading(theme, deco);
      if (_error != null && rows.isEmpty) return _buildError(theme);
    }
    if (rows.isEmpty) return _buildEmpty(theme);
    return ListView.builder(
      controller: _scroll,
      padding: deco.menuPadding,
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder:
          (context, index) => _buildRow(theme, deco, rows[index], index),
    );
  }

  Widget _buildLoading(ThemeData theme, DropdownMenuStyle deco) {
    final DropdownLoading loading = widget.loading;

    if (loading.builder != null) return loading.builder!(context);

    if (loading.shimmer) {
      final Color base =
          loading.baseColor ??
          theme.colorScheme.onSurface.withValues(alpha: 0.08);
      final Color highlight =
          loading.highlightColor ??
          theme.colorScheme.onSurface.withValues(alpha: 0.18);
      return _ShimmerSkeleton(
        key: const Key('dropdownLoadingSkeleton'),
        baseColor: base,
        highlightColor: highlight,
        itemCount: loading.itemCount,
        itemPadding: deco.itemPadding,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: loading.strokeWidth,
            color: loading.color ?? theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!, () => _load(_query));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.errorText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _load(_query),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(widget.retryText),
          ),
        ],
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
    final DropdownSearchStyle ss = widget.searchStyle;
    final Color normalBorder = ss.borderColor ?? theme.dividerColor;
    final Color focusedBorder =
        ss.focusedBorderColor ?? theme.colorScheme.primary;

    OutlineInputBorder borderWith(Color color) => OutlineInputBorder(
      borderRadius: ss.borderRadius,
      borderSide: BorderSide(color: color, width: ss.borderWidth),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: TextField(
        focusNode: _searchFocus,
        autofocus: true,
        onChanged: _onSearchChanged,
        style: ss.textStyle,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: ss.hintStyle,
          prefixIcon: Icon(Icons.search, size: 20, color: ss.iconColor),
          // Show a subtle spinner while an async refetch is in flight, even
          // when stale results are still visible.
          suffixIcon:
              widget.async && _loading
                  ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : null,
          isDense: true,
          filled: ss.fillColor != null,
          fillColor: ss.fillColor,
          contentPadding: ss.contentPadding,
          border: borderWith(normalBorder),
          enabledBorder: borderWith(normalBorder),
          focusedBorder: borderWith(focusedBorder),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    if (widget.emptyBuilder != null) return widget.emptyBuilder!(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.emptyText,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      ),
    );
  }

  Widget _buildRow(
    ThemeData theme,
    DropdownMenuStyle deco,
    _Row<T> row,
    int index,
  ) {
    if (row.isHeader) {
      return Semantics(
        header: true,
        child: Padding(
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
        ),
      );
    }

    final T item = row.item as T;
    final bool isSelected = _isSelected(item);
    // Respects the selection cap: an unselected item is disabled at the limit.
    final bool isEnabled = _isSelectable(item);
    final bool isActive = index == _activeIndex;

    final Widget content =
        widget.itemBuilder != null
            ? widget.itemBuilder!(context, item, isSelected, isEnabled)
            : _defaultRowContent(theme, deco, item, isSelected, isEnabled);

    return Semantics(
      // Anchors Scrollable.ensureVisible for keyboard navigation.
      key: isActive ? _activeRowKey : null,
      container: true,
      button: true,
      enabled: isEnabled,
      // Single-select rows read as "selected"; multi-select rows as a checkbox.
      selected: widget.multiSelect ? null : isSelected,
      checked: widget.multiSelect ? isSelected : null,
      label: widget.labelFor(item),
      child: _HoverableRow(
        enabled: isEnabled,
        // In multi-select a checkbox already signals state, so don't also tint
        // the whole row background for selection.
        selected: isSelected && !widget.multiSelect,
        highlighted: isActive,
        highlightColor:
            deco.highlightColor ??
            theme.colorScheme.primary.withValues(alpha: 0.08),
        selectedColor:
            deco.selectedColor ??
            theme.colorScheme.primary.withValues(alpha: 0.12),
        onTap: isEnabled ? () => _onItemTap(item) : null,
        child: content,
      ),
    );
  }

  Widget _defaultRowContent(
    ThemeData theme,
    DropdownMenuStyle deco,
    T item,
    bool isSelected,
    bool isEnabled,
  ) {
    final TextStyle base =
        deco.itemTextStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final TextStyle style =
        !isEnabled
            ? base.copyWith(color: deco.disabledColor ?? theme.disabledColor)
            : isSelected
            ? (deco.selectedTextStyle ??
                base.copyWith(fontWeight: FontWeight.w600))
            : base;

    return Padding(
      padding: deco.itemPadding,
      child: Row(
        children: <Widget>[
          if (widget.multiSelect) ...<Widget>[
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color:
                  !isEnabled
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
    required this.highlighted,
    required this.highlightColor,
    required this.selectedColor,
    required this.onTap,
  });

  final Widget child;
  final bool enabled;
  final bool selected;

  /// Whether the row is highlighted by keyboard navigation (painted like hover).
  final bool highlighted;
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
    } else if ((_hovering || widget.highlighted) && widget.enabled) {
      background = widget.highlightColor;
    }

    return MouseRegion(
      cursor:
          widget.enabled
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

/// Animated skeleton placeholder rows used for the shimmer loading style.
///
/// Paints [itemCount] rounded bars in [baseColor] and sweeps a [highlightColor]
/// band across them, all without any third-party dependency.
class _ShimmerSkeleton extends StatefulWidget {
  const _ShimmerSkeleton({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.itemCount,
    required this.itemPadding,
  });

  final Color baseColor;
  final Color highlightColor;
  final int itemCount;
  final EdgeInsetsGeometry itemPadding;

  @override
  State<_ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<_ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  // Varied bar widths so the placeholder looks like real content.
  static const List<double> _widthFactors = <double>[0.85, 0.6, 0.9, 0.5, 0.75];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget skeleton = Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(widget.itemCount, (int i) {
        return Padding(
          padding: widget.itemPadding,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _widthFactors[i % _widthFactors.length],
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: widget.baseColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        );
      }),
    );

    return AnimatedBuilder(
      animation: _controller,
      child: skeleton,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            // Center of the highlight band sweeps from off-screen left to
            // off-screen right as the controller advances.
            final double center = _controller.value * 2 - 0.5;
            final double s0 = (center - 0.25).clamp(0.0, 1.0);
            final double s1 = center.clamp(0.0, 1.0);
            final double s2 = (center + 0.25).clamp(0.0, 1.0);
            return LinearGradient(
              colors: <Color>[
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: <double>[s0, s1, s2],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
