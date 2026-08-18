import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dropdown_chip_style.dart';
import 'dropdown_direction.dart';
import 'dropdown_field_style.dart';
import 'dropdown_loading.dart';
import 'dropdown_menu_style.dart';
import 'dropdown_overlay.dart';
import 'dropdown_search_style.dart';

part 'dropdown_controller.dart';

/// Signature for turning an item of type [T] into its display label.
typedef ItemLabel<T> = String Function(T item);

/// Signature for grouping items: returns the group name for an item, or `null`
/// to leave the item ungrouped.
typedef ItemGroup<T> = String? Function(T item);

/// Signature for deciding whether an item can be selected.
typedef ItemEnabled<T> = bool Function(T item);

/// Signature for building a fully custom row for an item.
typedef DropdownItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      bool isSelected,
      bool isEnabled,
    );

/// Signature for building a custom error state for [CustomDropdown.async].
///
/// [error] is whatever the loader threw; call [retry] to run the loader again
/// with the current query.
typedef DropdownErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// A highly customizable dropdown supporting single- and multi-select.
///
/// The simplest single-select usage only needs [items] and [onChanged]:
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
///
/// Use [CustomDropdown.multi] for multi-select with checkboxes:
///
/// ```dart
/// CustomDropdown<City>.multi(
///   items: cities,
///   selectedItems: picked,
///   itemLabel: (c) => c.name,
///   enableSearch: true,
///   onSelectionChanged: (list) => setState(() => picked = list),
/// )
/// ```
class CustomDropdown<T> extends StatefulWidget {
  /// Creates a single-select dropdown.
  const CustomDropdown({
    super.key,
    required this.items,
    required ValueChanged<T> this.onChanged,
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
    this.fieldStyle = const DropdownFieldStyle(),
    this.menuStyle = const DropdownMenuStyle(),
    this.searchStyle = const DropdownSearchStyle(),
    this.enabled = true,
    this.menuWidth,
    this.gap = 4,
    this.closeOnSelect = true,
    this.emptyText = 'No results',
    this.emptyBuilder,
    this.leading,
    this.clearable = false,
    this.onCleared,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.controller,
  }) : assert(
         !clearable || onCleared != null,
         'When clearable is true, provide onCleared to reset your value '
         '(e.g. set it to null).',
       ),
       multiSelect = false,
       errorBuilder = null,
       selectedItems = null,
       onSelectionChanged = null,
       selectedItemsLabel = null,
       showSelectAll = false,
       selectAllLabel = 'Select all',
       clearAllLabel = 'Clear',
       async = false,
       loader = null,
       debounce = const Duration(milliseconds: 300),
       errorText = 'Failed to load',
       retryText = 'Retry',
       loading = const DropdownLoading.circular(),
       validatorMulti = null,
       showChips = false,
       chipOverflow = ChipOverflow.wrap,
       chipStyle = const DropdownChipStyle();

  /// Creates a multi-select dropdown that shows a checkbox on each row and
  /// keeps the menu open while the user toggles items.
  const CustomDropdown.multi({
    super.key,
    required this.items,
    required ValueChanged<List<T>> this.onSelectionChanged,
    List<T> this.selectedItems = const <Never>[],
    this.itemLabel,
    this.groupBy,
    this.isItemEnabled,
    this.itemBuilder,
    this.enableSearch = false,
    this.searchHint = 'Search',
    this.searchMatcher,
    this.hintText = 'Select',
    this.selectedItemsLabel,
    this.showChips = false,
    this.chipOverflow = ChipOverflow.wrap,
    this.chipStyle = const DropdownChipStyle(),
    this.showSelectAll = false,
    this.selectAllLabel = 'Select all',
    this.clearAllLabel = 'Clear',
    this.direction = DropdownDirection.auto,
    this.fieldStyle = const DropdownFieldStyle(),
    this.menuStyle = const DropdownMenuStyle(),
    this.searchStyle = const DropdownSearchStyle(),
    this.enabled = true,
    this.menuWidth,
    this.gap = 4,
    this.emptyText = 'No results',
    this.emptyBuilder,
    this.leading,
    FormFieldValidator<List<T>>? validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.controller,
  }) : multiSelect = true,
       validatorMulti = validator,
       validator = null,
       errorBuilder = null,
       value = null,
       onChanged = null,
       async = false,
       loader = null,
       debounce = const Duration(milliseconds: 300),
       errorText = 'Failed to load',
       retryText = 'Retry',
       loading = const DropdownLoading.circular(),
       clearable = false,
       onCleared = null,
       // A multi-select menu stays open while toggling.
       closeOnSelect = false;

