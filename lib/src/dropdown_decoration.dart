import 'package:flutter/material.dart';

/// Visual configuration for [CustomDropdown].
///
/// Every field is optional. When a value is `null` the widget falls back to a
/// sensible default derived from the ambient [Theme], so the dropdown looks at
/// home in any app while still allowing full customization.
@immutable
class DropdownDecoration {
  /// Creates a decoration. All parameters are optional.
  const DropdownDecoration({
    this.backgroundColor,
    this.highlightColor,
    this.selectedColor,
    this.textStyle,
    this.selectedTextStyle,
    this.groupHeaderStyle,
    this.disabledColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border,
    this.elevation = 4,
    this.maxHeight = 320,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 4),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  /// Background color of the open menu. Defaults to the theme surface color.
  final Color? backgroundColor;

  /// Background color painted behind an item while it is hovered / focused.
  /// Defaults to the theme primary color at low opacity.
  final Color? highlightColor;

  /// Background color painted behind the currently selected item.
  /// Defaults to the theme primary color at low opacity.
  final Color? selectedColor;

  /// Text style for normal (unselected, enabled) items.
  final TextStyle? textStyle;

  /// Text style for the selected item. Falls back to [textStyle] made bold.
  final TextStyle? selectedTextStyle;

  /// Text style for group header rows.
  final TextStyle? groupHeaderStyle;

  /// Text color for disabled items. Defaults to the theme disabled color.
  final Color? disabledColor;

  /// Corner radius of the menu and its ink effects.
  final BorderRadius borderRadius;

  /// Optional border drawn around the menu.
  final BoxBorder? border;

  /// Material elevation (shadow depth) of the menu.
  final double elevation;

  /// Maximum height of the scrollable menu before it scrolls internally.
  final double maxHeight;

  /// Padding around the list inside the menu.
  final EdgeInsetsGeometry menuPadding;

  /// Padding inside each item row.
  final EdgeInsetsGeometry itemPadding;

  /// Returns a copy of this decoration with the given fields replaced.
  DropdownDecoration copyWith({
    Color? backgroundColor,
    Color? highlightColor,
    Color? selectedColor,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    TextStyle? groupHeaderStyle,
    Color? disabledColor,
    BorderRadius? borderRadius,
    BoxBorder? border,
    double? elevation,
    double? maxHeight,
    EdgeInsetsGeometry? menuPadding,
    EdgeInsetsGeometry? itemPadding,
  }) {
    return DropdownDecoration(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      highlightColor: highlightColor ?? this.highlightColor,
      selectedColor: selectedColor ?? this.selectedColor,
      textStyle: textStyle ?? this.textStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      groupHeaderStyle: groupHeaderStyle ?? this.groupHeaderStyle,
      disabledColor: disabledColor ?? this.disabledColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      maxHeight: maxHeight ?? this.maxHeight,
      menuPadding: menuPadding ?? this.menuPadding,
      itemPadding: itemPadding ?? this.itemPadding,
    );
  }
}