  /// Creates a single-select dropdown whose items are fetched asynchronously
  /// by [loader], which is called with the current search query (debounced).
  ///
  /// ```dart
  /// CustomDropdown<User>.async(
  ///   loader: (query) => api.searchUsers(query),
  ///   itemLabel: (u) => u.name,
  ///   onChanged: (u) => setState(() => selected = u),
  /// )
  /// ```
  ///
  /// The menu shows a loading indicator while awaiting, an error state with a
  /// retry action if [loader] throws, and [emptyText] when it returns no items.
  /// Because [loader] is expected to filter by the query itself, results are
  /// not filtered again on the client.
  const CustomDropdown.async({
    super.key,
    required Future<List<T>> Function(String query) this.loader,
    required ValueChanged<T> this.onChanged,
    this.value,
    this.itemLabel,
    this.groupBy,
    this.isItemEnabled,
    this.itemBuilder,
    this.enableSearch = true,
    this.searchHint = 'Search',
    this.hintText = 'Select',
    this.debounce = const Duration(milliseconds: 300),
    this.errorText = 'Failed to load',
    this.retryText = 'Retry',
    this.loading = const DropdownLoading.circular(),
    this.direction = DropdownDirection.auto,
    this.fieldStyle = const DropdownFieldStyle(),
    this.menuStyle = const DropdownMenuStyle(),
    this.searchStyle = const DropdownSearchStyle(),
    this.enabled = true,
    this.menuWidth,
    this.gap = 4,
    this.closeOnSelect = true,
    this.emptyText = 'No results',
    this.emptyBuilder,
    this.errorBuilder,
    this.leading,
    this.clearable = false,
    this.onCleared,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.controller,
  }) : assert(
         !clearable || onCleared != null,
         'When clearable is true, provide onCleared to reset your value '
         '(e.g. set it to null).',
       ),
       async = true,
       items = const <Never>[],
       multiSelect = false,
       searchMatcher = null,
       selectedItems = null,
       onSelectionChanged = null,
       selectedItemsLabel = null,
       showSelectAll = false,
       selectAllLabel = 'Select all',
       clearAllLabel = 'Clear',
       validatorMulti = null,
       showChips = false,
       chipOverflow = ChipOverflow.wrap,
       chipStyle = const DropdownChipStyle();

  /// The list of selectable items. Empty for [CustomDropdown.async], where
  /// items come from [loader] instead.
  final List<T> items;

  /// Whether items are loaded asynchronously via [loader].
  final bool async;

  /// Async: fetches items for the given (debounced) search query. Non-null
  /// only for [CustomDropdown.async].
  final Future<List<T>> Function(String query)? loader;

  /// Async: how long to wait after the last keystroke before calling [loader].
  final Duration debounce;

  /// Async: message shown when [loader] throws.
  final String errorText;

  /// Async: label for the retry action shown in the error state.
  final String retryText;

  /// Async: how the loading state is rendered (circular, shimmer skeleton, or
  /// a fully custom widget). Defaults to a circular spinner.
  final DropdownLoading loading;

  /// Whether this dropdown selects multiple items. Set by the constructor.
  final bool multiSelect;

  /// Single-select: called with the newly selected item. Non-null only when
  /// [multiSelect] is false.
  final ValueChanged<T>? onChanged;

  /// Single-select: the currently selected item, or `null`.
  final T? value;

  /// Multi-select: called with the full updated selection whenever the user
  /// toggles an item. Non-null only when [multiSelect] is true.
  final ValueChanged<List<T>>? onSelectionChanged;

  /// Multi-select: the currently selected items. Non-null only when
  /// [multiSelect] is true.
  final List<T>? selectedItems;

  /// Multi-select: builds the trigger label from the current selection. When
  /// `null`, the selected items' labels are joined with ", ". Ignored when
  /// [showChips] is true.
  final String Function(List<T> selected)? selectedItemsLabel;

  /// Multi-select: whether to show the selection as removable chips on the
  /// trigger instead of a comma-joined text label. Each chip has a ✕ button
  /// that removes just that item. Defaults to `false`.
  final bool showChips;

  /// Multi-select: how chips behave when they exceed the trigger width — wrap
  /// onto new lines (default) or scroll horizontally on one line. Only used
  /// when [showChips] is true.
  final ChipOverflow chipOverflow;

  /// Multi-select: styling for the chips (used when [showChips] is true).
  /// Colors default to values derived from [menuStyle] and the theme.
  final DropdownChipStyle chipStyle;

  /// Multi-select: whether to show "select all" / "clear" actions above the
  /// list. Defaults to `false`. Both actions operate on the items currently
  /// visible (respecting the active search filter) and skip disabled items.
  final bool showSelectAll;

  /// Label for the "select all" action (used when [showSelectAll] is true).
  final String selectAllLabel;

  /// Label for the "clear" action (used when [showSelectAll] is true).
  final String clearAllLabel;

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
  /// showing the label (and a check/checkbox) is used.
  final DropdownItemBuilder<T>? itemBuilder;

  /// Whether to show a search box at the top of the menu.
  final bool enableSearch;

  /// Placeholder text for the search box.
  final String searchHint;

  /// Optional custom search predicate. Receives the item and the lowercased
  /// query and returns whether the item matches. Defaults to a case-insensitive
  /// "label contains query" match.
  final bool Function(T item, String query)? searchMatcher;

  /// Text shown on the trigger when nothing is selected.
  final String hintText;

  /// Where the menu opens relative to the trigger.
  final DropdownDirection direction;

  /// Styling for the input field (the tappable trigger).
  final DropdownFieldStyle fieldStyle;

  /// Styling for the open dropdown menu (the box and its rows).
  final DropdownMenuStyle menuStyle;

  /// Styling for the search box (when `enableSearch` is on).
  final DropdownSearchStyle searchStyle;

  /// Whether the whole dropdown is interactive.
  final bool enabled;

  /// Explicit menu width. When `null`, top/bottom menus match the trigger
  /// width and left/right menus use an intrinsic width.
  final double? menuWidth;

  /// Space in logical pixels between the trigger and the menu.
  final double gap;

  /// Whether to close the menu after an item is selected. Always `false` for
  /// multi-select.
  final bool closeOnSelect;

  /// Text shown when a search yields no matches (used when [emptyBuilder] is
  /// null).
  final String emptyText;

  /// Optional builder for a fully custom empty state (no items / no matches).
  /// When null, [emptyText] is shown.
  final WidgetBuilder? emptyBuilder;

  /// Async: optional builder for a fully custom error state. Receives the
  /// thrown error and a retry callback. When null, a default message with a
  /// retry button is shown.
  final DropdownErrorBuilder? errorBuilder;

  /// Optional widget shown at the start of the trigger (e.g. an icon).
  final Widget? leading;

  /// Single-select: whether to show a clear (✕) button on the trigger while a
  /// value is selected. Tapping it calls [onCleared]. Ignored for multi-select.
  final bool clearable;

  /// Single-select: called when the user taps the clear button. Reset your
  /// selection here (typically set the value back to `null`). Required when
  /// [clearable] is true.
  final VoidCallback? onCleared;

  /// Single-select / async: optional validator for use inside a [Form]. When
  /// non-null, the dropdown registers as a [FormField]: [Form.validate] runs
  /// it against the current [value], and a non-null return shows an error
  /// message below the trigger and turns the field outline the theme's error
  /// color. Non-null only for the default and async constructors.
  final FormFieldValidator<T>? validator;

  /// Multi-select: optional validator for use inside a [Form], validating the
  /// current [selectedItems]. Set via the `validator` argument of
  /// [CustomDropdown.multi].
  final FormFieldValidator<List<T>>? validatorMulti;

  /// When to automatically run [validator] / [validatorMulti]. Defaults to
  /// [AutovalidateMode.disabled] (validate only on [Form.validate]).
  final AutovalidateMode autovalidateMode;

  /// Optional controller to open/close/toggle the menu programmatically and
  /// observe its open state. See [DropdownController].
  final DropdownController? controller;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _isOpen = false;

  String _labelFor(T item) => widget.itemLabel?.call(item) ?? item.toString();

  bool get _interactive =>
      widget.enabled && (widget.async || widget.items.isNotEmpty);

  /// Whether to show the clear (✕) button: single-select, opted in, enabled,
  /// and something is currently selected.
  bool get _showClear =>
      widget.clearable &&
      widget.enabled &&
      !widget.multiSelect &&
      widget.value != null;

  /// Whether to render the multi-select selection as chips on the trigger.
  bool get _showChips =>
      widget.multiSelect &&
      widget.showChips &&
      (widget.selectedItems?.isNotEmpty ?? false);

  /// Removes [item] from the multi-select selection and reports the new list.
  void _removeChip(T item) {
    final List<T> next = List<T>.of(widget.selectedItems ?? const <Never>[])
      ..remove(item);
    widget.onSelectionChanged?.call(next);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(open: _open, close: _close);
  }

  @override
  void didUpdateWidget(CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(open: _open, close: _close);
      widget.controller?._setIsOpen(_isOpen);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
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

    final DropdownDirection resolved = _resolveDirection(
      triggerTopLeft,
      triggerSize,
      screen,
    );

    _entry = OverlayEntry(
      builder: (context) {
        return DropdownOverlay<T>(
          link: _link,
          triggerSize: triggerSize,
          direction: resolved,
          gap: widget.gap,
          menuWidth: widget.menuWidth,
          menuStyle: widget.menuStyle,
          searchStyle: widget.searchStyle,
          items: widget.items,
          multiSelect: widget.multiSelect,
          showSelectAll: widget.showSelectAll,
          selectAllLabel: widget.selectAllLabel,
          clearAllLabel: widget.clearAllLabel,
          async: widget.async,
          loader: widget.loader,
          debounce: widget.debounce,
          errorText: widget.errorText,
          retryText: widget.retryText,
          loading: widget.loading,
          value: widget.value,
          initialSelected: widget.selectedItems ?? const <Never>[],
          labelFor: _labelFor,
          groupBy: widget.groupBy,
          isItemEnabled: widget.isItemEnabled,
          itemBuilder: widget.itemBuilder,
          enableSearch: widget.enableSearch,
          searchHint: widget.searchHint,
          searchMatcher: widget.searchMatcher,
          emptyText: widget.emptyText,
          emptyBuilder: widget.emptyBuilder,
          errorBuilder: widget.errorBuilder,
          onSelected: (item) {
            widget.onChanged?.call(item);
            if (widget.closeOnSelect) _close();
          },
          onSelectionChanged: (list) => widget.onSelectionChanged?.call(list),
          onDismiss: _close,
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    setState(() => _isOpen = true);
    widget.controller?._setIsOpen(true);
  }

  void _close() {
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
    widget.controller?._setIsOpen(false);
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
    final double needed = widget.menuStyle.maxHeight + widget.gap;

    if (spaceBelow >= needed || spaceBelow >= spaceAbove) {
      return DropdownDirection.bottom;
    }
    return DropdownDirection.top;
  }

  /// The text shown on the trigger for the current selection.
  ({String text, bool isHint}) _triggerLabel() {
    if (widget.multiSelect) {
      final List<T> selected = widget.selectedItems ?? const <Never>[];
      if (selected.isEmpty) return (text: widget.hintText, isHint: true);
      final String text =
          widget.selectedItemsLabel != null
              ? widget.selectedItemsLabel!(selected)
              : selected.map(_labelFor).join(', ');
      return (text: text, isHint: false);
    }
    final T? value = widget.value;
    return value != null
        ? (text: _labelFor(value), isHint: false)
        : (text: widget.hintText, isHint: true);
  }

  /// Whether this dropdown participates in [Form] validation.
  bool get _hasValidator =>
      widget.multiSelect
          ? widget.validatorMulti != null
          : widget.validator != null;

  /// The current selection as seen by the [FormField]: the picked value for
  /// single-select, or the selected list for multi-select.
  Object? get _formValue =>
      widget.multiSelect
          ? (widget.selectedItems ?? const <Never>[])
          : widget.value;

  /// Runs the appropriate validator against [value].
  String? _runValidator(Object? value) {
    if (widget.multiSelect) {
      final List<T> list =
          value is List<T> ? value : (value as List?)?.cast<T>() ?? <T>[];
      return widget.validatorMulti?.call(list);
    }
    return widget.validator?.call(value as T?);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DropdownFieldStyle fs = widget.fieldStyle;

    if (!_hasValidator) {
      return _buildTrigger(theme, fs, hasError: false);
    }

    return FormField<Object?>(
      initialValue: _formValue,
      autovalidateMode: widget.autovalidateMode,
      validator: _runValidator,
      builder: (FormFieldState<Object?> state) {
        // The selection is owned by the parent, so push external changes into
        // the FormField (re-running validation) whenever the content differs.
        if (!_selectionEquals(state.value, _formValue)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) state.didChange(_formValue);
          });
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTrigger(theme, fs, hasError: state.hasError),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
                child: Text(
                  state.errorText!,
                  style: (theme.textTheme.bodySmall ?? const TextStyle())
                      .copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Content equality for a selection value (list-aware for multi-select).
  bool _selectionEquals(Object? a, Object? b) {
    if (a is List && b is List) return listEquals<Object?>(a, b);
    return a == b;
  }

  Widget _buildTrigger(
    ThemeData theme,
    DropdownFieldStyle fs, {
    required bool hasError,
  }) {
    final ({String text, bool isHint}) label = _triggerLabel();

    return CompositedTransformTarget(
      link: _link,
      child: Semantics(
        container: true,
        button: true,
        enabled: _interactive,
        expanded: _isOpen,
        label: label.text,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: fs.borderRadius,
            onTap: _interactive ? _toggle : null,
            child: Container(
              padding: fs.padding,
              decoration: BoxDecoration(
                borderRadius: fs.borderRadius,
                border: Border.all(
                  color:
                      hasError
                          ? theme.colorScheme.error
                          : (fs.borderColor ?? theme.dividerColor),
                  width: fs.borderWidth,
                ),
                color: fs.backgroundColor,
              ),
              child: Row(
                children: <Widget>[
                  if (widget.leading != null) ...<Widget>[
                    widget.leading!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child:
                        _showChips
                            ? _buildChips(theme)
                            : Text(
                              label.text,
                              overflow: TextOverflow.ellipsis,
                              style: _triggerTextStyle(theme, fs, label.isHint),
                            ),
                  ),
                  if (_showClear) ...<Widget>[
                    const SizedBox(width: 4),
                    Semantics(
                      button: true,
                      label: 'Clear',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onCleared,
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: fs.iconColor ?? theme.iconTheme.color,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color:
                          !widget.enabled
                              ? theme.disabledColor
                              : (fs.iconColor ?? theme.iconTheme.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Resolves the trigger text style from [fs], honoring the hint and disabled
  /// states while letting an explicit style win.
  TextStyle? _triggerTextStyle(
    ThemeData theme,
    DropdownFieldStyle fs,
    bool isHint,
  ) {
    final TextStyle? explicit = isHint ? fs.hintStyle : fs.textStyle;
    if (!widget.enabled) {
      return (explicit ?? theme.textTheme.bodyMedium)?.copyWith(
        color: theme.disabledColor,
      );
    }
    if (explicit != null) return explicit;
    return theme.textTheme.bodyMedium?.copyWith(
      color: isHint ? theme.hintColor : null,
    );
  }

  /// Builds the multi-select chips row, wrapping or scrolling per [chipOverflow].
  Widget _buildChips(ThemeData theme) {
    final List<T> items = widget.selectedItems ?? const <Never>[];
    final DropdownChipStyle cs = widget.chipStyle;
    final List<Widget> chips = <Widget>[
      for (final T item in items) _chip(theme, cs, item),
    ];

    if (widget.chipOverflow == ChipOverflow.scroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < chips.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: cs.spacing),
              chips[i],
            ],
          ],
        ),
      );
    }
    return Wrap(spacing: cs.spacing, runSpacing: cs.spacing, children: chips);
  }

  /// A single removable chip for [item].
  Widget _chip(ThemeData theme, DropdownChipStyle cs, T item) {
    final Color background =
        cs.backgroundColor ??
        widget.menuStyle.selectedColor ??
        theme.colorScheme.primary.withValues(alpha: 0.12);
    final TextStyle labelStyle =
        cs.textStyle ??
        (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
          fontSize: 13,
        );
    final Color iconColor =
        cs.deleteIconColor ?? labelStyle.color ?? theme.colorScheme.onSurface;

    return Container(
      padding: cs.padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: cs.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              _labelFor(item),
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: 'Remove ${_labelFor(item)}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.enabled ? () => _removeChip(item) : null,
              child: Icon(
                Icons.close,
                size: cs.deleteIconSize,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
